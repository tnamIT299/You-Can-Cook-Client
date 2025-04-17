import 'package:flutter/material.dart';
import 'package:you_can_cook/models/User.dart' as userModel;
import 'package:you_can_cook/services/UserService.dart';
import 'package:you_can_cook/utils/color.dart';
import 'package:you_can_cook/screens/Main/main_tab/profile_tab.dart';

class ChefsTabSearch extends StatefulWidget {
  final String searchQuery;

  const ChefsTabSearch({super.key, required this.searchQuery});

  @override
  _ChefsTabSearchState createState() => _ChefsTabSearchState();
}

class _ChefsTabSearchState extends State<ChefsTabSearch> {
  final UserService _userService = UserService();
  List<userModel.User> topChefs = []; // 5 đầu bếp đề xuất
  List<userModel.User> allChefs = []; // Toàn bộ người dùng
  List<userModel.User> filteredChefs = []; // Danh sách hiển thị
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Lấy dữ liệu ban đầu
  }

  @override
  void didUpdateWidget(covariant ChefsTabSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _filterChefs(); // Lọc lại khi searchQuery thay đổi
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final topChefsResult = await _userService.get5UserMaxFolllwer();
      final allChefsResult = await _userService.getAllUsers();
      setState(() {
        topChefs = topChefsResult;
        allChefs = allChefsResult;
        filteredChefs = topChefs;
        isLoading = false;
      });
      _filterChefs();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  // Lọc danh sách dựa trên searchQuery
  void _filterChefs() {
    if (widget.searchQuery.isEmpty) {
      setState(() {
        filteredChefs = topChefs;
      });
      return;
    }

    final query = widget.searchQuery.toLowerCase();
    setState(() {
      filteredChefs =
          allChefs.where((chef) {
            final name = (chef.name).toLowerCase();
            final nickname = (chef.nickname ?? '').toLowerCase();
            return name.contains(query) || nickname.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredChefs.isEmpty) {
      return const Center(child: Text("Không tìm thấy đầu bếp nào phù hợp."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: filteredChefs.length,
      itemBuilder: (context, index) {
        final chef = filteredChefs[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileTab(userId: chef.uid),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundImage:
                chef.avatar != null
                    ? NetworkImage(chef.avatar!)
                    : const AssetImage("assets/icons/logo.png")
                        as ImageProvider,
          ),
          title: Text(chef.nickname ?? chef.name),
          subtitle: Row(
            children: [
              const Icon(Icons.groups, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                "${chef.follower ?? 0} người theo dõi",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
