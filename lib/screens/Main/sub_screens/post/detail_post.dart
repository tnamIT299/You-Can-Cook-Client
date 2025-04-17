import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/Comment.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/vi_messages.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/widgets/card_comment.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:you_can_cook/services/CommentService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/db/db.dart' as db;

void registerTimeagoMessages() {
  timeago.setLocaleMessages('vi', timeago.ViMessages());
}

class DetailPostScreen extends StatefulWidget {
  final Post post;
  final String? currentUserUid;

  const DetailPostScreen({super.key, required this.post, this.currentUserUid});

  @override
  _DetailPostScreenState createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService(db.supabaseClient);
  final List<Comment> _comments = [];
  late Post _currentPost;
  bool _isLoadingComments = false;
  bool _hasMoreComments = true;
  final int _commentsToShow = 8;
  int _offset = 0;
  int? _currentUserUid;
  bool _isEditingComment = false;
  int? _editingCommentId;
  int? _editingCommentIndex;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    _fetchCurrentUserUid();
    _fetchComments();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = StoreProvider.of<AppState>(context, listen: false);
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        store.dispatch(FetchUserInfo(currentUser.email!));
      } else {
        debugPrint("Không có người dùng đăng nhập hoặc email bị thiếu.");
      }
    });
  }

  void _startEditingComment(int commentId, String content, int index) {
    setState(() {
      _isEditingComment = true;
      _editingCommentId = commentId;
      _editingCommentIndex = index;
      _commentController.text = content;
    });

    // Cuộn màn hình xuống TextField
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchCurrentUserUid() async {
    final userService = UserService();
    final uid = await userService.getCurrentUserUid();
    if (uid != null) {
      setState(() {
        _currentUserUid = uid;
      });
    }
  }

  Future<void> _fetchComments() async {
    if (_isLoadingComments || !_hasMoreComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final newComments = await _commentService.getCommentsByPostId(
        _currentPost.pid ?? 0,
        limit: _commentsToShow,
        offset: _offset,
      );
      setState(() {
        _comments.addAll(newComments);
        _offset += newComments.length;
        _hasMoreComments = newComments.length == _commentsToShow;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  // Thêm phương thức này vào _DetailPostScreenState
  Future<void> _editComment(int commentId, String newContent) async {
    try {
      // Tìm vị trí comment cần sửa
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index == -1) return;

      // Lưu nội dung cũ để có thể khôi phục nếu có lỗi
      final oldContent = _comments[index].content;

      // Cập nhật UI ngay lập tức để UX tốt hơn
      setState(() {
        _comments[index] = Comment(
          id: _comments[index].id,
          userId: _comments[index].userId,
          postId: _comments[index].postId,
          content: newContent,
          createdAt: _comments[index].createdAt,
          name: _comments[index].name,
          nickname: _comments[index].nickname,
          avatar: _comments[index].avatar,
        );
      });

      // Gọi API để cập nhật comment
      await _commentService.updateComment(commentId, newContent);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã cập nhật bình luận")));
    } catch (e) {
      print('Error editing comment: $e');

      // Tải lại toàn bộ bình luận nếu có lỗi
      _fetchComments();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật bình luận: $e')));
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileTab(userId: _currentPost.uid),
      ),
    );
  }

  Future<void> _submitComment(dynamic userInfo) async {
    if (_commentController.text.isEmpty || userInfo?.uid == null) {
      return;
    }

    setState(() {
      _isLoadingComments = true;
    });

    try {
      await _commentService.addComment(
        userId: userInfo.uid,
        postId: _currentPost.pid ?? 0,
        content: _commentController.text,
      );

      await _commentService.updatePostCommentCount(
        _currentPost.pid ?? 0,
        increment: true,
      );

      setState(() {
        _comments.insert(
          0,
          Comment(
            id: 0,
            userId: userInfo.uid,
            postId: _currentPost.pid ?? 0,
            content: _commentController.text,
            createdAt: DateTime.now(),
            avatar: userInfo.avatar,
            nickname: userInfo.nickname ?? userInfo.name,
            name: userInfo.name,
          ),
        );
        _currentPost = Post(
          pid: _currentPost.pid,
          uid: _currentPost.uid,
          pcontent: _currentPost.pcontent,
          pimage: _currentPost.pimage,
          phashtag: _currentPost.phashtag,
          plike: _currentPost.plike,
          pcomment: (_currentPost.pcomment ?? 0) + 1,
          psave: _currentPost.psave,
          createAt: _currentPost.createAt,
          avatar: _currentPost.avatar,
          nickname: _currentPost.nickname,
        );
        _commentController.clear();
        _offset += 1;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _deleteComment(int commentId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xóa bình luận"),
            content: const Text("Bạn có chắc chắn muốn xóa bình luận này?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      await _commentService.deleteComment(commentId);
      await _commentService.updatePostCommentCount(
        _currentPost.pid ?? 0,
        increment: false,
      );

      setState(() {
        _comments.removeAt(index);
        _currentPost = Post(
          pid: _currentPost.pid,
          uid: _currentPost.uid,
          pcontent: _currentPost.pcontent,
          pimage: _currentPost.pimage,
          phashtag: _currentPost.phashtag,
          plike: _currentPost.plike,
          pcomment: (_currentPost.pcomment ?? 1) - 1,
          psave: _currentPost.psave,
          createAt: _currentPost.createAt,
          avatar: _currentPost.avatar,
          nickname: _currentPost.nickname,
        );
        _offset -= 1;
        _isLoadingComments = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bình luận đã được xóa")));
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi xóa bình luận: $e")));
    }
  }

  void _loadMoreComments() {
    _fetchComments();
  }

  void _cancelEditing() {
    setState(() {
      _isEditingComment = false;
      _editingCommentId = null;
      _editingCommentIndex = null;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String relativeTime = timeago.format(
      _currentPost.createAt ?? DateTime.now(),
      locale: 'vi',
    );
    final List<String>? images = _currentPost.pimage;

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        final userInfo = state.userInfo;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Chi tiết bài viết",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body:
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: GestureDetector(
                                  onTap: () => _navigateToProfile(context),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        _currentPost.avatar != null
                                            ? NetworkImage(_currentPost.avatar!)
                                            : const AssetImage(
                                                  "assets/icons/logo.png",
                                                )
                                                as ImageProvider,
                                  ),
                                ),
                                title: GestureDetector(
                                  onTap: () => _navigateToProfile(context),
                                  child: Text(
                                    _currentPost.nickname ??
                                        'you_can_cook ${DateTime.now().microsecondsSinceEpoch}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                subtitle: Text(relativeTime),
                              ),
                              if (images != null && images.isNotEmpty)
                                images.length > 1
                                    ? Column(
                                      children: [
                                        CarouselSlider(
                                          options: CarouselOptions(
                                            height: 300.0,
                                            autoPlay: true,
                                            autoPlayInterval: const Duration(
                                              seconds: 3,
                                            ),
                                            enlargeCenterPage: true,
                                            aspectRatio: 16 / 9,
                                            viewportFraction: 1.0,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentImageIndex = index;
                                              });
                                            },
                                          ),
                                          items:
                                              images.map((imageUrl) {
                                                return Builder(
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Center(
                                                          child: Text(
                                                            'Error loading image',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children:
                                              images.asMap().entries.map((
                                                entry,
                                              ) {
                                                return GestureDetector(
                                                  onTap:
                                                      () => setState(() {
                                                        _currentImageIndex =
                                                            entry.key;
                                                      }),
                                                  child: Container(
                                                    width: 8.0,
                                                    height: 8.0,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 4.0,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          _currentImageIndex ==
                                                                  entry.key
                                                              ? AppColors
                                                                  .primary
                                                              : Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    )
                                    : Image.network(
                                      images[0],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300.0,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Center(
                                          child: Text(
                                            'Error loading image',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        );
                                      },
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _currentPost.pcontent ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (_currentPost.phashtag != null &&
                                  _currentPost.phashtag!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Wrap(
                                    children:
                                        _currentPost.phashtag!.map<Widget>((
                                          tag,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              FunctionButton(post: _currentPost),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Bình luận",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_comments.isEmpty &&
                                        !_isLoadingComments)
                                      const Center(
                                        child: Text("Chưa có bình luận nào."),
                                      ),
                                    ..._comments.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final comment = entry.value;
                                      return CardComment(
                                        comment: {
                                          'avatar': comment.avatar ?? '',
                                          'nickname':
                                              comment.nickname ??
                                              comment.name ??
                                              'Bạn',
                                          'content': comment.content,
                                          'time': timeago.format(
                                            comment.createdAt,
                                            locale: 'vi',
                                          ),
                                          'uid': comment.userId.toString(),
                                        },
                                        canDelete:
                                            _currentUserUid != null &&
                                            _currentUserUid == comment.userId,
                                        onDelete:
                                            () => _deleteComment(
                                              comment.id,
                                              index,
                                            ),
                                        onEdit:
                                            () => _startEditingComment(
                                              comment.id,
                                              comment.content,
                                              index,
                                            ),
                                      );
                                    }),
                                    if (_hasMoreComments)
                                      Center(
                                        child: TextButton(
                                          onPressed: _loadMoreComments,
                                          child: const Text(
                                            "Xem thêm",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_isLoadingComments)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  userInfo?.avatar != null
                                      ? NetworkImage(userInfo.avatar)
                                      : const AssetImage(
                                            "assets/icons/logo.png",
                                          )
                                          as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText:
                                      _isEditingComment
                                          ? "Chỉnh sửa bình luận..."
                                          : "Viết bình luận...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  // Thêm prefix nếu đang chỉnh sửa
                                  prefixIcon:
                                      _isEditingComment
                                          ? const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          )
                                          : null,
                                ),
                              ),
                            ),
                            // Nút hủy chỉnh sửa (chỉ hiển thị khi đang chỉnh sửa)
                            if (_isEditingComment)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: _cancelEditing,
                              ),
                            // Nút gửi/lưu
                            IconButton(
                              icon: Icon(
                                _isEditingComment ? Icons.check : Icons.send,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                if (_isEditingComment) {
                                  if (_editingCommentId != null &&
                                      _editingCommentIndex != null) {
                                    _editComment(
                                      _editingCommentId!,
                                      _commentController.text,
                                    );
                                    _cancelEditing();
                                  }
                                } else {
                                  _submitComment(userInfo);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class FunctionButton extends StatelessWidget {
  const FunctionButton({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Like functionality here")),
                  );
                },
              ),
              Text("${post.plike ?? 0}"),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Comment functionality here")),
                  );
                },
              ),
              Text("${post.pcomment ?? 0}"),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Save functionality here")),
                  );
                },
              ),
              Text("${post.psave ?? 0}"),
            ],
          ),
        ],
      ),
    );
  }
}
