import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CardPhotoProfile extends StatelessWidget {
  const CardPhotoProfile({super.key, required this.photos});

  final List<String> photos;

  // Hàm hiển thị ảnh lớn trong dialog
  void _showFullImage(BuildContext context, String photoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Ảnh'),
                backgroundColor: Colors.white,
              ),
              body: InteractiveViewer(
                child: Center(child: Image.network(photoUrl)),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullImage(context, photos[index]),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/icons/logo.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
