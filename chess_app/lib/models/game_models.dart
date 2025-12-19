class GameMode {
  final String id;
  final String name;
  final String timeControl;
  final int whiteTimeMs;
  final int blackTimeMs;
  final String description;

  GameMode({
    required this.id,
    required this.name,
    required this.timeControl,
    required this.whiteTimeMs,
    required this.blackTimeMs,
    required this.description,
  });
}

class MatchState {
  final String matchId;
  final String? playerColor;
  final String fen;
  final String turn;
  final ClockState clock;
  final String status;
  final GameResult? result;

  MatchState({
    required this.matchId,
    this.playerColor,
    required this.fen,
    required this.turn,
    required this.clock,
    required this.status,
    this.result,
  });

  factory MatchState.fromJson(Map<String, dynamic> json) {
    return MatchState(
      matchId: json['matchId'] ?? '',
      playerColor: json['color'],
      fen: json['fen'] ?? json['initialFen'] ?? 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      turn: json['turn'] ?? 'white',
      clock: ClockState.fromJson(json['clock'] ?? {}),
      status: json['status'] ?? 'active',
      result: json['result'] != null ? GameResult.fromJson(json['result']) : null,
    );
  }
}

class ClockState {
  final int whiteMs;
  final int blackMs;

  ClockState({
    required this.whiteMs,
    required this.blackMs,
  });

  factory ClockState.fromJson(Map<String, dynamic> json) {
    return ClockState(
      whiteMs: json['whiteMs'] ?? 300000,
      blackMs: json['blackMs'] ?? 300000,
    );
  }

  String getFormattedTime(String color) {
    final ms = color == 'white' ? whiteMs : blackMs;
    final seconds = (ms / 1000).floor();
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class GameResult {
  final String winner;
  final String reason;

  GameResult({
    required this.winner,
    required this.reason,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      winner: json['winner'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  String getDisplayText() {
    if (winner == 'draw') {
      return 'Draw by $reason';
    }
    final winnerText = winner == 'white' ? 'White' : 'Black';
    return '$winnerText wins by $reason';
  }
}
