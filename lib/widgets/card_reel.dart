import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/screens/Main/sub_screens/reel/edit_privacy_reel.dart';
import 'package:you_can_cook/services/FollowerService.dart';
import 'package:you_can_cook/widgets/dialog_noti.dart';

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
  bool _isLiked = false;
  bool _isSaved = false;
  bool _showProgress = false;
  Timer? _hideProgressTimer;
  late final FollowerService _followerService;

  @override
  void initState() {
    super.initState();
    _followerService = FollowerService();
    final url = widget.videoUrl ?? widget.reel!.reelUrl;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _hideProgressTimer?.cancel();
    _controller.pause(); // Dừng phát video
    _controller.dispose(); // Hủy controller
    super.dispose();
  }

  void _toggleLike() async {
    if (widget.reel == null) return;
    setState(() {
      _isLiked = !_isLiked;
    });
    await _reelService.updateLike(widget.reel!.reel_id!, _isLiked);
  }

  void _toggleSave() async {
    if (widget.reel == null) return;
    setState(() {
      _isSaved = !_isSaved;
    });
    await _reelService.updateSave(widget.reel!.reel_id!, _isSaved);
  }

  void _showComments() {
    if (widget.reel == null) return;
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 300,
            color: Colors.black87,
            child: Center(
              child: Text(
                'Comments for Reel #${widget.reel!.reel_id}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
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
                            widget.reel!.uid,
                          );
                          // Dừng phát video ngay sau khi xóa
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
                        } catch (e) {}
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
                    onTap: () async {
                      // Navigator.pop(context);
                      // try {
                      //   await _reelService._supabase.from('reports').insert({
                      //     'reel_id': widget.reel!.reel_id,
                      //     'user_id': widget.currentUserUid,
                      //     'reason': 'Nội dung không phù hợp',
                      //     'created_at': DateTime.now().toIso8601String(),
                      //   });
                      //   if (mounted) {
                      //     widget.scaffoldMessengerState?.showSnackBar(
                      //       const SnackBar(content: Text("Báo cáo đã được gửi")),
                      //     );
                      //   }
                      // } catch (e) {
                      //   if (mounted) {
                      //     widget.scaffoldMessengerState?.showSnackBar(
                      //       SnackBar(content: Text("Lỗi khi gửi báo cáo: $e")),
                      //     );
                      //   }
                      // }
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
                        "Huỷ theo dõi",
                        "Bạn có chắc chắn muốn huỷ theo dõi ${widget.reel!.nickname} không?",
                        () async {
                          await _followerService.unfollow(
                            int.parse(widget.currentUserUid!),
                            widget.reel!.uid,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã huỷ theo dõi")),
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
                      color: Colors.black.withOpacity(0.5),
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
                            (context) => ProfileTab(userId: widget.reel!.uid),
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
                  '${widget.reel!.reelLike ?? 0}',
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
                  '${widget.reel!.reelComment ?? 0}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleSave,
                ),
                Text(
                  '${widget.reel!.reelSave ?? 0}',
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
