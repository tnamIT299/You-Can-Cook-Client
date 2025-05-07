// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:you_can_cook/widgets/card_reel.dart';
// import 'package:you_can_cook/screens/Main/main_tab/reel_tab.dart';
// import 'package:you_can_cook/models/Reel.dart';
// import 'package:you_can_cook/services/ReelService.dart';
// import 'package:you_can_cook/screens/Main/sub_screens/reel/create_reel.dart';
// import 'package:you_can_cook/services/UserService.dart';

// class ReelTab extends StatefulWidget {
//   const ReelTab({super.key});

//   @override
//   State<ReelTab> createState() => _ReelTabState();
// }

// class _ReelTabState extends State<ReelTab> {
//   final ReelService _reelService = ReelService();
//   final UserService _userService = UserService();
//   late Future<List<Reel>> _reelsFuture;
//   int? _currentUserUid;
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();

//   @override
//   void initState() {
//     super.initState();
//     _reelsFuture = Future.value([]);
//     _fetchUserInfo();
//   }

//   Future<void> _fetchUserInfo() async {
//     try {
//       final uid = await _userService.getCurrentUserUid();
//       setState(() {
//         _currentUserUid = uid;
//         _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
//       });
//     } catch (e) {
//       setState(() {
//         _reelsFuture = Future.error('Không thể lấy UID: $e');
//       });
//     }
//   }

//   Future<void> _refreshReels() async {
//     setState(() {
//       _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaffoldMessenger(
//       key: _scaffoldMessengerKey,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.black,
//           title: const Text(
//             'Reels',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 30,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(
//                 Icons.add_circle_outline,
//                 color: Colors.white,
//                 size: 30,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const CreateReel()),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(
//                 Icons.more_vert_outlined,
//                 color: Colors.white,
//                 size: 30,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const CreateReel()),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: FutureBuilder<List<Reel>>(
//           future: _reelsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   'Error: ${snapshot.error}',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               );
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'Chưa có video nào',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               );
//             }

//             final reels = snapshot.data!;
//             return RefreshIndicator(
//               onRefresh: _refreshReels, // Gọi _refreshReels khi kéo xuống
//               child: PageView.builder(
//                 scrollDirection: Axis.vertical,
//                 itemCount: reels.length,
//                 itemBuilder: (context, index) {
//                   return CardReel(
//                     reel: reels[index],
//                     currentUserUid: _currentUserUid.toString(),
//                     onReelDeleted: _refreshReels,
//                     scaffoldMessengerState: _scaffoldMessengerKey.currentState,
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

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
      final List<Reel> loadedReels = [];
      for (String videoUrl in widget.initialVideos!) {
        final reel = await _reelService.fetchReelByUrl(videoUrl);
        if (reel != null) {
          loadedReels.add(reel);
        }
      }
      setState(() {
        _reels = loadedReels;
        _isLoadingInitialReels = false;
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

  Future<void> _refreshReels() async {
    if (_reels.isNotEmpty) {
      // Nếu đang hiển thị initialVideos, làm mới _reels
      setState(() {
        _isLoadingInitialReels = true;
      });
      await _loadInitialReels();
    } else {
      // Nếu hiển thị từ fetchFilteredReels, làm mới _reelsFuture
      setState(() {
        _reelsFuture = _reelService.fetchFilteredReels(_currentUserUid!);
      });
    }
  }

  @override
  void dispose() {
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
                ? _isLoadingInitialReels
                    ? const Center(child: CircularProgressIndicator())
                    : _reels.isEmpty
                    ? const Center(child: Text("Không tìm thấy video nào"))
                    : RefreshIndicator(
                      onRefresh: _refreshReels,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: _reels.length,
                        itemBuilder: (context, index) {
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
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có video nào',
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
