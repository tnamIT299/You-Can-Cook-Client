import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:you_can_cook/services/NotificationService.dart';
import 'package:you_can_cook/screens/Main/sub_screens/post/detail_post.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/utils/color.dart';
import 'dart:convert';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/models/Notification.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

class NotificationsScreen extends StatefulWidget {
  final int userId; // uid của người dùng
  final SupabaseClient supabaseClient;

  const NotificationsScreen({
    super.key,
    required this.userId,
    required this.supabaseClient,
  });

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationService notificationService;
  List<Map<String, dynamic>>? notifications;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    notificationService = NotificationService(widget.supabaseClient);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final result = await notificationService.getNotifications(widget.userId);

      setState(() {
        notifications = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await notificationService.markAllAsRead(widget.userId);

      setState(() {
        if (notifications != null) {
          for (var i = 0; i < notifications!.length; i++) {
            notifications![i]['is_read'] = true;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    try {
      await notificationService.deleteNotification(notificationId);

      setState(() {
        notifications!.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa thông báo')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: ${e.toString()}')),
      );
    }
  }

  List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      try {
        final decoded = json.decode(value);
        return (decoded is List) ? List<String>.from(decoded) : [value];
      } catch (e) {
        return [value];
      }
    } else if (value is List) {
      return List<String>.from(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Center(
          child: const Text(
            'Thông báo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Source Sans 3',
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.white),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: LoadingScreen())
              : error != null
              ? Center(child: Text('Lỗi: $error'))
              : notifications == null || notifications!.isEmpty
              ? const Center(child: Text('Chưa có thông báo nào'))
              : ListView.builder(
                itemCount: notifications!.length,
                itemBuilder: (context, index) {
                  final notification = notifications![index];
                  return Dismissible(
                    key: Key(notification['id'].toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red[400],
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteNotification(notification['id'].toString(), index);
                    },
                    child: NotificationCard(
                      notification: notification,
                      onTap: () async {
                        if (notification['is_read'] != true) {
                          try {
                            await notificationService.markAsRead(
                              notification['id'].toString(),
                            );
                            setState(() {
                              notification['is_read'] = true;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi khi đánh dấu đã đọc: $e'),
                              ),
                            );
                            return;
                          }
                        }
                        if (notification['type'] == 'follow') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileTab(
                                    userId: notification['sender_uid'],
                                  ),
                            ),
                          );
                        }

                        if (notification['pid'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailPostScreen(
                                    post: Post(
                                      pid: notification['pid'],
                                      pcontent:
                                          notification['post']['pcontent'],
                                      uid: notification['receiver_uid'],
                                      nickname:
                                          notification['receiver']['nickname']
                                                      ?.isNotEmpty ==
                                                  true
                                              ? notification['receiver']['nickname']
                                              : notification['receiver']['name'] ??
                                                  'Người dùng',
                                      avatar:
                                          notification['receiver']['avatar']
                                                      ?.isNotEmpty ==
                                                  true
                                              ? notification['receiver']['avatar']
                                              : null,
                                      plike:
                                          notification['post']['plike']
                                              as int? ??
                                          0,
                                      pcomment:
                                          notification['post']['pcomment']
                                              as int? ??
                                          0,
                                      psave:
                                          notification['post']['psave']
                                              as int? ??
                                          0,
                                      pimage: _parseStringList(
                                        notification['post']['pimage'],
                                      ),
                                      phashtag: _parseStringList(
                                        notification['post']['phashtag'],
                                      ),
                                      createAt:
                                          notification['post']['createAt'] !=
                                                  null
                                              ? DateTime.parse(
                                                notification['post']['createAt'],
                                              )
                                              : null,
                                    ),
                                    currentUserUid: widget.userId.toString(),
                                  ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}

// Widget tùy chỉnh cho thẻ thông báo
class NotificationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    print('NotificationCard: onTapDown');
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    print('NotificationCard: onTapUp');
    setState(() {
      _isPressed = false;
    });
    widget.onTap();
  }

  void _onTapCancel() {
    print('NotificationCard: onTapCancel');
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRead = widget.notification['is_read'] == true;
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Đảm bảo nhận sự kiện nhấn
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRead ? Colors.transparent : Colors.blue[300]!,
                      width: isRead ? 0 : 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        widget.notification['actor']['avatar']?.isNotEmpty ==
                                true
                            ? NetworkImage(
                              widget.notification['actor']['avatar'],
                            )
                            : const AssetImage('assets/icons/logo.png')
                                as ImageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                // Nội dung và thời gian
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notification['content'] ?? 'Không có nội dung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(
                          DateTime.parse(widget.notification['created_at']),
                          locale: 'vi',
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Trạng thái đọc
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 8, left: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRead ? Colors.transparent : Colors.blue,
                    border: Border.all(
                      color: isRead ? Colors.grey[400]! : Colors.blue,
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
