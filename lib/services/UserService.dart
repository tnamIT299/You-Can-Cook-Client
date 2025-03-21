import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/User.dart' as userModel;

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy thông tin người dùng từ Supabase
  Future<userModel.User?> getUserInfo(String email) async {
    final response =
        await _supabase.from('users').select().eq('email', email).single();
    return userModel.User.fromMap(response);
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserInfo(
    String email,
    Map<String, dynamic> updates,
  ) async {
    final response = await _supabase
        .from('users')
        .update(updates)
        .eq('email', email);

    if (response != null) {
      throw Exception('Failed to update user info: $response');
    }
  }

  Future<void> updateUserPoints(int uid, int points) async {
    final response = await _supabase
        .from('users')
        .update({'totalPoint': points})
        .eq('uid', uid);
    if (response != null) {
      throw Exception('Failed to update points: ${response.error!.message}');
    }
  }

  Future<int> getUserPoints(int uid) async {
    final response =
        await _supabase
            .from('users')
            .select('totalPoint')
            .eq('uid', uid)
            .single();
    return response['totalPoint'] ?? 0;
  }

  // Upload avatar lên Supabase Storage
  Future<String> uploadAvatar(String filePath, String userId) async {
    final file = File(filePath);
    final fileName =
        'profile/$userId/${DateTime.now().millisecondsSinceEpoch.toString()}';
    final response = await _supabase.storage
        .from('image')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _supabase.storage.from('image').getPublicUrl(fileName);
    return publicUrl;
  }

  // Lấy danh sách tất cả người dùng
  Future<List<User>> getAllUsers() async {
    final response = await _supabase.from('users').select();
    return List<User>.from(
      response.map((user) => userModel.User.fromMap(user)),
    );
  }
}
