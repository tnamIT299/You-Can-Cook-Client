import 'package:flutter/material.dart';
import 'package:you_can_cook/models/User.dart';
import 'package:you_can_cook/services/RankingService.dart';
import 'package:you_can_cook/utils/color.dart';

class Ranked_Tab extends StatelessWidget {
  const Ranked_Tab({super.key});

  @override
  Widget build(BuildContext context) {
    final RankingService rankingService = RankingService();
    final String month = DateTime.now().month.toString();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<User>>(
            future: rankingService.getRankedUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Lỗi: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return const Center(
                  child: Text(
                    "Không có người dùng nào.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Chia danh sách thành top 3 và phần còn lại
              final top3 = users.length >= 3 ? users.sublist(0, 3) : users;
              final others = users.length > 3 ? users.sublist(3) : [];

              return CustomScrollView(
                slivers: [
                  // AppBar
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    title: Center(
                      child: Text(
                        'BẢNG XẾP HẠNG THÁNG $month',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Source Sans 3',
                          fontSize: 25,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                  ),
                  // Top 3
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Top3Podium(top3: top3),
                    ),
                  ),
                  // Danh sách còn lại
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = others[index];
                      return RankingItem(user: user, rank: index + 4);
                    }, childCount: others.length),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Widget hiển thị top 3 người dùng trên bục podium
class Top3Podium extends StatelessWidget {
  final List<User> top3;

  const Top3Podium({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Tăng chiều cao để chứa nội dung
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hạng 2
          if (top3.length > 1) PodiumItem(user: top3[1], rank: 2, height: 120),
          // Hạng 1
          if (top3.isNotEmpty) PodiumItem(user: top3[0], rank: 1, height: 160),
          // Hạng 3
          if (top3.length > 2) PodiumItem(user: top3[2], rank: 3, height: 100),
        ],
      ),
    );
  }
}

// Widget hiển thị từng người dùng trên bục podium
class PodiumItem extends StatelessWidget {
  final User user;
  final int rank;
  final double height;

  const PodiumItem({
    super.key,
    required this.user,
    required this.rank,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = [
      // Gradient cho hạng 1 (Vàng)
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF176), // Vàng nhạt
          Color(0xFFFFD700), // Vàng
          Color(0xFFFF9800), // Cam đậm
        ],
      ),
      // Gradient cho hạng 2 (Bạc)
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE0E0E0), // Xám nhạt
          Color(0xFFC0C0C0), // Bạc
          Color(0xFF9E9E9E), // Xám đậm
        ],
      ),
      // Gradient cho hạng 3 (Đồng)
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFD7CCC8), // Nâu nhạt
          Color(0xFFB87333), // Đồng
          Color(0xFF795548), // Nâu đậm
        ],
      ),
    ];

    return SizedBox(
      width: 100, // Đảm bảo chiều rộng cố định
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar và huy hiệu
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 30, // Giảm kích thước avatar
                backgroundImage:
                    user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : const AssetImage("assets/icons/logo.png")
                            as ImageProvider,
              ),
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    gradient: gradients[rank - 1],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Tên
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Điểm
          Text(
            "${user.totalPoint} điểm",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          // Bục podium
          Container(
            width: 60, // Giảm chiều rộng bục
            height: height, // Chiều cao bục
            decoration: BoxDecoration(
              gradient: gradients[rank - 1],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị từng người dùng trong danh sách
class RankingItem extends StatelessWidget {
  final User user;
  final int rank;

  const RankingItem({super.key, required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "#$rank",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundImage:
                  user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : const AssetImage("assets/icons/logo.png")
                          as ImageProvider,
            ),
          ],
        ),
        title: Text(user.name),
        subtitle: Text("${user.totalPoint} điểm"),
        //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        // onTap: () {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Xem chi tiết: ${user.nickname}")),
        //   );
        // },
      ),
    );
  }
}
