import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationService {
  /// Lấy lịch sử cuộc hội thoại từ Supabase
  Future<List<Map<String, dynamic>>> fetchChatHistory(String uid) async {
    try {
      final response = await Supabase.instance.client
          .from('ai_conversation') // Sửa tên bảng nếu cần
          .select('id, title, created_at')
          .eq('uid', uid)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (item) => {
              'id': item['id'].toString(),
              'question': item['title'],
              'timestamp': DateTime.parse(item['created_at']),
            },
          )
          .toList();
    } catch (e) {
      print('Lỗi khi lấy lịch sử hội thoại: $e');
      return [];
    }
  }

  /// Tạo cuộc hội thoại mới và lưu tin nhắn
  Future<String?> createNewConversation(String uid, String question) async {
    try {
      // Tạo cuộc hội thoại mới, không gửi created_at
      final conversationResponse =
          await Supabase.instance.client
              .from('ai_conversation')
              .insert({
                'uid': uid,
                'title': question,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final conversationId = conversationResponse['id'].toString();

      // Lưu tin nhắn của người dùng dưới dạng jsonb
      await Supabase.instance.client.from('messages').insert({
        'conversation_id': conversationId,
        'sender': 'user',
        'content': {'text': question},
        'created_at': DateTime.now().toIso8601String(),
      });

      return conversationId;
    } catch (e) {
      print('Lỗi khi tạo hội thoại: $e');
      return null;
    }
  }

  /// Thêm một tin nhắn vào cuộc hội thoại
  Future<void> addMessage(
    String conversationId,
    String sender,
    Map<String, dynamic> content,
    DateTime createdAt,
  ) async {
    try {
      await Supabase.instance.client.from('messages').insert({
        'conversation_id': conversationId,
        'sender': sender,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      });
    } catch (e) {
      print('Lỗi khi thêm tin nhắn: $e');
    }
  }

  /// Tải tin nhắn của một cuộc hội thoại
  Future<List<Map<String, dynamic>>> loadConversation(
    String conversationId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select('sender, content, created_at')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return (response as List)
          .map(
            (item) => {
              'sender': item['sender'],
              'content': item['content'],
              'timestamp': DateTime.parse(item['created_at']),
            },
          )
          .toList();
    } catch (e) {
      print('Lỗi khi tải hội thoại: $e');
      return [];
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await Supabase.instance.client
          .from('messages')
          .delete()
          .eq('conversation_id', conversationId);

      await Supabase.instance.client
          .from('ai_conversation')
          .delete()
          .eq('id', conversationId);
    } catch (e) {
      print('Lỗi khi xóa hội thoại: $e');
    }
  }

  Future<void> updateConversationTitle(
    String conversationId,
    String newTitle,
  ) async {
    try {
      await Supabase.instance.client
          .from('ai_conversation')
          .update({'title': newTitle})
          .eq('id', conversationId);
    } catch (e) {
      print('Lỗi khi cập nhật tiêu đề hội thoại: $e');
      rethrow;
    }
  }
}
