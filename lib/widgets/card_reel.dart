import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/screens/Main/sub_screens/reel/edit_privacy_reel.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/widgets/dialog_noti.dart';
import 'package:you_can_cook/widgets/report-dialog.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:you_can_cook/redux/reducers.dart';
import 'package:you_can_cook/widgets/card_comment_reel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:you_can_cook/services/LikeService.dart';

class CardReel extends StatefulWidget {
  final Reel? reel;
  final String? videoUrl;
  final String? currentUserUid;
  final VoidCallback? onReelDeleted;
  final ScaffoldMessengerState? scaffoldMessengerState;

  const CardReel({
    super.key,
    this.reel,
    this.videoUrl,
    required this.currentUserUid,
    this.onReelDeleted,
    this.scaffoldMessengerState,
  }) : assert(
         reel != null || videoUrl != null,
         'Either reel or videoUrl must be provided',
       );

  @override
  State<CardReel> createState() => _CardReelState();
}

class _CardReelState extends State<CardReel> {
  late VideoPlayerController _controller;
  final ReelService _reelService = ReelService();
  final LikeService _likeService = LikeService();
  bool _isLiked = false;
  final bool _isSaved = false;
  bool _showProgress = false;
  Timer? _hideProgressTimer;
  late final FollowerService _followerService;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _gifSearchController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [];
  bool _isLoadingComments = false;
  bool _hasMoreComments = true;
  int _offset = 0;
  final int _commentsToShow = 10;
  String? _selectedGifUrl;
  bool _isLoadingGifs = false;
  List<String> _gifUrls = [];
  late Reel _currentReel;
  StreamSubscription? _likeCountSubscription;

  @override
  void initState() {
    super.initState();
    _followerService = FollowerService();
    _currentReel = widget.reel ?? Reel(reelUrl: widget.videoUrl!);
    final url = widget.videoUrl ?? widget.reel!.reelUrl;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
    _fetchComments();
    _fetchGifs('');
    if (widget.reel != null && widget.currentUserUid != null) {
      _checkLikeStatus();
      _subscribeToLikeCount();
    }
  }

  Future<void> _checkLikeStatus() async {
    try {
      final isLiked = await _likeService.hasReelLiked(
        int.parse(widget.currentUserUid!),
        widget.reel!.reel_id!,
      );
      setState(() {
        _isLiked = isLiked;
      });
    } catch (e) {
      print('Lỗi kiểm tra trạng thái thích: $e');
    }
  }

  void _subscribeToLikeCount() {
    if (widget.reel == null) return;
    _likeCountSubscription = _likeService
        .listenToReelLikeCount(widget.reel!.reel_id!)
        .listen((likeCount) {
          setState(() {
            _currentReel = Reel(
              reel_id: _currentReel.reel_id,
              uid: _currentReel.uid,
              reelUrl: _currentReel.reelUrl,
              reelContent: _currentReel.reelContent,
              reelHashtag: _currentReel.reelHashtag,
              reelLike: likeCount,
              reelComment: _currentReel.reelComment,
              reelSave: _currentReel.reelSave,
              reelRange: _currentReel.reelRange,
              createAt: _currentReel.createAt,
              avatar: _currentReel.avatar,
              nickname: _currentReel.nickname,
              name: _currentReel.name,
            );
          });
        });
  }

