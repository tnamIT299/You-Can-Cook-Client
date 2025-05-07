import 'package:flutter/material.dart';
import 'package:you_can_cook/screens/Main/main_tab/home_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/explore_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/chatAI_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/ranked_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/screens/Main/main_tab/reel_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens = [
    const Center(child: CircularProgressIndicator()),
  ];

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  Future<void> _initializeScreens() async {
    final currentUserUid =
        await UserService().getCurrentUserUid(); // Lấy UID từ UserService
    final int userId =
        currentUserUid ?? 0; // Nếu null, đặt giá trị mặc định là 0
    if (mounted) {
      setState(() {
        _screens = [
          HomeTab(),
          const ReelTab(),
          const ExploreTab(),
          const ChatAI_Tab(),
          const Ranked_Tab(),
          ProfileTab(userId: userId), // Truyền userId vào ProfileTab
        ];
      });
    }
  }

  // Xử lý khi thay đổi tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: BottomNavigationBar(
          backgroundColor: AppColors.background,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Color(0xFF868686),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12, height: 1.2),
          unselectedLabelStyle: TextStyle(fontSize: 10, height: 1.2),
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Bảng tin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded),
              label: 'Reel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'BXH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
