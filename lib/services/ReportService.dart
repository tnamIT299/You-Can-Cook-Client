import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> reportUser({
    required String reportedUid,
    required String reporterUid,
    required String content,
    String? pid,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Vui lòng đăng nhập để báo cáo');
      }

      await _supabase.from('userReport').insert({
        'reporter_id': reporterUid,
        'reported_id': reportedUid,
        'content': content,
        'pid': pid,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Không thể gửi báo cáo: $e');
    }
  }
}
