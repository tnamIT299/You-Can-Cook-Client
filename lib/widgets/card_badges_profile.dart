import 'package:flutter/material.dart';
class CardBadgesTab extends StatelessWidget {
  const CardBadgesTab({
    super.key,
    required this.badges,
  });

  final List<Map<String, dynamic>> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                badge["image"]!,
                fit: BoxFit.cover,
                height: 50,
                width: 50,
              ),
              const SizedBox(height: 8),
              Text(
                badge["name"]!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}