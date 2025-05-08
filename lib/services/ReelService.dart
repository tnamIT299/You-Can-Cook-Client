import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'package:path_provider/path_provider.dart';

class ReelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all reels from Supabase
  Future<List<Reel>> fetchReels() async {
    final response = await _supabase
        .from('reels')
        .select('*, users(nickname, avatar, name)')
        .order('createAt', ascending: false);
    print(response);

    return response.map((data) => Reel.fromMap(data)).toList();
  }

  // Fetch filtered reels based on reelRange and followers
  Future<List<Reel>> fetchFilteredReels(int currentUserUid) async {
    try {
      // Bước 1: Lấy danh sách người mà người dùng hiện tại đang theo dõi
      final followingResponse = await _supabase
          .from('followers')
          .select('following_id')
          .eq('follower_id', currentUserUid);

      List<int> followingIds =
          (followingResponse as List<dynamic>)
              .map((item) => item['following_id'] as int)
              .toList();

      // Bước 2: Truy vấn reel theo các tiêu chí
      final response = await _supabase
          .from('reels')
          .select('*, users(nickname, avatar, name)')
          .or(
            'reelRange.eq.Công khai,uid.eq.$currentUserUid${followingIds.isNotEmpty ? ',uid.in.(${followingIds.join(',')})' : ''}',
          ) // Lọc reel: Công khai, của chính người dùng, hoặc của người đang theo dõi
          .order(
            'createAt',
            ascending: false,
          ); // Sắp xếp theo thời gian mới nhất

      return (response as List<dynamic>)
          .map((reel) => Reel.fromMap(reel))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch filtered reels: $e');
    }
  }

  Future<List<Reel>> fetchVideosByUid(int uid) async {
    try {
      // Lấy danh sách Reel từ bảng reels dựa trên uid
      final response = await _supabase
          .from('reels')
          .select('*, users(nickname, avatar, name)')
          .eq('uid', uid)
          .order('createAt', ascending: false);

      return (response as List<dynamic>)
          .map((reel) => Reel.fromMap(reel))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  Future<List<Reel>> fetchReelsByUrls(
    List<String> videoUrls, {
    int limit = 5,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('reels')
          .select('*, users(nickname, avatar, name)')
          .inFilter('reelUrl', videoUrls)
          .range(offset, offset + limit - 1)
          .order('createAt', ascending: false);

      return (response as List<dynamic>)
          .map((reel) => Reel.fromMap(reel))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reels by URLs: $e');
    }
  }

  // Upload a new reel to Supabase
  Future<void> uploadReel(Reel reel, String videoPath) async {
    final userId = reel.uid.toString();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';

    // Upload video to Supabase bucket
    await _supabase.storage
        .from('reel')
        .upload('$userId/$fileName', File(videoPath));

    // Get the public URL of the uploaded video
    final reelUrl = _supabase.storage
        .from('reel')
        .getPublicUrl('$userId/$fileName');

    // Tạo thumbnail từ video
    final thumbnailData = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      maxHeight: 150,
      quality: 75,
    );

    String? thumbnailUrl;
    if (thumbnailData != null) {
      final thumbnailFileName =
          '${DateTime.now().millisecondsSinceEpoch}_thumb.png';
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File('${tempDir.path}/$thumbnailFileName');
      await thumbnailFile.writeAsBytes(thumbnailData);
      await _supabase.storage
          .from('reel-thumbnails')
          .upload('$userId/$thumbnailFileName', thumbnailFile);
      thumbnailUrl = _supabase.storage
          .from('reel-thumbnails')
          .getPublicUrl('$userId/$thumbnailFileName');
      // Xóa file tạm thời sau khi upload
      await thumbnailFile.delete();
    }
    // Save reel metadata to the database
    await _supabase.from('reels').insert({
      'uid': reel.uid,
      'reelContent': reel.reelContent,
      'reelUrl': reelUrl,
      'thumbnailUrl': thumbnailUrl,
      'reelHashtag': reel.reelHashtag,
      'reelLike': 0,
      'reelComment': 0,
      'reelSave': 0,
      'reelRange': reel.reelRange,
      'createAt': DateTime.now().toIso8601String(),
      'isWarning': false,
    });
  }

  // Update like count
  Future<void> updateLike(int reelId, bool isLiked) async {
    final reel =
        await _supabase
            .from('reels')
            .select('reelLike')
            .eq('reel_id', reelId)
            .single();

    final newLikeCount = (reel['reelLike'] ?? 0) + (isLiked ? 1 : -1);
    await _supabase
        .from('reels')
        .update({'reelLike': newLikeCount})
        .eq('reel_id', reelId);
  }

  // Update save count
  Future<void> updateSave(int reelId, bool isSaved) async {
    final reel =
        await _supabase
            .from('reels')
            .select('reelSave')
            .eq('reel_id', reelId)
            .single();

    final newSaveCount = (reel['reelSave'] ?? 0) + (isSaved ? 1 : -1);
    await _supabase
        .from('reels')
        .update({'reelSave': newSaveCount})
        .eq('reel_id', reelId);
  }

  // Update reel privacy (reelRange)
  Future<void> updateReelPrivacy(int reelId, String newPrivacy) async {
    try {
      await _supabase
          .from('reels')
          .update({'reelRange': newPrivacy})
          .eq('reel_id', reelId);
    } catch (e) {
      throw Exception('Failed to update reel privacy: $e');
    }
  }

  // Delete a reel from both the database and storage
  Future<void> deleteReel(int reelId, int uid) async {
    try {
      // Lấy thông tin reel để biết đường dẫn video trong bucket
      final reel =
          await _supabase
              .from('reels')
              .select('reelUrl')
              .eq('reel_id', reelId)
              .single();

      // Xóa video trong bucket
      final reelUrl = reel['reelUrl'] as String;
      // Phân tích reelUrl để lấy tên file (phần cuối của URL)
      final fileName = reelUrl.split('/').last;
      final userId = uid.toString();
      await _supabase.storage.from('reel').remove(['$userId/$fileName']);

      // Xóa dữ liệu trong bảng reels
      await _supabase.from('reels').delete().eq('reel_id', reelId);
    } catch (e) {
      throw Exception('Failed to delete reel: $e');
    }
  }
}
