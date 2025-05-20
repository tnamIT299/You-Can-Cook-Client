import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class CardCommentReel extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String? currentUserUid;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;
  final Function(String)? onEdit;

  const CardCommentReel({
    super.key,
    required this.comment,
    this.currentUserUid,
    this.onLike,
    this.onDelete,
    this.onEdit,
  });

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Xóa bình luận',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Xóa bình luận'),
                            content: const Text(
                              'Bạn có chắc chắn muốn xóa bình luận này?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 218, 3, 3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );

                    Navigator.pop(context);

                    if (shouldDelete == true) {
                      onDelete?.call();
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showOptionsMenuReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: const Text(
                    'Báo cáo bình luận',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Mở dialog báo cáo
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController editController = TextEditingController(
      text: comment['content'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa bình luận'),
            content: TextField(
              controller: editController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Nhập bình luận mới...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  if (editController.text.isNotEmpty) {
                    onEdit?.call(editController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(comment['created_at']);
    final relativeTime = timeago.format(createdAt, locale: 'vi');
    final isCommentOwner =
        currentUserUid != null && currentUserUid == comment['uid'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                comment['users']?['avatar'] != null
                    ? NetworkImage(comment['users']?['avatar'])
                    : const AssetImage('assets/icons/logo.png')
                        as ImageProvider,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment['users']?['nickname'] ??
                          comment['users']?['name'] ??
                          'Anonymous',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCommentOwner)
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _showOptionsMenu(context),
                      ),
                    if (!isCommentOwner)
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _showOptionsMenuReport(context),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (comment['content'] != null && comment['content'].isNotEmpty)
                  Text(
                    comment['content'],
                    style: const TextStyle(color: Colors.white),
                  ),
                if (comment['gifURL'] != null && comment['gifURL'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: CachedNetworkImage(
                      imageUrl: comment['gifURL'],
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      relativeTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        comment['isLiked'] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            comment['isLiked'] == true
                                ? Colors.red
                                : Colors.white,
                        size: 20,
                      ),
                      onPressed: onLike,
                    ),
                    Text(
                      '${comment['like_count'] ?? 0}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
