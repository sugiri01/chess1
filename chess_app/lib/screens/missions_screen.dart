import 'package:flutter/material.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.brown[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 5),
                  Text('₹23.49', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4a1a1a),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber, size: 18),
                SizedBox(width: 5),
                Text('2450', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
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
        child: Column(
          children: [
            _buildTabs(),
            Expanded(
              child: _buildMissionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTab('Daily', 0, '2'),
          const SizedBox(width: 8),
          _buildTab('Weekly', 1),
          const SizedBox(width: 8),
          _buildTab('Lifetime', 2, '2'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, [String? badge]) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange[800] : const Color(0xFF2a1515),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: -8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
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
        ),
      ),
    );
  }

  Widget _buildMissionsList() {
    if (_selectedTab == 0) {
      return _buildDailyMissions();
    } else if (_selectedTab == 1) {
      return _buildWeeklyMissions();
    } else {
      return _buildLifetimeMissions();
    }
  }

  Widget _buildDailyMissions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMissionCard(
          reward: '₹1',
          description: 'Login 1 times',
          progress: 1,
          total: 1,
          isCompleted: true,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹3',
          description: 'Play 5 chess games',
          progress: 3,
          total: 5,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹5',
          description: 'Win 3 games today',
          progress: 1,
          total: 3,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹3',
          description: 'Achieve checkmate 3 times',
          progress: 0,
          total: 3,
        ),
      ],
    );
  }

  Widget _buildWeeklyMissions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMissionCard(
          reward: '₹10',
          description: 'Play 20 games this week',
          progress: 12,
          total: 20,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹15',
          description: 'Win 10 games this week',
          progress: 5,
          total: 10,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹5',
          description: 'Login 5 days this week',
          progress: 3,
          total: 5,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹20',
          description: 'Invite 2 friends to play',
          progress: 0,
          total: 2,
          isCash: true,
        ),
      ],
    );
  }

  Widget _buildLifetimeMissions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMissionCard(
          reward: '₹50',
          description: 'Win 100 total games',
          progress: 45,
          total: 100,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹100',
          description: 'Play 500 total games',
          progress: 230,
          total: 500,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹25',
          description: 'Reach 1800 rating',
          progress: 1500,
          total: 1800,
        ),
        const SizedBox(height: 12),
        _buildMissionCard(
          reward: '₹75',
          description: 'Win a tournament',
          progress: 0,
          total: 1,
        ),
      ],
    );
  }

  Widget _buildMissionCard({
    required String reward,
    required String description,
    required int progress,
    required int total,
    bool isCompleted = false,
    bool isCash = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.brown[700]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCash ? Colors.green[800] : Colors.brown[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCash ? Icons.currency_rupee : Icons.emoji_events,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            reward,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress / total,
                        backgroundColor: Colors.grey[800],
                        color: Colors.green,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$progress / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isCompleted ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.orange[800] : Colors.green,
              disabledBackgroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              isCompleted ? 'Claim' : 'Go',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
