import 'package:flutter/material.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardComment extends StatelessWidget {
  final Map<String, dynamic> comment;
  final bool canDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLike;

  const CardComment({
    super.key,
    required this.comment,
    this.canDelete = false,
    this.onDelete,
    this.onEdit,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLiked = comment['isLiked'] as bool? ?? false;
    final int likeCount = comment['like_count'] as int? ?? 0;
    final bool isGifComment = comment['gifURL'] != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (comment.containsKey('uid') && comment['uid']!.isNotEmpty) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      const SizedBox(width: 8),
                      if (canDelete)
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            _showOptionsModal(context, isGifComment);
                          },
                          constraints: const BoxConstraints(minWidth: 40),
                        ),
                    ],
                  ),
                  if (isGifComment)
                    CachedNetworkImage(
                      imageUrl: comment['gifURL']!,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                    )
                  else
                    Text(
                      comment['content']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        comment['time']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            onPressed: onLike,
                          ),
                          likeCount >= 1000
                              ? Text(
                                '${(likeCount / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                              : likeCount >= 0
                              ? Text(
                                likeCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsModal(BuildContext context, bool isGifComment) {
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
              if (!isGifComment)
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.primary),
                  title: const Text('Chỉnh sửa bình luận'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onEdit != null) {
                      onEdit!();
                    }
                  },
                ),
              if (!isGifComment) const Divider(height: 0),
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
