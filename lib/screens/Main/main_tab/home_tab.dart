import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:you_can_cook/widgets/card_post.dart';
import 'package:you_can_cook/screens/Main/sub_screens/settting.dart';
import 'package:you_can_cook/screens/Main/sub_screens/post/create_post.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

  final List<Map<String, dynamic>> posts = [
    {
      "username": "jana_strassmann",
      "role": "Artist",
      "image": "assets/icons/logo.png",
      "hashtags": ["#travel", "#time", "#tranding"],
      "likes": 500,
      "comments": 120,
      "saves": 50,
      "description":
          "Hello my friends today i did holl for the first time it was a crazy experience",
    },
    {
      "username": "chineze_afamefuna",
      "role": "Artist",
      "image": "assets/icons/logo.png",
      "hashtags": ["#travel", "#time", "#tranding"],
      "likes": 120,
      "comments": 120,
      "saves": 50,
      "description": "Enjoying a sunny day at the beach! 🌞",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color(0xFFEEA734)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/icons/logo.png"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email ?? "Guest",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Điểm tích luỹ'),
              onTap: () {
                // Xử lý khi chọn Điểm tích luỹ
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Yêu thích'),
              onTap: () {
                // Xử lý khi chọn Yêu thích
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 200.0,
            backgroundColor: const Color(0xFFEEA734),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            return IconButton(
                              iconSize: 30,
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            );
                          },
                        ),
                        Row(
                          children: [
                            IconButton(
                              iconSize: 30,
                              color: Colors.white,
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateNewPostScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              iconSize: 30,
                              color: Colors.white,
                              icon: const Icon(Icons.notifications),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text(
                      "Xin Chào",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Source Sans 3',
                      ),
                    ),
                    const Text(
                      "Hôm nay ăn gì? Để chúng tôi gợi ý!",
                      style: TextStyle(
                        color: Color(0xff141a46),
                        fontSize: 20,
                        fontFamily: 'Source Sans 3',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Danh sách bài đăng
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: CardPost(post: post),
              );
            }, childCount: posts.length),
          ),
        ],
      ),
    );
  }
}
