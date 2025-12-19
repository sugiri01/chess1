import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // Stream controllers for events
  final _matchFoundController = StreamController<Map<String, dynamic>>.broadcast();
  final _moveResultController = StreamController<Map<String, dynamic>>.broadcast();
  final _illegalMoveController = StreamController<Map<String, dynamic>>.broadcast();
  final _gameOverController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<Map<String, dynamic>> get onMatchFound => _matchFoundController.stream;
  Stream<Map<String, dynamic>> get onMoveResult => _moveResultController.stream;
  Stream<Map<String, dynamic>> get onIllegalMove => _illegalMoveController.stream;
  Stream<Map<String, dynamic>> get onGameOver => _gameOverController.stream;
  Stream<bool> get onConnection => _connectionController.stream;

  bool get isConnected => _isConnected;
  String? currentMatchId;
  String? playerColor;

  void connect(String serverUrl) {
    if (_socket != null && _isConnected) {
      print('Already connected');
      return;
    }

    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to server');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
      _connectionController.add(false);
    });

    // Listen for match found
    _socket!.on('match_found', (data) {
      print('Match found: $data');
      currentMatchId = data['matchId'];
      playerColor = data['color'];
      _matchFoundController.add(data);
    });

    // Listen for move results
    _socket!.on('move_result', (data) {
      print('Move result: $data');
      _moveResultController.add(data);
    });

    // Listen for illegal moves
    _socket!.on('illegal_move', (data) {
      print('Illegal move: $data');
      _illegalMoveController.add(data);
    });

    // Listen for game over
    _socket!.on('game_over', (data) {
      print('Game over: $data');
      _gameOverController.add(data);
    });
  }

  void joinQueue() {
    if (_socket != null && _isConnected) {
      print('Joining queue...');
      _socket!.emit('join_queue', {});
    }
  }

  void makeMove({
    required String matchId,
    required String from,
    required String to,
    String? promotion,
  }) {
    if (_socket != null && _isConnected) {
      final moveData = {
        'matchId': matchId,
        'from': from,
        'to': to,
        if (promotion != null) 'promotion': promotion,
      };
      print('Making move: $moveData');
      _socket!.emit('make_move', moveData);
    }
  }

  void resign(String matchId) {
    if (_socket != null && _isConnected) {
      print('Resigning match: $matchId');
      _socket!.emit('resign', {'matchId': matchId});
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      currentMatchId = null;
      playerColor = null;
    }
  }

  void dispose() {
    _matchFoundController.close();
    _moveResultController.close();
    _illegalMoveController.close();
    _gameOverController.close();
    _connectionController.close();
    disconnect();
  }
}
