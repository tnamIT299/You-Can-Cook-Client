import 'package:flutter/material.dart';
import 'package:you_can_cook/screens/Main/sub_tab/chefsTabSearch.dart';
import 'package:you_can_cook/screens/Main/sub_tab/recipesTabSearch.dart';
import 'package:you_can_cook/screens/Main/sub_tab/tagTabSearch.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dữ liệu giả cho Recipes
  final List<Map<String, dynamic>> recipes = [
    {"title": "Chocolate cake with buttercream frosting", "rating": 4.8, "image": "assets/icons/logo.png"},
    {"title": "Chocolate cake with buttercream frosting", "rating": 4.8, "image": "assets/icons/logo.png"},
    {"title": "Chocolate cake with buttercream frosting", "rating": 4.8, "image": "assets/icons/logo.png"},
    {"title": "Chocolate cake with buttercream frosting", "rating": 4.8, "image": "assets/icons/logo.png"},
    {"title": "Chocolate cake with buttercream frosting", "rating": 4.8, "image": "assets/icons/logo.png"},
  ];

  // Dữ liệu giả cho Chefs
  final List<Map<String, dynamic>> chefs = [
    {"name": "Chef John", "rating": 4.9, "image": "assets/icons/logo.png"},
    {"name": "Chef Maria", "rating": 4.7, "image": "assets/icons/logo.png"},
  ];

  // Dữ liệu giả cho Tags
  final List<String> tags = ["#baking", "#dessert", "#chocolate", "#cake"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFEEA734),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Tìm kiếm",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: const Icon(Icons.mic, color: Colors.black),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: "Recipes"),
              Tab(text: "Chefs"),
              Tab(text: "Tags"),
            ],
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Recipes Tab
                RecipesTabSearch(recipes: recipes),
                // Chefs Tab
                ChefsTabSearch(chefs: chefs),
                // Tags Tab
                TagTabSearch(tags: tags),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





