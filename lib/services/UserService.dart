import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Lấy thông tin người dùng từ Supabase
  Future<userModel.User?> getUserInfo(String email) async {
    final response =
        await _supabase.from('users').select().eq('email', email).single();
    return userModel.User.fromMap(response);
  }

  // Lấy thông tin người dùng từ Supabase dựa trên userId (uid)
  Future<userModel.User?> getUserInfoById(int userId) async {
    final response =
        await _supabase.from('users').select().eq('uid', userId).single();
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
  }

  Future<void> updateUserPoints(int uid, int points) async {
    final response = await _supabase
        .from('users')
        .update({'totalPoint': points})
        .eq('uid', uid);
    if (response != null) {
      throw Exception('Failed to update points: $response');
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

  Future<void> deleteUserPhoto(String photoUrl) async {
    try {
      // Phân tích URL để tách bucket và path
      final Uri uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;
      final publicIndex = pathSegments.indexOf('public');

      if (publicIndex >= 0 && publicIndex + 1 < pathSegments.length) {
        // Bucket name là phần sau 'public'
        final bucketName = pathSegments[publicIndex + 1];

        // Path là phần còn lại sau bucket name
        final path = pathSegments.sublist(publicIndex + 2).join('/');

        // Xóa file từ storage
        await _supabase.storage.from(bucketName).remove([path]);

        return;
      } else {
        // Xử lý URLs từ các nguồn khác
        final String basePath = _supabase.storage.url;
        if (!photoUrl.startsWith(basePath)) {
          throw Exception('URL is not from Supabase storage');
        }

        // Phân tích URL
        String path = photoUrl.substring(basePath.length);
        if (path.startsWith('/')) {
          path = path.substring(1);
        }

        // Tách bucket và path
        final parts = path.split('/');
        if (parts.length < 2) {
          throw Exception('Invalid storage URL format');
        }

        final bucketName = parts[0];
        final filePath = parts.sublist(1).join('/');
        // Xóa file từ Storage
        await _supabase.storage.from(bucketName).remove([filePath]);
      }
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }

  // Lấy danh sách tất cả người dùng
  Future<List<userModel.User>> getAllUsers() async {
    final response = await _supabase.from('users').select();
    return List<userModel.User>.from(
      response.map((user) => userModel.User.fromMap(user)),
    );
  }

  Future<int?> getCurrentUserUid() async {
    final firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) return null;

    final response =
        await _supabase
            .from('users')
            .select('uid')
            .eq('email', currentUser.email!)
            .maybeSingle();

    return response?['uid'] as int?;
  }

  Future<userModel.User?> getUserByEmail(String email) async {
    final response =
        await _supabase.from('users').select().eq('email', email).maybeSingle();
    print(response);
    return response != null ? userModel.User.fromMap(response) : null;
  }

  // Tăng số lượng follower của user
  Future<void> incrementFollower(int userId) async {
    final response =
        await _supabase
            .from('users')
            .select('follower')
            .eq('uid', userId)
            .single();

    final currentFollower = response['follower'] as int? ?? 0;
    await _supabase
        .from('users')
        .update({'follower': currentFollower + 1})
        .eq('uid', userId);
  }

  // Giảm số lượng follower của user
  Future<void> decrementFollower(int userId) async {
    final response =
        await _supabase
            .from('users')
            .select('follower')
            .eq('uid', userId)
            .single();

    final currentFollower = response['follower'] as int? ?? 0;
    if (currentFollower > 0) {
      await _supabase
          .from('users')
          .update({'follower': currentFollower - 1})
          .eq('uid', userId);
    }
  }

  // Tăng số lượng following của user
  Future<void> incrementFollowing(int userId) async {
    final response =
        await _supabase
            .from('users')
            .select('following')
            .eq('uid', userId)
            .single();

    final currentFollowing = response['following'] as int? ?? 0;
    await _supabase
        .from('users')
        .update({'following': currentFollowing + 1})
        .eq('uid', userId);
  }

  // Giảm số lượng following của user
  Future<void> decrementFollowing(int userId) async {
    final response =
        await _supabase
            .from('users')
            .select('following')
            .eq('uid', userId)
            .single();

    final currentFollowing = response['following'] as int? ?? 0;
    if (currentFollowing > 0) {
      await _supabase
          .from('users')
          .update({'following': currentFollowing - 1})
          .eq('uid', userId);
    }
  }

  Future<List<userModel.User>> get5UserMaxFolllwer() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('follower', ascending: false)
        .limit(5);
    return List<userModel.User>.from(
      response.map((user) => userModel.User.fromMap(user)),
    );
  }

  Future<int> getTotalLikes(int uid) async {
    try {
      // Lấy tổng số lượt like từ bảng posts
      final postResponse = await _supabase
          .from('posts')
          .select('plike')
          .eq('uid', uid);

      int totalPostLikes = 0;
      for (var post in postResponse) {
        totalPostLikes += (post['plike'] as int?) ?? 0;
      }

      // Lấy tổng số lượt like từ bảng reels
      final reelResponse = await _supabase
          .from('reels')
          .select('reelLike')
          .eq('uid', uid);

      int totalReelLikes = 0;
      for (var reel in reelResponse) {
        totalReelLikes += (reel['reelLike'] as int?) ?? 0;
      }

      // Tổng hợp số lượt like
      return totalPostLikes + totalReelLikes;
    } catch (e) {
      throw Exception('Failed to fetch total likes: $e');
    }
  }
}
