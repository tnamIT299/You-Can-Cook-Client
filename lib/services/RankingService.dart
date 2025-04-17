import 'package:supabase/supabase.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/db/db.dart' as db;

class RankingService {
  final SupabaseClient _client;

  RankingService() : _client = db.supabaseClient;

  Future<List<userModel.User>> getRankedUsers() async {
    try {
      final response = await _client
          .from('users')
          .select('uid, email, name, nickname, avatar, totalPoint')
          .order('totalPoint', ascending: false);

      return (response as List<dynamic>).map((user) {
        return userModel.User(
          email: user['email'] as String? ?? '',
          uid: user['uid'] as int,
          name: user['name'] as String? ?? '',
          nickname: user['nickname'] as String? ?? '',
          avatar: user['avatar'] as String?,
          totalPoint: user['totalPoint'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch ranked users: $e');
    }
  }
}
