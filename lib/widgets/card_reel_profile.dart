import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:convert';
import 'package:you_can_cook/screens/Main/main_tab/reel_tab.dart';

class CardReelProfile extends StatelessWidget {
  final List<String> videos;
  final String? currentUserUid;

  const CardReelProfile({super.key, required this.videos, this.currentUserUid});

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
        final videoUrl = videos[index];
        return GestureDetector(
          onTap: () {
            // Điều hướng đến ReelTab và truyền danh sách video cùng index
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReelTab(
                      initialVideos: videos,
                      initialIndex: index,
                      currentUserUid: currentUserUid,
                    ),
              ),
            );
          },
          child: FutureBuilder<String?>(
            future: VideoThumbnail.thumbnailData(
                  video: videoUrl,
                  imageFormat: ImageFormat.PNG,
                  maxHeight: 150,
                  quality: 75,
                )
                .then((data) {
                  if (data == null) {
                    throw Exception(
                      "Không thể tạo thumbnail cho video: $videoUrl",
                    );
                  }
                  return "data:image/png;base64,${base64Encode(data)}";
                })
                .catchError((e) {
                  print("Error generating thumbnail: $e");
                  return null;
                }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error),
                      SizedBox(height: 4),
                      Text(
                        "Không thể tải thumbnail",
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Image.memory(
                base64Decode(snapshot.data!.split(',')[1]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  print("Error displaying thumbnail: $error");
                  return const Center(child: Icon(Icons.error));
                },
              );
            },
          ),
        );
      },
    );
  }
}
