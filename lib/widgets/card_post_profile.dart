import 'package:flutter/material.dart';
import 'package:you_can_cook/models/Post.dart';

class CardPostProfile extends StatelessWidget {
  const CardPostProfile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    // Debug dữ liệu pimage
    print('pimage: ${post.pimage}');
    final imageUrl =
        (post.pimage != null && post.pimage!.isNotEmpty)
            ? post.pimage![0]
            : null;
    print('Selected imageUrl: $imageUrl');

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child:
                  imageUrl != null
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image load error: $error');
                          return Image.asset(
                            'assets/icons/logo.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      )
                      : Image.asset(
                        'assets/icons/logo.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              post.pcontent ?? 'No description',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "${post.plike ?? 0} thích",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
