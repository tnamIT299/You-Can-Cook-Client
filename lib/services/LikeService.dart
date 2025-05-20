import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/models/Like.dart';

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
        try {
          await _client.from('likes').insert({
            'uid': userId,
            'pid': postId,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          if (e.toString().contains('duplicate key value')) {
            // Like đã tồn tại, bỏ qua lỗi và kiểm tra lại trạng thái
            if (await hasLiked(userId, postId)) {
              return; // Like đã tồn tại, không cần thêm thông báo
            }
            throw Exception('Failed to insert like: $e');
          }
          throw Exception('Failed to insert like: $e');
        }

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
          .select('id, uid, pid, created_at, users!uid(nickname, name, avatar)')
          .eq('pid', postId);

      return response.map((liker) {
        final user = liker['users'] as Map<String, dynamic>;
        return {
          'like': Like(
            id: liker['id'] as int,
            uid: liker['uid'] as int,
            pid: liker['pid'] as int,
            created_at: DateTime.parse(liker['created_at'] as String),
          ),
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

  //reel
  /// Kiểm tra xem người dùng đã thích video chưa
  Future<bool> hasReelLiked(int userId, int reelId) async {
    try {
      final response =
          await _client
              .from('reel_likes')
              .select()
              .eq('uid', userId)
              .eq('reel_id', reelId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Không thể kiểm tra trạng thái thích: $e');
    }
  }

  /// Thêm hoặc xóa lượt thích cho video
  Future<void> toggleReelLike(
    int userId,
    int reelId,
    int reelOwnerId,
    bool isLiked,
  ) async {
    try {
      if (isLiked) {
        // Xóa lượt thích
        await _client
            .from('reel_likes')
            .delete()
            .eq('uid', userId)
            .eq('reel_id', reelId);

        // Giảm số lượng lượt thích trong bảng reels
        await _client
            .from('reels')
            .update({'reelLike': (await getReelLikeCount(reelId))})
            .eq('reel_id', reelId);
      } else {
        // Thêm lượt thích
        await _client.from('reel_likes').insert({
          'uid': userId,
          'reel_id': reelId,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Tăng số lượng lượt thích trong bảng reels
        await _client
            .from('reels')
            .update({'reelLike': (await getReelLikeCount(reelId))})
            .eq('reel_id', reelId);

        // Gửi thông báo cho chủ video (nếu không phải chính họ)
        if (reelOwnerId != userId) {
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

          await _client.from('notifications').insert({
            'receiver_uid': reelOwnerId,
            'sender_uid': userId,
            'type': 'reel_like',
            'reelId': reelId,
            'content': '$likerName đã thích video của bạn',
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw Exception('Không thể thay đổi trạng thái thích: $e');
    }
  }

  /// Lấy số lượng lượt thích của video
  Future<int> getReelLikeCount(int reelId) async {
    try {
      final response = await _client
          .from('reel_likes')
          .select('id')
          .eq('reel_id', reelId)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      throw Exception('Không thể lấy số lượng lượt thích: $e');
    }
  }

  /// Lấy danh sách người đã thích video
  Future<List<Map<String, dynamic>>> getReelLikers(
    int reelId, {
    int? currentUserId,
  }) async {
    try {
      final response = await _client
          .from('reel_likes')
          .select(
            'id, uid, reel_id, created_at, users!uid(nickname, name, avatar)',
          )
          .eq('reel_id', reelId);

      return response.map((liker) {
        final user = liker['users'] as Map<String, dynamic>;
        return {
          'id': liker['id'] as int,
          'uid': liker['uid'] as int,
          'reel_id': liker['reel_id'] as int,
          'created_at': DateTime.parse(liker['created_at'] as String),
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
      throw Exception('Không thể lấy danh sách người thích: $e');
    }
  }

  // Lắng nghe thay đổi số lượng lượt thích theo thời gian thực
  Stream<int> listenToReelLikeCount(int reelId) {
    return _client
        .from('reel_likes')
        .stream(primaryKey: ['id'])
        .map((event) => event.where((e) => e['reel_id'] == reelId).length);
  }
}
