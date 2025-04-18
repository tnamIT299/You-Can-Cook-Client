import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CardPhotoProfile extends StatelessWidget {
  const CardPhotoProfile({
    super.key,
    required this.photos,
    required this.onDeletePhoto,
    required this.isOwnProfile, // Thêm tham số này
  });

  final List<String> photos;
  final Function(String) onDeletePhoto;
  final bool isOwnProfile;

  // Hàm hiển thị ảnh lớn trong dialog với tùy chọn xóa
  void _showFullImage(BuildContext context, String photoUrl, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Ảnh'),
                backgroundColor: Colors.white,
                actions: [
                  // Chỉ hiển thị nút xóa nếu là profile của chính người dùng
                  if (isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Hiện dialog xác nhận trước khi xóa
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Xóa ảnh'),
                                content: const Text(
                                  'Bạn có chắc muốn xóa ảnh này không?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Đóng dialog
                                      Navigator.pop(context);
                                      // Đóng màn hình xem ảnh
                                      Navigator.pop(context);
                                      // Gọi callback xóa ảnh
                                      onDeletePhoto(photoUrl);
                                    },
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                ],
              ),
              body: InteractiveViewer(
                child: Center(
                  child: Image.network(
                    photoUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Không thể tải ảnh',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),
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
          onTap: () => _showFullImage(context, photos[index], index),
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
