import 'package:flutter/material.dart';
import 'package:you_can_cook/models/Badges.dart' as custom_badge;
import 'package:you_can_cook/services/BadgeService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';

class BadgeScreen extends StatelessWidget {
  final BadgeService _badgeService = BadgeService();

  BadgeScreen({super.key});

  Future<List<custom_badge.Badge>> _fetchBadges() async {
    return _badgeService.fetchBadges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kho huy hiệu"),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<List<custom_badge.Badge>>(
        future: _fetchBadges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final List<custom_badge.Badge> badges = snapshot.data ?? [];
          if (badges.isEmpty) {
            return const Center(child: Text("Không có huy hiệu nào."));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return BadgeItem(badge: badge);
              },
            ),
          );
        },
      ),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final custom_badge.Badge badge;

  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Huy hiệu: ${badge.name} - ${badge.milestone}"),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/badges/${badge.imagePath}',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 80, color: Colors.red);
              },
            ),
            const SizedBox(height: 8.0),
            Text(
              badge.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              badge.milestone,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
