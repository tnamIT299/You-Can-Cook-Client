import 'package:you_can_cook/models/Post.dart';
import 'package:supabase/supabase.dart';
import 'dart:io';

class PostService {
  final SupabaseClient _client;

  PostService(this._client);

  Future<List<Post>> fetchPosts() async {
    final response = await _client
        .from('posts')
        .select(
          '*, users!posts_uid_fkey(nickname, avatar, uid)',
        ) // Join với bảng users
        .order('createAt', ascending: false); // Sắp xếp theo thời gian mới nhất
    return (response as List<dynamic>)
        .map((post) => Post.fromMap(post))
        .toList();
  }

  Future<List<Post>> fetchPostsByUid(int uid) async {
    final response = await _client.from('posts').select().eq('uid', uid);
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
    await _client.from('posts').delete().eq('pid', postId);
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
}