  void _toggleLike() async {
    if (widget.reel == null || widget.currentUserUid == null) return;
    try {
      setState(() {
        _isLiked = !_isLiked;
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: (_currentReel.reelLike ?? 0) + (_isLiked ? 1 : -1),
          reelComment: _currentReel.reelComment,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
      });
      await _likeService.toggleReelLike(
        int.parse(widget.currentUserUid!),
        widget.reel!.reel_id!,
        widget.reel!.uid!,
        !_isLiked, // Trạng thái trước khi thay đổi
      );
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked; // Hoàn tác nếu lỗi
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: (_currentReel.reelLike ?? 0) + (_isLiked ? 1 : -1),
          reelComment: _currentReel.reelComment,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thay đổi trạng thái thích: $e')),
      );
    }
  }

  void _showLikers() async {
    if (widget.reel == null) return;
    try {
      final likers = await _likeService.getReelLikers(
        widget.reel!.reel_id!,
        currentUserId: int.tryParse(widget.currentUserUid ?? ''),
      );
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black87,
        builder:
            (context) => Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  const Text(
                    'Người đã thích',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        likers.isEmpty
                            ? const Center(
                              child: Text(
                                'Chưa có ai thích video này.',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                            : ListView.builder(
                              itemCount: likers.length,
                              itemBuilder: (context, index) {
                                final liker = likers[index];
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProfileTab(
                                              userId: liker['uid'],
                                            ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        liker['avatar'] != null
                                            ? NetworkImage(liker['avatar'])
                                            : const AssetImage(
                                                  'assets/icons/logo.png',
                                                )
                                                as ImageProvider,
                                  ),
                                  title: Text(
                                    liker['nickname'] ??
                                        liker['name'] ??
                                        'Anonymous',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    liker['name'],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lấy danh sách người thích: $e')),
      );
    }
  }

  @override
  void dispose() {
    _hideProgressTimer?.cancel();
    _controller.pause();
    _controller.dispose();
    _commentController.dispose();
    _gifSearchController.dispose();
    _likeCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (_isLoadingComments || !_hasMoreComments || widget.reel == null) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final newComments = await _reelService.fetchReelComments(
        widget.reel!.reel_id!,
        limit: _commentsToShow,
        offset: _offset,
        currentUserId: int.parse(widget.currentUserUid!),
      );

      print('Fetched comments: $newComments');

      setState(() {
        _comments.addAll(newComments);
        _offset += newComments.length;
        _hasMoreComments = newComments.length == _commentsToShow;
        _isLoadingComments = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        _isLoadingComments = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi tải bình luận: $e')));
    }
  }

  void _loadMoreComments() {
    _fetchComments();
  }

  void _toggleLikeComment(int index) async {
    final comment = _comments[index];
    final isLiked = !comment['isLiked'];
    setState(() {
      comment['isLiked'] = isLiked;
      comment['like_count'] = (comment['like_count'] ?? 0) + (isLiked ? 1 : -1);
    });

    try {
      if (isLiked) {
        await _reelService.likeReelComment(
          comment['id'],
          int.parse(widget.currentUserUid!),
        );
      } else {
        await _reelService.unlikeReelComment(
          comment['id'],
          int.parse(widget.currentUserUid!),
        );
      }
    } catch (e) {
      setState(() {
        comment['isLiked'] = !isLiked;
        comment['like_count'] =
            (comment['like_count'] ?? 0) + (isLiked ? -1 : 1);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi thay đổi trạng thái thích: $e')),
      );
    }
  }

  Future<void> _submitComment(dynamic userInfo) async {
    if (_commentController.text.trim().isEmpty && _selectedGifUrl == null ||
        userInfo?.uid == null ||
        widget.reel == null) {
      return;
    }

    final ScrollController scrollController = ScrollController();

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final tempComment = {
        'id': 0,
        'uid': userInfo.uid,
        'reel_id': widget.reel!.reel_id,
        'content': _commentController.text,
        'gifURL': _selectedGifUrl,
        'created_at': DateTime.now().toIso8601String(),
        'avatar': userInfo.avatar,
        'nickname': userInfo.nickname ?? userInfo.name,
        'name': userInfo.name,
        'isLiked': false,
        'users': {
          'uid': userInfo.uid,
          'avatar': userInfo.avatar,
          'nickname': userInfo.nickname ?? userInfo.name,
          'name': userInfo.name,
        },
      };

      setState(() {
        _comments.insert(0, tempComment);
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: _currentReel.reelLike,
          reelComment: (_currentReel.reelComment ?? 0) + 1,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
        _commentController.clear();
        _selectedGifUrl = null;
        _offset += 1;
        _isLoadingComments = false;
      });

      await _reelService.addComment(
        userId: userInfo.uid,
        reelId: widget.reel!.reel_id!,
        content: tempComment['content'],
        gifUrl: tempComment['gifURL'],
      );

      await _reelService.updateReelCommentCount(
        widget.reel!.reel_id!,
        increment: true,
      );

      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _comments.removeWhere((c) => c['id'] == 0);
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: _currentReel.reelLike,
          reelComment: (_currentReel.reelComment ?? 1) - 1,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
        _offset -= 1;
        _isLoadingComments = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể gửi bình luận: $e')));
    }
  }

  void _deleteComment(int commentId, int index) async {
    if (widget.reel == null) return;

    try {
      setState(() {
        _comments.removeAt(index);
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: _currentReel.reelLike,
          reelComment: (_currentReel.reelComment ?? 1) - 1,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
        _offset -= 1;
      });

      await _reelService.deleteComment(commentId, widget.reel!.reel_id!);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bình luận đã được xóa')));
    } catch (e) {
      setState(() {
        _comments.insert(index, _comments[index]);
        _currentReel = Reel(
          reel_id: _currentReel.reel_id,
          uid: _currentReel.uid,
          reelUrl: _currentReel.reelUrl,
          reelContent: _currentReel.reelContent,
          reelHashtag: _currentReel.reelHashtag,
          reelLike: _currentReel.reelLike,
          reelComment: (_currentReel.reelComment ?? 0) + 1,
          reelSave: _currentReel.reelSave,
          reelRange: _currentReel.reelRange,
          createAt: _currentReel.createAt,
          avatar: _currentReel.avatar,
          nickname: _currentReel.nickname,
          name: _currentReel.name,
        );
        _offset += 1;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa bình luận: $e')));
    }
  }

  Future<void> _fetchGifs(String query) async {
    setState(() {
      _isLoadingGifs = true;
    });

    try {
      final String apiKey = dotenv.env['GIF_API_KEY'] ?? '';
      final String url =
          query.isEmpty
              ? 'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=20'
              : 'https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$query&limit=20';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _gifUrls = List<String>.from(
            data['data'].map((gif) => gif['images']['fixed_height']['url']),
          );
          _isLoadingGifs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGifs = false;
        });
      }
    }
  }

  void _showGifPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _gifSearchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm GIF...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  _fetchGifs(value);
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    _isLoadingGifs
                        ? const Center(child: CircularProgressIndicator())
                        : _gifUrls.isEmpty
                        ? const Center(
                          child: Text(
                            'Không tìm thấy GIF',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemCount: _gifUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedGifUrl = _gifUrls[index];
                                  print('Selected GIF: $_selectedGifUrl');
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('GIF đã được chọn'),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: _gifUrls[index],
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComments() {
    if (widget.reel == null) return;

    setState(() {
      _comments.clear();
      _offset = 0;
      _hasMoreComments = true;
      _isLoadingComments = false;
    });

    _fetchComments();

    final ScrollController scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      builder:
          (context) => StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              final userInfo = state.userInfo;

              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Bình luận',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          _isLoadingComments && _comments.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : _comments.isEmpty
                              ? const Center(
                                child: Text(
                                  'Chưa có bình luận nào.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                              : ListView.builder(
                                controller: scrollController,
                                itemCount:
                                    _comments.length +
                                    (_hasMoreComments ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _comments.length) {
                                    return _isLoadingComments
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : TextButton(
                                          onPressed: _loadMoreComments,
                                          child: const Text(
                                            'Xem thêm',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        );
                                  }

                                  return CardCommentReel(
                                    comment: _comments[index],
                                    currentUserUid: widget.currentUserUid,
                                    onLike: () => _toggleLikeComment(index),
                                    onDelete:
                                        () => _deleteComment(
                                          _comments[index]['id'],
                                          index,
                                        ),
                                  );
                                },
                              ),
                    ),
                    if (_selectedGifUrl != null)
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: _selectedGifUrl!,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    const CircularProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedGifUrl = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              userInfo?.avatar != null
                                  ? NetworkImage(userInfo.avatar)
                                  : const AssetImage("assets/icons/logo.png")
                                      as ImageProvider,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Viết bình luận...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.gif,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _showGifPicker,
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () => _submitComment(userInfo),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showProgressBar();
    });
  }

  void _rewind10Seconds() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    _showProgressBar();
  }

  void _forward10Seconds() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(newPosition > duration ? duration : newPosition);
    _showProgressBar();
  }

  void _showProgressBar() {
    setState(() {
      _showProgress = true;
    });

    _hideProgressTimer?.cancel();
    _hideProgressTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showProgress = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _showReportDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => ReportDialog(
            reporterUid: widget.currentUserUid!,
            reportedUid: widget.reel!.uid.toString(),
            reel_id: widget.reel!.reel_id.toString(),
          ),
    );

    if (result == true) {
      // Handle successful report if needed
    }
  }

  void _showOptionsMenu() {
    if (widget.reel == null) return;

    final bool isReelOwner =
        widget.currentUserUid != null &&
        widget.currentUserUid == widget.reel!.uid.toString();

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            color: Colors.black87,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isReelOwner) ...[
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.white),
                    title: const Text(
                      'Chỉnh sửa quyền riêng tư video',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  EditReelPrivacyScreen(reel: widget.reel!),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.visibility, color: Colors.white),
                    title: const Text(
                      'Xem số lượt thích',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showLikers();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.white),
                    title: const Text(
                      'Xóa video',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Xóa Reel'),
                              content: const Text(
                                'Bạn có chắc chắn muốn xóa reel này?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );

                      Navigator.pop(context);

                      if (shouldDelete == true) {
                        try {
                          if (widget.reel == null ||
                              widget.reel!.reel_id == null) {
                            throw Exception("Video không hợp lệ để xóa");
                          }
                          await _reelService.deleteReel(
                            widget.reel!.reel_id!,
                            widget.reel!.uid!,
                          );
                          _controller.pause();
                          _controller.dispose();
                          if (mounted) {
                            widget.scaffoldMessengerState?.showSnackBar(
                              const SnackBar(
                                content: Text("Reel đã được xóa thành công"),
                              ),
                            );
                            widget.onReelDeleted?.call();
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {}
                        }
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.report, color: Colors.white),
                    title: const Text(
                      'Báo cáo video',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showReportDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.red),
                    title: const Text(
                      'Bỏ theo dõi',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      show_Dialog(
                        context,
                        "Hủy theo dõi",
                        "Bạn có chắc chắn muốn hủy theo dõi ${widget.reel!.nickname} không?",
                        () async {
                          await _followerService.unfollow(
                            int.parse(widget.currentUserUid!),
                            widget.reel!.uid!,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã hủy theo dõi")),
                          );
                        },
                        () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        _controller.value.isInitialized
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        onDoubleTapDown: (details) {
                          final tapPosition = details.localPosition.dx;
                          if (tapPosition < screenWidth / 2) {
                            _rewind10Seconds();
                          } else {
                            _forward10Seconds();
                          }
                        },
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                  if (_showProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      color: Colors.black,
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Colors.red,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
            : const Center(child: CircularProgressIndicator()),
        if (widget.reel != null) ...[
          Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProfileTab(userId: widget.reel!.uid!),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            widget.reel!.avatar != null
                                ? NetworkImage(widget.reel!.avatar!)
                                : const AssetImage('assets/icons/logo.png')
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.reel!.nickname ?? widget.reel!.name ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.reel!.reelContent ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (widget.reel!.reelHashtag != null &&
                    widget.reel!.reelHashtag!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      children:
                          widget.reel!.reelHashtag!.map<Widget>((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 2.0),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 60,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleLike,
                ),
                Text(
                  '${_currentReel.reelLike ?? 0}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _showComments,
                ),
                Text(
                  '${_currentReel.reelComment ?? 0}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
                Text(
                  '${_currentReel.reelSave ?? 0}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _showOptionsMenu,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
