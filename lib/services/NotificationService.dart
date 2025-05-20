import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/Notification.dart';

class NotificationService {
  final SupabaseClient supabaseClient;

  NotificationService(this.supabaseClient);

  /// Lấy danh sách thông báo của người dùng dựa trên uid
  Future<List<Map<String, dynamic>>> getNotifications(
    int userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select('''
                id, receiver_uid, sender_uid, type, pid, reelId, content, is_read, created_at, updated_at,
                actor:users!sender_uid(name, nickname, avatar),
                receiver:users!receiver_uid(name, nickname, avatar),
                post:posts!pid(uid, pcontent, pimage, createAt, phashtag, plike, pcomment, psave , post_owner:users!uid(name, nickname, avatar))
                ''')
          .eq('receiver_uid', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Đếm số thông báo chưa đọc của người dùng
  Future<int> getUnreadNotificationCount(int userId) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('receiver_uid', userId)
          .eq('is_read', false)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error fetching unread notification count: $e');
      throw Exception('Failed to fetch unread notification count: $e');
    }
  }

  /// Lắng nghe thay đổi trong bảng notifications theo thời gian thực
  Stream<int> listenToUnreadNotifications(int userId) {
    return supabaseClient
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('receiver_uid', userId)
        .map((event) {
          // Đếm số thông báo chưa đọc từ dữ liệu stream
          return event
              .where((notification) => notification['is_read'] == false)
              .length;
        });
  }

  /// Đánh dấu một thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Đánh dấu tất cả thông báo của người dùng là đã đọc
  Future<void> markAllAsRead(int userId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('receiver_uid', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Xóa một thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}
