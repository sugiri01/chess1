import 'package:flutter/material.dart';
import '../models/game_models.dart';
import 'chess_game_screen.dart';
import 'refer_earn_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final List<GameMode> gameModes = const [
    GameMode(
      id: 'bullet',
      name: 'BULLET',
      timeControl: '1+0',
      whiteTimeMs: 60000,
      blackTimeMs: 60000,
      description: '1 minute per side',
    ),
    GameMode(
      id: 'blitz',
      name: 'BLITZ',
      timeControl: '3+0',
      whiteTimeMs: 180000,
      blackTimeMs: 180000,
      description: '3 minutes per side',
    ),
    GameMode(
      id: 'rapid',
      name: 'RAPID',
      timeControl: '5+0',
      whiteTimeMs: 300000,
      blackTimeMs: 300000,
      description: '5 minutes per side',
    ),
    GameMode(
      id: 'classical',
      name: 'CLASSICAL',
      timeControl: '10+0',
      whiteTimeMs: 600000,
      blackTimeMs: 600000,
      description: '10 minutes per side',
    ),
    GameMode(
      id: 'tournaments',
      name: 'TOURNAMENTS',
      timeControl: 'Various',
      whiteTimeMs: 300000,
      blackTimeMs: 300000,
      description: 'Join tournaments',
    ),
    GameMode(
      id: 'practice',
      name: 'PRACTICE',
      timeControl: 'Unlimited',
      whiteTimeMs: 999999000,
      blackTimeMs: 999999000,
      description: 'Practice mode',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4a1a1a),
              Color(0xFF1a0a0a),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              Expanded(
                child: _buildGameModes(context),
              ),
              _buildBottomNav(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ChessMaster',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rating: 1500',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                SizedBox(width: 5),
                Text(
                  '2450',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.orange, size: 30),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGameModes(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: gameModes.asMap().entries.map((entry) {
          final index = entry.key;
          final mode = entry.value;
          return _buildGameCard(
            context,
            mode,
            _getCardColor(index),
            isHot: index == 2,
            isNew: index == 4,
          );
        }).toList(),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      Colors.brown[700]!,
      Colors.green[800]!,
      Colors.red[900]!,
      Colors.blue[900]!,
      Colors.amber[800]!,
      Colors.lightBlue[700]!,
    ];
    return colors[index % colors.length];
  }

  Widget _buildGameCard(
    BuildContext context,
    GameMode mode,
    Color color, {
    bool isHot = false,
    bool isNew = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChessGameScreen(gameMode: mode),
          ),
        );
      },
      child: Container(
        width: 180,
        height: 280,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber[700]!, width: 3),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.castle, size: 60, color: Colors.amber),
                const SizedBox(height: 10),
                Text(
                  mode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    mode.timeControl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mode.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (isHot)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.red],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (isNew)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.people,
            'Referral',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReferEarnScreen()),
              );
            },
          ),
          _buildNavItem(
            context,
            Icons.emoji_events,
            'Missions',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MissionsScreen()),
              );
            },
            badge: '5',
          ),
          _buildNavItem(context, Icons.headset_mic, 'Support', () {}),
          _buildNavItem(context, Icons.mail, 'Messages', () {}),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(icon, color: Colors.white70, size: 28),
              if (badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
