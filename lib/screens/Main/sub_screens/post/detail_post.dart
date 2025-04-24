import 'package:flutter/material.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/models/Post.dart';
import 'package:you_can_cook/models/Comment.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/widgets/card_comment.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/redux/actions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:you_can_cook/services/CommentService.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/services/LikeService.dart';
import 'package:you_can_cook/db/db.dart' as db;
import 'package:you_can_cook/helper/pick_Image.dart';
import 'package:you_can_cook/widgets/loading_screen.dart';
import 'package:you_can_cook/screens/Main/sub_screens/like/like_screen.dart';
import 'package:giphy_picker/giphy_picker.dart';

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
  List<File> selectedImages = [];
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService(db.supabaseClient);
  final LikeService _likeService = LikeService();
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
    _fetchCurrentUserUid().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final store = StoreProvider.of<AppState>(context, listen: false);
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email != null) {
          store.dispatch(FetchUserInfo(currentUser.email!)).then((_) {
            _fetchComments();
          });
        } else {
          debugPrint("Không có người dùng đăng nhập hoặc email bị thiếu.");
          _fetchComments();
        }
      });
    });
  }

  @override
  void didUpdateWidget(DetailPostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserUid != oldWidget.currentUserUid) {
      _fetchCurrentUserUid();
    }
  }

  void _startEditingComment(int commentId, String content, int index) {
    setState(() {
      _isEditingComment = true;
      _editingCommentId = commentId;
      _editingCommentIndex = index;
      _commentController.text = content;
    });

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
    if (uid != null && mounted) {
      setState(() {
        _currentUserUid = uid;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePickerUtil.pickImage();
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile));
      });
    }
  }

  Future<void> _fetchComments() async {
    if (_isLoadingComments || !_hasMoreComments) return;

    if (mounted) {
      setState(() {
        _isLoadingComments = true;
      });
    }

    final store = StoreProvider.of<AppState>(context, listen: false);
    try {
      await store.dispatch(
        FetchComments(
          widget.post.pid ?? 0,
          limit: _commentsToShow,
          offset: _offset,
        ),
      );

      final comments = store.state.postComments[widget.post.pid ?? 0] ?? [];
      if (mounted) {
        setState(() {
          _offset += comments.length;
          final totalComments = _currentPost.pcomment ?? 0;
          _hasMoreComments = comments.length < totalComments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  void _toggleLikeComment(Comment comment, bool isLiked) {
    if (_currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thích bình luận')),
      );
      return;
    }

    final store = StoreProvider.of<AppState>(context, listen: false);
    store.dispatch(
      ToggleCommentLike(widget.post.pid ?? 0, comment.id, !isLiked),
    );
  }

  Future<void> _editComment(int commentId, String newContent) async {
    try {
      await _commentService.updateComment(commentId, newContent);
      await _fetchComments();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã cập nhật bình luận")));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
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

    if (mounted) {
      setState(() {
        _isLoadingComments = true;
      });
    }

    final store = StoreProvider.of<AppState>(context, listen: false);
    try {
      final tempComment = Comment(
        id: 0,
        userId: userInfo.uid,
        postId: _currentPost.pid ?? 0,
        content: _commentController.text,
        createdAt: DateTime.now(),
        avatar: userInfo.avatar,
        nickname: userInfo.nickname ?? userInfo.name,
        name: userInfo.name,
        likeCount: 0,
        isLiked: false,
      );

      final currentComments =
          store.state.postComments[_currentPost.pid ?? 0] ?? [];
      store.dispatch(
        SetComments(_currentPost.pid ?? 0, [tempComment, ...currentComments]),
      );
      if (mounted) {
        setState(() {
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
            name: _currentPost.name,
          );
          _commentController.clear();
          _offset += 1;
          _isLoadingComments = false;
        });
      }

      await _commentService.addComment(
        userId: userInfo.uid,
        postId: _currentPost.pid ?? 0,
        content: tempComment.content,
      );

      await _commentService.updatePostCommentCount(
        _currentPost.pid ?? 0,
        increment: true,
      );

      await _fetchComments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm bình luận: $e')));
      final currentComments =
          store.state.postComments[_currentPost.pid ?? 0] ?? [];
      store.dispatch(
        SetComments(
          _currentPost.pid ?? 0,
          currentComments.where((c) => c.id != 0).toList(),
        ),
      );
      if (mounted) {
        setState(() {
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
            name: _currentPost.name,
          );
          _offset -= 1;
          _isLoadingComments = false;
        });
      }
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
    if (mounted) {
      setState(() {
        _isLoadingComments = true;
      });
    }

    try {
      await _commentService.deleteComment(commentId);
      await _commentService.updatePostCommentCount(
        _currentPost.pid ?? 0,
        increment: false,
      );
      if (mounted) {
        setState(() {
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
            name: _currentPost.name,
          );
          _offset -= 1;
          _isLoadingComments = false;
        });
      }

      await _fetchComments();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bình luận đã được xóa")));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
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

  void _updateLikeCount(int newLikeCount, bool isLiked) {
    if (mounted) {
      setState(() {
        _currentPost = Post(
          pid: _currentPost.pid,
          uid: _currentPost.uid,
          pcontent: _currentPost.pcontent,
          pimage: _currentPost.pimage,
          phashtag: _currentPost.phashtag,
          plike: newLikeCount,
          pcomment: _currentPost.pcomment,
          psave: _currentPost.psave,
          createAt: _currentPost.createAt,
          avatar: _currentPost.avatar,
          nickname: _currentPost.nickname,
          name: _currentPost.name,
        );
      });
    }
  }

  Future<void> _pickGIF(BuildContext context) async {
    try {
      final gif = await GiphyPicker.pickGif(
        context: context,
        apiKey: 'QxBdVtcex9YYfnfZYJkC8BoWNxE6hw7A', // Thay bằng API Key của bạn
      );

      if (gif != null) {
        // In ra URL của GIF để kiểm tra, chưa gửi bình luận
        print('GIF selected: ${gif.url}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã chọn GIF: ${gif.url}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn GIF: $e')));
    }
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
        final comments = state.postComments[_currentPost.pid ?? 0] ?? [];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed:
                  () => Navigator.pop(context, {
                    'likeCount': _currentPost.plike ?? 0,
                  }),
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
              state.isLoading && comments.isEmpty
                  ? const LoadingScreen()
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
                                        _currentPost.name ??
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
                              FunctionButton(
                                post: _currentPost,
                                likeService: _likeService,
                                currentUserUid: _currentUserUid,
                                onLikeToggled: _updateLikeCount,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 4.0,
                                ),
                                child: FutureBuilder<
                                  List<Map<String, dynamic>>
                                >(
                                  future: _likeService.getPostLikers(
                                    _currentPost.pid ?? 0,
                                    currentUserId: _currentUserUid,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    final likers = snapshot.data!;
                                    final likeCount = likers.length;
                                    bool isCurrentUserLiker = likers.any(
                                      (liker) => liker['isCurrentUser'],
                                    );
                                    String displayText = '';

                                    if (likeCount == 1) {
                                      displayText =
                                          isCurrentUserLiker
                                              ? 'Bạn đã thích bài viết này'
                                              : '${likers[0]['nickname']} đã thích bài viết';
                                    } else if (likeCount == 2) {
                                      if (isCurrentUserLiker) {
                                        final otherLiker = likers.firstWhere(
                                          (liker) => !liker['isCurrentUser'],
                                        );
                                        displayText =
                                            'Bạn và ${otherLiker['nickname']} đã thích bài viết';
                                      } else {
                                        displayText =
                                            '${likers[0]['nickname']} và ${likers[1]['nickname']} đã thích bài viết';
                                      }
                                    } else {
                                      if (isCurrentUserLiker) {
                                        final otherLiker = likers.firstWhere(
                                          (liker) => !liker['isCurrentUser'],
                                        );
                                        displayText =
                                            'Bạn, ${otherLiker['nickname']} và ${likeCount - 2} người khác đã thích bài viết';
                                      } else {
                                        displayText =
                                            '${likers[0]['nickname']} và ${likeCount - 1} người khác đã thích bài viết';
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => LikersScreen(
                                                  postId: _currentPost.pid ?? 0,
                                                  currentUserId:
                                                      _currentUserUid,
                                                  likeService: _likeService,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        displayText,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
                                    if (comments.isEmpty && !_isLoadingComments)
                                      const Center(
                                        child: Text("Chưa có bình luận nào."),
                                      ),
                                    ...comments.asMap().entries.map((entry) {
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
                                          'like_count': comment.likeCount,
                                          'isLiked': comment.isLiked,
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
                                        onLike:
                                            () => _toggleLikeComment(
                                              comment,
                                              comment.isLiked,
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
                                ),
                              ),
                            ),
                            if (_isEditingComment)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: _cancelEditing,
                              ),
                            // IconButton(
                            //   icon: const Icon(
                            //     Icons.image,
                            //     color: Colors.green,
                            //   ),
                            //   onPressed: _pickImage,
                            // ),
                            IconButton(
                              icon: const Icon(
                                size: 40.0,
                                Icons.gif,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                _pickGIF(context);
                              },
                            ),
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

class FunctionButton extends StatefulWidget {
  const FunctionButton({
    super.key,
    required this.post,
    required this.likeService,
    required this.currentUserUid,
    required this.onLikeToggled,
  });

  final Post post;
  final LikeService likeService;
  final int? currentUserUid;
  final void Function(int newLikeCount, bool isLiked) onLikeToggled;

  @override
  _FunctionButtonState createState() => _FunctionButtonState();
}

class _FunctionButtonState extends State<FunctionButton> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.plike ?? 0;
    if (widget.currentUserUid != null) {
      _checkLikeStatus();
    }
  }

  @override
  void didUpdateWidget(FunctionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUserUid != oldWidget.currentUserUid) {
      _checkLikeStatus();
    }
  }

  Future<void> _checkLikeStatus() async {
    if (widget.currentUserUid == null) {
      if (mounted) {
        setState(() {
          _isLiked = false;
        });
      }
      return;
    }
    final isLiked = await widget.likeService.hasLiked(
      widget.currentUserUid!,
      widget.post.pid!,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (widget.currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thích bài viết')),
      );
      return;
    }

    try {
      await widget.likeService.toggleLike(
        widget.currentUserUid!,
        widget.post.pid!,
        widget.post.uid,
        _isLiked,
      );
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
          widget.onLikeToggled(_likeCount, _isLiked);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi thích bài viết: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream:
          widget.currentUserUid != null
              ? widget.likeService.listenToLikeStatus(
                widget.currentUserUid!,
                widget.post.pid!,
              )
              : null,
      initialData: _isLiked ? 1 : 0,
      builder: (context, likeStatusSnapshot) {
        final isLiked = likeStatusSnapshot.data == 1;
        return StreamBuilder<int>(
          stream: widget.likeService.listenToLikeCount(widget.post.pid!),
          initialData: _likeCount,
          builder: (context, likeCountSnapshot) {
            final likeCount = likeCountSnapshot.data ?? _likeCount;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : AppColors.primary,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text("$likeCount"),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.comment,
                          color: AppColors.primary,
                        ),
                        onPressed: () {},
                      ),
                      Text("${widget.post.pcomment ?? 0}"),
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
                            const SnackBar(
                              content: Text("Save functionality here"),
                            ),
                          );
                        },
                      ),
                      Text("${widget.post.psave ?? 0}"),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
