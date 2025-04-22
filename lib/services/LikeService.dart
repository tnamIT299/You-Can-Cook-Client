import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/db/db.dart';

class LikeService {
  final SupabaseClient _client = supabaseClient;

  /// Kiểm tra xem người dùng đã like bài post chưa
  Future<bool> hasLiked(int userId, int postId) async {
    try {
      final response =
          await _client
              .from('likes')
              .select()
              .eq('uid', userId)
              .eq('pid', postId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check like status: $e');
    }
  }

  /// Thêm hoặc xóa like cho bài post
  Future<void> toggleLike(
    int userId,
    int postId,
    int postOwnerId,
    bool isLiked,
  ) async {
    try {
      if (isLiked) {
        // Xóa like
        await _client
            .from('likes')
            .delete()
            .eq('uid', userId)
            .eq('pid', postId);

        // Giảm số lượng like trong bảng posts
        await _client
            .from('posts')
            .update({'plike': (await getLikeCount(postId))})
            .eq('pid', postId);
      } else {
        // Thêm like
        await _client.from('likes').insert({
          'uid': userId,
          'pid': postId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Tăng số lượng like trong bảng posts
        await _client
            .from('posts')
            .update({'plike': (await getLikeCount(postId))})
            .eq('pid', postId);

        // Lấy thông tin người like để tạo nội dung thông báo
        final likerInfo =
            await _client
                .from('users')
                .select('nickname, name')
                .eq('uid', userId)
                .single();

        final likerName =
            likerInfo['nickname']?.isNotEmpty == true
                ? likerInfo['nickname']
                : likerInfo['name'] ?? 'Người dùng';

        if (postOwnerId == userId) {
          return;
        }
        await _client.from('notifications').insert({
          'receiver_uid': postOwnerId,
          'sender_uid': userId,
          'type': 'like',
          'pid': postId,
          'content': '$likerName đã thích bài viết của bạn',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Lấy số lượng like của bài post
  Future<int> getLikeCount(int postId) async {
    try {
      final response = await _client
          .from('likes')
          .select('id')
          .eq('pid', postId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Failed to get like count: $e');
    }
  }

  /// Lắng nghe thay đổi số lượng like theo thời gian thực
  Stream<int> listenToLikeCount(int postId) {
    return _client
        .from('likes')
        .stream(primaryKey: ['id'])
        .map((event) => event.where((e) => e['pid'] == postId).length);
  }

  /// Lắng nghe trạng thái like của người dùng cho bài post
  Stream<int> listenToLikeStatus(int userId, int postId) {
    return _client
        .from('likes')
        .stream(primaryKey: ['id'])
        .map(
          (event) =>
              event
                      .where((e) => e['uid'] == userId && e['pid'] == postId)
                      .isNotEmpty
                  ? 1
                  : 0,
        );
  }

  /// Lấy danh sách người like bài post
  Future<List<Map<String, dynamic>>> getPostLikers(
    int postId, {
    int? currentUserId,
  }) async {
    try {
      final response = await _client
          .from('likes')
          .select('uid, users!uid(nickname, name, avatar)')
          .eq('pid', postId);

      return response.map((liker) {
        final user = liker['users'] as Map<String, dynamic>;
        return {
          'uid': liker['uid'],
          'nickname':
              user['nickname']?.isNotEmpty == true
                  ? user['nickname']
                  : user['name'] ?? 'Người dùng',
          'name': user['name'] ?? 'Người dùng',
          'avatar': user['avatar'],
          'isCurrentUser':
              currentUserId != null && liker['uid'] == currentUserId,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch post likers: $e');
    }
  }
}
