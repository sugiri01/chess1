const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const { Chess } = require('chess.js');
const { v4: uuidv4 } = require('uuid');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// In-memory storage (MVP - no database)
const matches = new Map(); // matchId -> Match
const players = new Map(); // socketId -> Player
const queue = []; // Array of playerIds waiting

const PORT = process.env.PORT || 3000;

// Data Models
class Player {
  constructor(playerId, socketId, color = null) {
    this.playerId = playerId;
    this.socketId = socketId;
    this.color = color;
  }
}

class Match {
  constructor(matchId, whitePlayerId, blackPlayerId) {
    this.matchId = matchId;
    this.players = {
      white: whitePlayerId,
      black: blackPlayerId
    };
    this.chess = new Chess();
    this.fen = this.chess.fen();
    this.turn = 'white';
    this.status = 'active';
    this.clock = {
      whiteMs: 300000, // 5 minutes default
      blackMs: 300000,
      lastMoveTs: Date.now()
    };
    this.result = null;
  }

  updateClock() {
    const now = Date.now();
    const elapsed = now - this.clock.lastMoveTs;
    
    if (this.turn === 'white') {
      this.clock.whiteMs = Math.max(0, this.clock.whiteMs - elapsed);
    } else {
      this.clock.blackMs = Math.max(0, this.clock.blackMs - elapsed);
    }
    
    this.clock.lastMoveTs = now;

    // Check timeout
    if (this.clock.whiteMs === 0) {
      this.result = { winner: 'black', reason: 'timeout' };
      this.status = 'finished';
      return true;
    }
    if (this.clock.blackMs === 0) {
      this.result = { winner: 'white', reason: 'timeout' };
      this.status = 'finished';
      return true;
    }
    
    return false;
  }

  makeMove(from, to, promotion) {
    // Server-side validation only
    const move = this.chess.move({ from, to, promotion });
    
    if (!move) {
      return { success: false, reason: 'Invalid move' };
    }

    // Update state
    this.fen = this.chess.fen();
    this.turn = this.chess.turn() === 'w' ? 'white' : 'black';

    // Update clock
    this.updateClock();

    // Check game over conditions
    if (this.chess.isCheckmate()) {
      const winner = this.chess.turn() === 'w' ? 'black' : 'white';
      this.result = { winner, reason: 'checkmate' };
      this.status = 'finished';
    } else if (this.chess.isDraw()) {
      this.result = { winner: 'draw', reason: 'draw' };
      this.status = 'finished';
    } else if (this.chess.isStalemate()) {
      this.result = { winner: 'draw', reason: 'stalemate' };
      this.status = 'finished';
    } else if (this.chess.isThreefoldRepetition()) {
      this.result = { winner: 'draw', reason: 'repetition' };
      this.status = 'finished';
    } else if (this.chess.isInsufficientMaterial()) {
      this.result = { winner: 'draw', reason: 'insufficient material' };
      this.status = 'finished';
    }

    return { success: true };
  }
}

