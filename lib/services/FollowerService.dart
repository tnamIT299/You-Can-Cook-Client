// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:you_can_cook/db/db.dart';
// import 'package:you_can_cook/services/UserService.dart';

// class FollowerService {
//   final SupabaseClient _client = supabaseClient;
//   final UserService _userService = UserService();

//   // Kiểm tra trạng thái theo dõi
//   Future<bool> checkFollowingStatus(int followerId, int followingId) async {
//     try {
//       final response =
//           await _client
//               .from('followers')
//               .select()
//               .eq('follower_id', followerId)
//               .eq('following_id', followingId)
//               .maybeSingle();

//       return response != null;
//     } catch (e) {
//       throw Exception('Failed to check following status: $e');
//     }
//   }

//   // Theo dõi hoặc hủy theo dõi
//   Future<void> toggleFollow(
//     int followerId,
//     int followingId,
//     bool isFollowing,
//   ) async {
//     try {
//       if (isFollowing) {
//         // Hủy theo dõi
//         final response = await _client
//             .from('followers')
//             .delete()
//             .eq('follower_id', followerId)
//             .eq('following_id', followingId);

//         // Giảm số lượng follower của người bị hủy theo dõi
//         await _userService.decrementFollower(followingId);
//         // Giảm số lượng following của người hủy theo dõi
//         await _userService.decrementFollowing(followerId);
//       } else {
//         // Theo dõi
//         final response = await _client.from('followers').insert({
//           'follower_id': followerId,
//           'following_id': followingId,
//         });

//         // Tăng số lượng follower của người được theo dõi
//         await _userService.incrementFollower(followingId);
//         // Tăng số lượng following của người theo dõi
//         await _userService.incrementFollowing(followerId);
//       }
//     } catch (e) {
//       throw Exception('Failed to toggle follow status: $e');
//     }
//   }

//   //Huỷ theo dõi
//   Future<void> unfollow(int followerId, int followingId) async {
//     try {
//       await _client
//           .from('followers')
//           .delete()
//           .eq('follower_id', followerId)
//           .eq('following_id', followingId);
//       await _userService.decrementFollower(followingId);
//       await _userService.decrementFollowing(followerId);
//     } catch (e) {
//       throw Exception('Failed to unfollow: $e');
//     }
//   }

//   // Lấy danh sách ĐANG THEO DÕI (Following)
//   Future<List<Map<String, dynamic>>> getFollowing(int userId) async {
//     try {
//       final response = await _client
//           .from('followers')
//           .select('following_id')
//           .eq('follower_id', userId);

//       if (response.isEmpty) return [];

//       final followingIds =
//           response.map((e) => e['following_id'] as int).toList();

//       final usersResponse = await _client
//           .from('users')
//           .select('uid, name, nickname, avatar')
//           .inFilter('uid', followingIds);

//       return usersResponse;
//     } catch (e) {
//       throw Exception('Failed to fetch following list: $e');
//     }
//   }

//   // Lấy danh sách NGƯỜI THEO DÕI (Followers)
//   Future<List<Map<String, dynamic>>> getFollowers(int userId) async {
//     try {
//       final response = await _client
//           .from('followers')
//           .select('follower_id')
//           .eq('following_id', userId);

//       if (response.isEmpty) return [];

//       final followerIds = response.map((e) => e['follower_id'] as int).toList();

//       final usersResponse = await _client
//           .from('users')
//           .select('uid, name, nickname, avatar')
//           .inFilter('uid', followerIds);

//       return usersResponse;
//     } catch (e) {
//       throw Exception('Failed to fetch followers list: $e');
//     }
//   }
// }

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/db/db.dart';
import 'package:you_can_cook/services/UserService.dart';

class FollowerService {
  final SupabaseClient _client = supabaseClient;
  final UserService _userService = UserService();

  // Kiểm tra trạng thái theo dõi
  Future<bool> checkFollowingStatus(int followerId, int followingId) async {
    try {
      final response =
          await _client
              .from('followers')
              .select()
              .eq('follower_id', followerId)
              .eq('following_id', followingId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check following status: $e');
    }
  }

  // Theo dõi hoặc hủy theo dõi
  Future<void> toggleFollow(
    int followerId,
    int followingId,
    bool isFollowing,
  ) async {
    try {
      if (isFollowing) {
        // Hủy theo dõi
        await _client
            .from('followers')
            .delete()
            .eq('follower_id', followerId)
            .eq('following_id', followingId);

        // Giảm số lượng follower của người bị hủy theo dõi
        await _userService.decrementFollower(followingId);
        // Giảm số lượng following của người hủy theo dõi
        await _userService.decrementFollowing(followerId);
      } else {
        // Theo dõi
        await _client.from('followers').insert({
          'follower_id': followerId,
          'following_id': followingId,
        });

        // Tăng số lượng follower của người được theo dõi
        await _userService.incrementFollower(followingId);
        // Tăng số lượng following của người theo dõi
        await _userService.incrementFollowing(followerId);

        // Lấy thông tin người theo dõi để tạo nội dung thông báo
        final followerInfo =
            await _client
                .from('users')
                .select('nickname, name')
                .eq('uid', followerId)
                .single();

        final followerName =
            followerInfo['nickname']?.isNotEmpty == true
                ? followerInfo['nickname']
                : followerInfo['name'] ?? 'Người dùng';

        // Chèn thông báo vào bảng notifications
        await _client.from('notifications').insert({
          'receiver_uid': followingId,
          'sender_uid': followerId,
          'type': 'follow',
          'content': '$followerName đã theo dõi bạn',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle follow status: $e');
    }
  }

  // Hủy theo dõi
  Future<void> unfollow(int followerId, int followingId) async {
    try {
      await _client
          .from('followers')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      await _userService.decrementFollower(followingId);
      await _userService.decrementFollowing(followerId);
    } catch (e) {
      throw Exception('Failed to unfollow: $e');
    }
  }

  // Lấy danh sách ĐANG THEO DÕI (Following)
  Future<List<Map<String, dynamic>>> getFollowing(int userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('following_id')
          .eq('follower_id', userId);

      if (response.isEmpty) return [];

      final followingIds =
          response.map((e) => e['following_id'] as int).toList();

      final usersResponse = await _client
          .from('users')
          .select('uid, name, nickname, avatar')
          .inFilter('uid', followingIds);

      return usersResponse;
    } catch (e) {
      throw Exception('Failed to fetch following list: $e');
    }
  }

  // Lấy danh sách NGƯỜI THEO DÕI (Followers)
  Future<List<Map<String, dynamic>>> getFollowers(int userId) async {
    try {
      final response = await _client
          .from('followers')
          .select('follower_id')
          .eq('following_id', userId);

      if (response.isEmpty) return [];

      final followerIds = response.map((e) => e['follower_id'] as int).toList();

      final usersResponse = await _client
          .from('users')
          .select('uid, name, nickname, avatar')
          .inFilter('uid', followerIds);

      return usersResponse;
    } catch (e) {
      throw Exception('Failed to fetch followers list: $e');
    }
  }
}
