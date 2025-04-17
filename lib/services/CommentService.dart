import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/Comment.dart';

class CommentService {
  final SupabaseClient supabaseClient;

  CommentService(this.supabaseClient);

  // Thêm bình luận mới
  Future<void> addComment({
    required int userId,
    required int postId,
    required String content,
  }) async {
    try {
      await supabaseClient.from('comments').insert({
        'uid': userId,
        'pid': postId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Xóa bình luận
  Future<void> deleteComment(int commentId) async {
    try {
      await supabaseClient.from('comments').delete().eq('id', commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Cập nhật bình luận
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
      print(e);
      throw Exception('Lỗi khi cập nhật bình luận: $e');
    }
  }

  // Lấy danh sách bình luận cho một bài đăng
  Future<List<Comment>> getCommentsByPostId(
    int postId, {
    int limit = 8,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from('comments')
          .select('*, users!uid(avatar, nickname, name, uid)')
          .eq('pid', postId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Comment>.from(
        response.map((comment) => Comment.fromMap(comment)),
      );
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  // Cập nhật số lượng bình luận trong bảng posts
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
}