// Socket.IO event handlers
io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);

  // Handle join_queue
  socket.on('join_queue', () => {
    console.log(`Player ${socket.id} joining queue`);

    // Create player
    const playerId = uuidv4();
    const player = new Player(playerId, socket.id);
    players.set(socket.id, player);

    // Add to queue
    queue.push(playerId);

    // Try to match
    if (queue.length >= 2) {
      matchPlayers();
    }
  });

  // Handle make_move
  socket.on('make_move', (data) => {
    const { matchId, from, to, promotion } = data;
    
    console.log(`Move attempt: ${socket.id} from ${from} to ${to}`);

    // Validate match exists
    const match = matches.get(matchId);
    if (!match) {
      socket.emit('illegal_move', { reason: 'Match not found' });
      return;
    }

    // Validate player belongs to match
    const player = players.get(socket.id);
    if (!player) {
      socket.emit('illegal_move', { reason: 'Player not found' });
      return;
    }

    // Validate correct turn
    if (match.turn !== player.color) {
      socket.emit('illegal_move', { reason: 'Not your turn' });
      return;
    }

    // Check if player matches the turn color
    if (match.players[player.color] !== player.playerId) {
      socket.emit('illegal_move', { reason: 'Invalid player' });
      return;
    }

    // Make move (server validates)
    const result = match.makeMove(from, to, promotion);
    
    if (!result.success) {
      socket.emit('illegal_move', { reason: result.reason });
      return;
    }

    // Broadcast new state to both players
    const moveResult = {
      fen: match.fen,
      turn: match.turn,
      clock: {
        whiteMs: match.clock.whiteMs,
        blackMs: match.clock.blackMs
      }
    };

    // Get opponent socket
    const whitePlayer = Array.from(players.values()).find(p => p.playerId === match.players.white);
    const blackPlayer = Array.from(players.values()).find(p => p.playerId === match.players.black);

    if (whitePlayer) {
      io.to(whitePlayer.socketId).emit('move_result', moveResult);
    }
    if (blackPlayer) {
      io.to(blackPlayer.socketId).emit('move_result', moveResult);
    }

    // Check if game over
    if (match.status === 'finished') {
      if (whitePlayer) {
        io.to(whitePlayer.socketId).emit('game_over', match.result);
      }
      if (blackPlayer) {
        io.to(blackPlayer.socketId).emit('game_over', match.result);
      }
      
      // Clean up match
      matches.delete(matchId);
    }
  });

  // Handle resign
  socket.on('resign', (data) => {
    const { matchId } = data;
    
    const match = matches.get(matchId);
    if (!match) return;

    const player = players.get(socket.id);
    if (!player) return;

    // Determine winner (opponent)
    const winner = player.color === 'white' ? 'black' : 'white';
    match.result = { winner, reason: 'resign' };
    match.status = 'finished';

    // Notify both players
    const whitePlayer = Array.from(players.values()).find(p => p.playerId === match.players.white);
    const blackPlayer = Array.from(players.values()).find(p => p.playerId === match.players.black);

    if (whitePlayer) {
      io.to(whitePlayer.socketId).emit('game_over', match.result);
    }
    if (blackPlayer) {
      io.to(blackPlayer.socketId).emit('game_over', match.result);
    }

    // Clean up
    matches.delete(matchId);
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
    
    const player = players.get(socket.id);
    if (player) {
      // Remove from queue
      const queueIndex = queue.indexOf(player.playerId);
      if (queueIndex > -1) {
        queue.splice(queueIndex, 1);
      }

      // Find and end any active matches
      for (const [matchId, match] of matches.entries()) {
        if (match.players.white === player.playerId || match.players.black === player.playerId) {
          const winner = match.players.white === player.playerId ? 'black' : 'white';
          match.result = { winner, reason: 'disconnect' };
          match.status = 'finished';

          // Notify opponent
          const opponentId = winner === 'white' ? match.players.white : match.players.black;
          const opponentPlayer = Array.from(players.values()).find(p => p.playerId === opponentId);
          if (opponentPlayer) {
            io.to(opponentPlayer.socketId).emit('game_over', match.result);
          }

          matches.delete(matchId);
        }
      }

      players.delete(socket.id);
    }
  });
});

// Matchmaking logic
function matchPlayers() {
  if (queue.length < 2) return;

  // Get first two players
  const player1Id = queue.shift();
  const player2Id = queue.shift();

  // Random color assignment
  const isPlayer1White = Math.random() < 0.5;
  const whitePlayerId = isPlayer1White ? player1Id : player2Id;
  const blackPlayerId = isPlayer1White ? player2Id : player1Id;

  // Create match
  const matchId = uuidv4();
  const match = new Match(matchId, whitePlayerId, blackPlayerId);
  matches.set(matchId, match);

  // Update players
  const player1 = Array.from(players.values()).find(p => p.playerId === player1Id);
  const player2 = Array.from(players.values()).find(p => p.playerId === player2Id);

  if (!player1 || !player2) {
    console.error('Players not found for matching');
    return;
  }

  player1.color = isPlayer1White ? 'white' : 'black';
  player2.color = isPlayer1White ? 'black' : 'white';

  // Notify both players
  io.to(player1.socketId).emit('match_found', {
    matchId: matchId,
    color: player1.color,
    initialFen: match.fen,
    clock: {
      whiteMs: match.clock.whiteMs,
      blackMs: match.clock.blackMs
    }
  });

  io.to(player2.socketId).emit('match_found', {
    matchId: matchId,
    color: player2.color,
    initialFen: match.fen,
    clock: {
      whiteMs: match.clock.whiteMs,
      blackMs: match.clock.blackMs
    }
  });

  console.log(`Match created: ${matchId} - White: ${whitePlayerId}, Black: ${blackPlayerId}`);
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    matches: matches.size,
    players: players.size,
    queue: queue.length
  });
});

server.listen(PORT, () => {
  console.log(`Chess server running on port ${PORT}`);
});
