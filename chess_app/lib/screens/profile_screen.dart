import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4a1a1a), Color(0xFF1a0a0a)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                _buildStatsSection(context),
                _buildMenuItems(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ChessMaster',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.military_tech, color: Colors.amber, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Rating: 1500',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.edit, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, color: Colors.amber, size: 20),
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
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[700]!, width: 2),
      ),
      child: Column(
        children: [
          _buildStatItem('Total Games', '450', Icons.sports_esports),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Wins', '245', Icons.emoji_events, color: Colors.green),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Losses', '180', Icons.close, color: Colors.red),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Draws', '25', Icons.handshake, color: Colors.grey),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Win Rate', '54.4%', Icons.trending_up, color: Colors.amber),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Best Rating', '1650', Icons.star, color: Colors.amber),
          const Divider(color: Colors.brown, thickness: 1),
          _buildStatItem('Tournament Wins', '3', Icons.emoji_events, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a1515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[700]!, width: 2),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.history, 'Game History'),
          _buildDivider(),
          _buildMenuItem(Icons.emoji_events, 'Achievements'),
          _buildDivider(),
          _buildMenuItem(Icons.auto_graph, 'Statistics'),
          _buildDivider(),
          _buildMenuItem(Icons.school, 'Tutorials'),
          _buildDivider(),
          _buildMenuItem(Icons.payment, 'Payment Methods'),
          _buildDivider(),
          _buildMenuItem(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.brown,
      thickness: 1,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
