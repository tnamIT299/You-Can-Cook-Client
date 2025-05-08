import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/widgets/card_reel.dart';
import 'package:you_can_cook/screens/Main/main_tab/reel_tab.dart';
import 'package:you_can_cook/models/Reel.dart';
import 'package:you_can_cook/services/ReelService.dart';
import 'package:you_can_cook/screens/Main/sub_screens/reel/create_reel.dart';
import 'package:you_can_cook/services/UserService.dart';

class ReelTab extends StatefulWidget {
  final List<String>? initialVideos;
  final int? initialIndex;
  final String? currentUserUid;

  const ReelTab({
    super.key,
    this.initialVideos,
    this.initialIndex,
    this.currentUserUid,
  });

  @override
  State<ReelTab> createState() => _ReelTabState();
}

class _ReelTabState extends State<ReelTab> {
  final ReelService _reelService = ReelService();
  final UserService _userService = UserService();
  late Future<List<Reel>> _reelsFuture;
  int? _currentUserUid;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late PageController _pageController;
  List<Reel> _reels = [];
  bool _isLoadingInitialReels = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _reelsFuture = Future.value([]);
    print('uidReeltab: ${widget.currentUserUid}');
    _pageController = PageController(initialPage: widget.initialIndex ?? 0);

    if (widget.currentUserUid != null) {
      _currentUserUid = int.tryParse(widget.currentUserUid!);
      print("Using transmitted currentUserUid: $_currentUserUid");
    }

    if (widget.initialVideos != null && widget.initialVideos!.isNotEmpty) {
      _isLoadingInitialReels = true;
      _loadInitialReels();
      _pageController.addListener(_loadMoreReels);
    } else {
      _reelsFuture = Future.value([]);
      if (_currentUserUid == null) {
        _fetchUserInfo();
      } else {
        _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
      }
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final uid = await _userService.getCurrentUserUid();
      setState(() {
        _currentUserUid = uid;
        _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
      });
    } catch (e) {
      setState(() {
        _reelsFuture = Future.error('Không thể lấy UID: $e');
      });
    }
  }

  Future<void> _loadInitialReels() async {
    try {
      final loadedReels = await _reelService.fetchReelsByUrls(
        widget.initialVideos!,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      setState(() {
        _reels = loadedReels;
        _isLoadingInitialReels = false;
        _hasMore = loadedReels.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _isLoadingInitialReels = false;
      });
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text("Lỗi khi tải video: $e")),
      );
    }
  }

  void _loadMoreReels() {
    if (!_hasMore || _isLoadingInitialReels) return;
    if (_pageController.page! >= _reels.length - 1) {
      setState(() {
        _isLoadingInitialReels = true;
        _currentPage++;
      });
      _loadInitialReels();
    }
  }

  Future<void> _refreshReels() async {
    if (_reels.isNotEmpty) {
      setState(() {
        _currentPage = 0;
        _reels = [];
        _hasMore = true;
        _isLoadingInitialReels = true;
      });
      await _loadInitialReels();
    } else {
      setState(() {
        _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_loadMoreReels);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: const Text(
            'Reels',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateReel()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert_outlined,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateReel()),
                );
              },
            ),
          ],
        ),
        body:
            _reels.isNotEmpty
                ? _isLoadingInitialReels && _reels.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _reels.isEmpty
                    ? const Center(child: Text("Không tìm thấy video nào"))
                    : RefreshIndicator(
                      onRefresh: _refreshReels,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: _reels.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _reels.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final reel = _reels[index];
                          return CardReel(
                            reel: reel,
                            currentUserUid: _currentUserUid?.toString(),
                            onReelDeleted: _refreshReels,
                            scaffoldMessengerState:
                                _scaffoldMessengerKey.currentState,
                          );
                        },
                      ),
                    )
                : FutureBuilder<List<Reel>>(
                  future: _reelsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: Opps! Something went wrong',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Đang tải...',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final reels = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refreshReels,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: reels.length,
                        itemBuilder: (context, index) {
                          return CardReel(
                            reel: reels[index],
                            currentUserUid: _currentUserUid?.toString(),
                            onReelDeleted: _refreshReels,
                            scaffoldMessengerState:
                                _scaffoldMessengerKey.currentState,
                          );
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
