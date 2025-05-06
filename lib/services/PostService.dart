import 'package:you_can_cook/models/Post.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:you_can_cook/models/Comment.dart';

class PostService {
  final SupabaseClient _client;

  PostService(this._client);

  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select(
          '*, users!posts_uid_fkey(name, nickname, avatar, uid)',
        ) // Join với bảng users
        .order('createAt', ascending: false); // Sắp xếp theo thời gian mới nhất
    return (response as List<dynamic>)
        .map((post) => Post.fromMap(post))
        .toList();
  }

  Future<List<Post>> getAllPosts() async {
    final response = await _client.from('posts').select();
    return List<Post>.from(response.map((post) => Post.fromMap(post)));
  }

  Future<List<Post>> fetchFilteredPosts(int currentUserUid) async {
    try {
      // Bước 1: Lấy danh sách người mà người dùng hiện tại đang theo dõi
      final followingResponse = await _client
          .from('followers')
          .select('following_id')
          .eq('follower_id', currentUserUid);

      List<int> followingIds =
          (followingResponse as List<dynamic>)
              .map((item) => item['following_id'] as int)
              .toList();

      // Bước 2: Truy vấn bài post theo các tiêu chí
      final response = await _client
          .from('posts')
          .select('*, users!posts_uid_fkey(name, nickname, avatar, uid)')
          .or(
            'prange.eq.Công khai,uid.eq.$currentUserUid${followingIds.isNotEmpty ? ',uid.in.(${followingIds.join(',')})' : ''}',
          ) // Lọc bài post: Công khai, của chính người dùng, hoặc của người đang theo dõi
          .order(
            'createAt',
            ascending: false,
          ); // Sắp xếp theo thời gian mới nhất

      return (response as List<dynamic>)
          .map((post) => Post.fromMap(post))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch filtered posts: $e');
    }
  }

  Future<List<Post>> fetchPostsByUid(int uid) async {
    final response = await _client
        .from('posts')
        .select('*, users(name, nickname, avatar)')
        .eq('uid', uid);
    return (response as List<dynamic>)
        .map((post) => Post.fromMap(post))
        .toList();
  }

  Future<Post> createPost(Post post) async {
    final response = await _client.from('posts').insert(post.toMap()).select();
    if (response.isEmpty) {
      throw Exception('Failed to create post: No data returned');
    }
    return Post.fromMap(response[0]);
  }

  Future<Post> updatePost(Post post) async {
    final response =
        await _client
            .from('posts')
            .update(post.toMap())
            .eq('pid', post.pid as int)
            .select();
    if (response.isEmpty) {
      throw Exception('Failed to update post: No data returned');
    }
    return Post.fromMap(response[0]);
  }

  Future<void> deletePost(int postId) async {
    try {
      // Bắt đầu một transaction
      //await _client.rpc('begin_transaction');

      // 1. Xóa tất cả các báo cáo liên quan đến bài viết này
      await _client.from('userReport').delete().eq('pid', postId);

      // 2. Xóa tất cả các like liên quan đến bài viết này
      // await _client
      //     .from('likes')
      //     .delete()
      //     .eq('post_id', postId);

      // // 3. Xóa tất cả các comment liên quan đến bài viết này
      // await _client
      //     .from('comments')
      //     .delete()
      //     .eq('post_id', postId);

      // // 4. Xóa tất cả các bookmark liên quan đến bài viết này
      // await _client
      //     .from('bookmarks')
      //     .delete()
      //     .eq('post_id', postId);

      // 5. Cuối cùng xóa bài viết
      await _client.from('posts').delete().eq('pid', postId);

      // Kết thúc transaction
      // await _client.rpc('commit_transaction');
    } catch (e) {
      // Nếu có lỗi, rollback transaction
      //await _client.rpc('rollback_transaction');
      throw Exception('Failed to delete post: $e');
    }
  }

  Future<String> uploadImage(File image, String path) async {
    final response = await _client.storage.from('image').upload(path, image);
    return _client.storage.from('image').getPublicUrl(path);
  }

  Future<List<String>> fetchImagesByUid(int uid) async {
    try {
      // Liệt kê tất cả file trong folder post/{uid}/
      final response = await _client.storage
          .from('image')
          .list(path: 'post/$uid/');
      // Tạo danh sách URL công khai từ các file
      final imageUrls =
          response.map((file) {
            return _client.storage
                .from('image')
                .getPublicUrl('post/$uid/${file.name}');
          }).toList();
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to fetch images: $e');
    }
  }

  Future<List<Post>> get5PostMaxLike() async {
    final response = await _client
        .from('posts')
        .select('*, users!posts_uid_fkey(nickname, avatar, uid)')
        .order('plike', ascending: false)
        .limit(5);
    return (response as List<dynamic>)
        .map((post) => Post.fromMap(post))
        .toList();
  }

  Future<List<String>> get10Hashtag() async {
    try {
      // Lấy 5 bài post có lượt like cao nhất
      final response = await _client
          .from('posts')
          .select('phashtag') // Lấy cột phashtag (dạng chuỗi)
          .order('plike', ascending: false)
          .limit(10);

      // Tạo danh sách các hashtag duy nhất
      Set<String> uniqueHashtags = {};
      for (var post in response as List<dynamic>) {
        if (post['phashtag'] != null) {
          // Xử lý phashtag như chuỗi và loại bỏ ký tự dư thừa
          String hashtagString = post['phashtag'].toString();
          // Loại bỏ [ ] và " bằng cách thay thế
          hashtagString = hashtagString
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '');
          // Tách chuỗi bằng dấu phẩy
          List<String> hashtags =
              hashtagString
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
          uniqueHashtags.addAll(hashtags);
        }
      }

      // Lấy tối đa 5 hashtag duy nhất
      return uniqueHashtags.take(10).toList();
    } catch (e) {
      throw Exception('Failed to fetch hashtags: $e');
    }
  }

  Future<List<Post>> fetchPostsByHashtag(String hashtag) async {
    try {
      final response = await _client
          .from('posts')
          .select('*, users!posts_uid_fkey(name,nickname, avatar, uid)')
          .ilike('phashtag', '%$hashtag%') // Tìm hashtag trong chuỗi phashtag
          .order(
            'createAt',
            ascending: false,
          ); // Sắp xếp theo thời gian mới nhất

      return (response as List<dynamic>)
          .map((post) => Post.fromMap(post))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by hashtag: $e');
    }
  }
}
