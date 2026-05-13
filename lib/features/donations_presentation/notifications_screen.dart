import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildNotifyItem(
            "Donation Accepted",
            "Resala Charity accepted your clothing donation.",
            "2 mins ago",
            Icons.check_circle_outline,
            Colors.green,
          ),
          _buildNotifyItem(
            "AI Analysis Complete",
            "Your item has been categorized as 'Good condition'.",
            "1 hour ago",
            Icons.auto_awesome,
            AppTheme.brown,
          ),
          _buildNotifyItem(
            "New Center Nearby",
            "A new food collection point opened in Nasr City.",
            "Yesterday",
            Icons.location_on_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textBlack, fontFamily: 'Cairo'),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}