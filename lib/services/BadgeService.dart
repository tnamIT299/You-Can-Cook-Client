import 'package:supabase/supabase.dart';
import 'package:you_can_cook/models/Badges.dart';
import 'package:you_can_cook/db/db.dart' as db;

class BadgeService {
  final SupabaseClient _client;

  BadgeService() : _client = db.supabaseClient;

  // Lấy danh sách huy hiệu từ bảng badges
  Future<List<Badge>> fetchBadges() async {
    try {
      final response = await _client
          .from('badges')
          .select()
          .order('points_required', ascending: true);

      return (response as List<dynamic>).map((badge) {
        return Badge(
          id: badge['id'] as int,
          name: badge['name'] as String,
          imagePath: badge['imagePath'] as String,
          milestone: badge['milestone'] as String,
        );
      }).toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch badges: $e');
    }
  }
}
