import 'package:flutter/material.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

class CardComment extends StatelessWidget {
  final Map<String, String> comment;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit; // Thêm callback cho hành động chỉnh sửa

  const CardComment({
    super.key,
    required this.comment,
    this.canDelete = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CircleAvatar với GestureDetector không thay đổi
            GestureDetector(
              onTap: () {
                // Chỉ điều hướng khi có userId
                if (comment.containsKey('uid') && comment['uid']!.isNotEmpty) {
                  // Chuyển sang màn hình ProfileTab với userId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfileTab(
                            userId: int.tryParse(comment['uid']!) ?? 0,
                          ),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    comment['avatar']!.isNotEmpty
                        ? NetworkImage(comment['avatar']!)
                        : const AssetImage("assets/icons/logo.png")
                            as ImageProvider,
              ),
            ),
            const SizedBox(width: 8),
            // Phần còn lại của CardComment
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bọc Text trong Flexible để giới hạn chiều rộng
                      Flexible(
                        child: Text(
                          comment['nickname']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      // Thêm SizedBox để đảm bảo khoảng cách giữa text và icon
                      const SizedBox(width: 8),
                      // IconButton không thay đổi
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            _showOptionsModal(context);
                          },
                          constraints: const BoxConstraints(
                            minWidth: 40,
                          ), // Đảm bảo kích thước tối thiểu
                        ),
                    ],
                  ),
                  Text(
                    comment['content']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment['time']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị modal tùy chọn
  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Chỉnh sửa bình luận'),
                onTap: () {
                  Navigator.pop(context);
                  if (onEdit != null) {
                    onEdit!(); // Không truyền nội dung vì sẽ lấy từ DetailPostScreen
                  }
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Xóa bình luận',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (onDelete != null) {
                    onDelete!();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
