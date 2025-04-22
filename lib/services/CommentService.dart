import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/Comment.dart';

class CommentService {
  final SupabaseClient supabaseClient;

  CommentService(this.supabaseClient);

  Future<void> addComment({
    required int userId,
    required int postId,
    required String content,
  }) async {
    try {
      // Thêm bình luận vào bảng comments và lấy thông tin bình luận vừa tạo
      final commentResponse =
          await supabaseClient
              .from('comments')
              .insert({
                'uid': userId,
                'pid': postId,
                'content': content,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      // Lấy thông tin bài viết để tìm chủ bài viết
      final postResponse =
          await supabaseClient
              .from('posts')
              .select('uid')
              .eq('pid', postId)
              .single();

      // Lấy thông tin người bình luận
      final actorResponse =
          await supabaseClient
              .from('users')
              .select('name, nickname')
              .eq('uid', userId)
              .single();

      // Tạo thông báo cho chủ bài viết nếu người bình luận không phải là họ
      if (postResponse['uid'] != userId) {
        await supabaseClient.from('notifications').insert({
          'receiver_uid': postResponse['uid'],
          'sender_uid': userId,
          'type': 'comment',
          'pid': postId,
          'content':
              '${actorResponse['nickname'] ?? actorResponse['name']} đã bình luận trên bài viết của bạn:  "${content.length > 50 ? '${content.substring(0, 50)}...' : content}"',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await supabaseClient
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId);

      await supabaseClient.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<Comment> updateComment(int commentId, String newContent) async {
    try {
      final response =
          await supabaseClient
              .from('comments')
              .update({'content': newContent})
              .eq('id', commentId)
              .select('*, users(name, nickname, avatar)')
              .single();
      return Comment.fromMap(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bình luận: $e');
    }
  }

  // Sửa phần này trong CommentService.dart
  Future<List<Comment>> getCommentsByPostId(
    int postId, {
    int limit = 8,
    int offset = 0,
    int? currentUserId,
  }) async {
    try {
      // Nếu đã đăng nhập, lấy cả trạng thái thích
      if (currentUserId != null && currentUserId > 0) {
        final response = await supabaseClient
            .from('comments')
            .select('''
          *,
          users!uid(avatar, nickname, name, uid),
          like_count:comment_likes(count),
          user_likes:comment_likes!left(id, user_id).eq(user_id, $currentUserId)
        ''')
            .eq('pid', postId)
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);

        return List<Comment>.from(
          response.map((comment) {
            final likeCount =
                (comment['like_count'] as List<dynamic>?)?.isNotEmpty == true
                    ? (comment['like_count'][0]['count'] as int?) ?? 0
                    : 0;
            final userLikes = comment['user_likes'] as List<dynamic>?;
            bool isLiked = false;

            if (userLikes != null && userLikes.isNotEmpty) {
              for (var like in userLikes) {
                if (like['user_id'] == currentUserId) {
                  isLiked = true;
                  break;
                }
              }
            }
            return Comment.fromMap({
              ...comment,
              'like_count': likeCount,
              'is_liked': isLiked,
            });
          }),
        );
      } else {}
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
    // Ensure a return or throw statement at the end
    throw Exception('Unexpected error: No comments fetched.');
  }

  Future<void> updatePostCommentCount(
    int postId, {
    required bool increment,
  }) async {
    try {
      final response =
          await supabaseClient
              .from('posts')
              .select('pcomment')
              .eq('pid', postId)
              .single();
      final currentCount = (response['pcomment'] ?? 0) as int;
      final newCount = increment ? currentCount + 1 : currentCount - 1;
      await supabaseClient
          .from('posts')
          .update({'pcomment': newCount.clamp(0, double.infinity).toInt()})
          .eq('pid', postId);
    } catch (e) {
      throw Exception('Failed to update comment count: $e');
    }
  }

  // Phương thức thích bình luận
  Future<int> likeComment(int commentId, int userId) async {
    try {
      // Kiểm tra xem đã thích chưa
      final existingLike = await supabaseClient
          .from('comment_likes')
          .select()
          .eq('comment_id', commentId)
          .eq('user_id', userId);

      // Nếu chưa thích, thêm vào bảng comment_likes
      if (existingLike.isEmpty) {
        await supabaseClient.from('comment_likes').insert({
          'comment_id': commentId,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Đếm lại số lượng like chính xác
      final countResult = await supabaseClient
          .from('comment_likes')
          .select('count')
          .eq('comment_id', commentId);

      final int actualCount = countResult[0]['count'];

      // Cập nhật like_count trong bảng comments
      await supabaseClient
          .from('comments')
          .update({'like_count': actualCount})
          .eq('id', commentId);

      return actualCount;
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  // Phương thức bỏ thích bình luận
  Future<int> unlikeComment(int commentId, int userId) async {
    try {
      await supabaseClient
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', userId);

      // Đếm lại số lượng like chính xác
      final countResult = await supabaseClient
          .from('comment_likes')
          .select('count')
          .eq('comment_id', commentId);

      final int actualCount = countResult[0]['count'] ?? 0;

      // Cập nhật like_count trong bảng comments
      await supabaseClient
          .from('comments')
          .update({'like_count': actualCount})
          .eq('id', commentId);

      return actualCount;
    } catch (e) {
      throw Exception('Failed to unlike comment: $e');
    }
  }
}
