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
        final response = await _client
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
        final response = await _client.from('followers').insert({
          'follower_id': followerId,
          'following_id': followingId,
        });

        // Tăng số lượng follower của người được theo dõi
        await _userService.incrementFollower(followingId);
        // Tăng số lượng following của người theo dõi
        await _userService.incrementFollowing(followerId);
      }
    } catch (e) {
      throw Exception('Failed to toggle follow status: $e');
    }
  }
}
