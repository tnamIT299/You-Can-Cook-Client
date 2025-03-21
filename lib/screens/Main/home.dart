import 'package:flutter/material.dart';
import 'package:you_can_cook/screens/Main/main_tab/home_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/explore_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/chatAI_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/ranked_tab.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';
import 'package:you_can_cook/utils/color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index của tab được chọn

  // Danh sách các màn hình tương ứng với các tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(),
      const ExploreTab(),
      const ChatAI_Tab(),
      const Ranked_Tab(),
      ProfileTab(),
    ];
  }

  // Xử lý khi thay đổi tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF868686),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Bảng tin',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'BXH'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
