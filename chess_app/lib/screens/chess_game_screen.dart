import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import '../models/game_models.dart';
import '../services/socket_service.dart';
import 'dart:async';

class ChessGameScreen extends StatefulWidget {
  final GameMode gameMode;

  const ChessGameScreen({Key? key, required this.gameMode}) : super(key: key);

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  final SocketService _socketService = SocketService();
  ChessBoardController? _chessBoardController;
  
  MatchState? _currentMatch;
  bool _isSearching = false;
  String _statusMessage = 'Ready to play';
  Timer? _clockTimer;
  int _whiteTimeMs = 0;
  int _blackTimeMs = 0;

  @override
  void initState() {
    super.initState();
    _chessBoardController = ChessBoardController();
    _initializeSocket();
  }

  void _initializeSocket() {
    // Connect to server (replace with your server URL)
    _socketService.connect('http://localhost:3000');

    // Listen for connection
    _socketService.onConnection.listen((connected) {
      if (mounted) {
        setState(() {
          if (connected) {
            _statusMessage = 'Connected to server';
          } else {
            _statusMessage = 'Disconnected';
            _isSearching = false;
          }
        });
      }
    });

    // Listen for match found
    _socketService.onMatchFound.listen((data) {
      if (mounted) {
        setState(() {
          _currentMatch = MatchState.fromJson(data);
          _whiteTimeMs = _currentMatch!.clock.whiteMs;
          _blackTimeMs = _currentMatch!.clock.blackMs;
          _isSearching = false;
          _statusMessage = 'Match found! You are ${_currentMatch!.playerColor}';
          _startClock();
        });
      }
    });

    // Listen for move results
    _socketService.onMoveResult.listen((data) {
      if (mounted) {
        final fen = data['fen'] as String;
        final turn = data['turn'] as String;
        final clock = ClockState.fromJson(data['clock']);
        
        setState(() {
          _chessBoardController!.loadFen(fen);
          _whiteTimeMs = clock.whiteMs;
          _blackTimeMs = clock.blackMs;
          _currentMatch = MatchState(
            matchId: _currentMatch!.matchId,
            playerColor: _currentMatch!.playerColor,
            fen: fen,
            turn: turn,
            clock: clock,
            status: 'active',
          );
          _statusMessage = turn == _currentMatch!.playerColor ? 'Your turn' : 'Opponent\'s turn';
        });
      }
    });

    // Listen for illegal moves
    _socketService.onIllegalMove.listen((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['reason'] ?? 'Illegal move'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Listen for game over
    _socketService.onGameOver.listen((data) {
      if (mounted) {
        _clockTimer?.cancel();
        final result = GameResult.fromJson(data);
        setState(() {
          _statusMessage = result.getDisplayText();
        });
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2a1515),
            title: const Text(
              'Game Over',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              result.getDisplayText(),
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _findMatch();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentMatch == null || _currentMatch!.status != 'active') {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentMatch!.turn == 'white') {
          _whiteTimeMs = (_whiteTimeMs - 100).clamp(0, double.infinity).toInt();
        } else {
          _blackTimeMs = (_blackTimeMs - 100).clamp(0, double.infinity).toInt();
        }
      });
    });
  }

  void _findMatch() {
    if (!_socketService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not connected to server'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _statusMessage = 'Searching for opponent...';
    });
    
    _socketService.joinQueue();
  }

  void _onMove(ShortMove move) {
    if (_currentMatch == null) {
      return;
    }

    if (_currentMatch!.turn != _currentMatch!.playerColor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not your turn!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _socketService.makeMove(
      matchId: _currentMatch!.matchId,
      from: move.from,
      to: move.to,
      promotion: move.promotion?.name,
    );
  }

  void _resign() {
    if (_currentMatch == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a1515),
        title: const Text('Resign?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to resign?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _socketService.resign(_currentMatch!.matchId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int ms) {
    final seconds = (ms / 1000).floor();
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameMode.name),
        backgroundColor: const Color(0xFF4a1a1a),
        actions: [
          if (_currentMatch != null)
            IconButton(
              icon: const Icon(Icons.flag),
              onPressed: _resign,
              tooltip: 'Resign',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4a1a1a), Color(0xFF1a0a0a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStatusBar(),
              const SizedBox(height: 10),
              if (_currentMatch != null) _buildOpponentClock(),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: _currentMatch != null
                      ? _buildChessBoard()
                      : _buildSearchingView(),
                ),
              ),
              const SizedBox(height: 10),
              if (_currentMatch != null) _buildPlayerClock(),
              const SizedBox(height: 10),
              if (_currentMatch == null && !_isSearching) _buildPlayButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[700]!, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _socketService.isConnected ? Icons.wifi : Icons.wifi_off,
            color: _socketService.isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentClock() {
    final isOpponentTurn = _currentMatch!.turn != _currentMatch!.playerColor;
    final opponentColor = _currentMatch!.playerColor == 'white' ? 'black' : 'white';
    final timeMs = opponentColor == 'white' ? _whiteTimeMs : _blackTimeMs;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isOpponentTurn ? Colors.green[800] : const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpponentTurn ? Colors.green : Colors.brown[700]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: opponentColor == 'white' ? Colors.white : Colors.black,
            size: 30,
          ),
          const SizedBox(width: 12),
          Text(
            'Opponent (${opponentColor == 'white' ? 'White' : 'Black'})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(timeMs),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerClock() {
    final isPlayerTurn = _currentMatch!.turn == _currentMatch!.playerColor;
    final playerColor = _currentMatch!.playerColor!;
    final timeMs = playerColor == 'white' ? _whiteTimeMs : _blackTimeMs;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isPlayerTurn ? Colors.green[800] : const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlayerTurn ? Colors.green : Colors.brown[700]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: playerColor == 'white' ? Colors.white : Colors.black,
            size: 30,
          ),
          const SizedBox(width: 12),
          Text(
            'You (${playerColor == 'white' ? 'White' : 'Black'})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            _formatTime(timeMs),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChessBoard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[700]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ChessBoard(
          controller: _chessBoardController!,
          boardColor: BoardColor.brown,
          boardOrientation: _currentMatch!.playerColor == 'white'
              ? PlayerColor.white
              : PlayerColor.black,
          onMove: _onMove,
        ),
      ),
    );
  }

  Widget _buildSearchingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isSearching)
          const CircularProgressIndicator(
            color: Colors.amber,
          ),
        const SizedBox(height: 20),
        Text(
          _isSearching ? 'Finding opponent...' : 'Ready to play ${widget.gameMode.timeControl}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _findMatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'FIND MATCH',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
