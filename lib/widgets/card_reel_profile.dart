import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'dart:convert';
import 'package:you_can_cook/screens/Main/main_tab/reel_tab.dart';

class CardReelProfile extends StatelessWidget {
  final List<Reel> videos;
  final String? currentUserUid;

  const CardReelProfile({
    super.key,
    required this.videos,
    required this.currentUserUid,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Center(child: Text("Chưa có video nào"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.7,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final reel = videos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReelTab(
                      initialVideos: videos.map((r) => r.reelUrl).toList(),
                      initialIndex: index,
                      currentUserUid: reel.uid.toString(),
                    ),
              ),
            );
          },
          child:
              reel.thumbnailUrl != null
                  ? Image.network(
                    reel.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading thumbnail: $error");
                      return const Center(child: Icon(Icons.error));
                    },
                  )
                  : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error),
                        SizedBox(height: 4),
                        Text(
                          "Không có thumbnail",
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
