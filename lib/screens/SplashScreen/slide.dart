import 'package:flutter/material.dart';

// Slide 1: Welcome
class WelcomeSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildSlide(
        imageAsset: 'assets/images/bibimbap.png',
        title: 'Welcome',
        subtitle:
            'It\'s a pleasure to meet you. We are excited that you\'re here! So let\'s get started',
        backgroundColor: Color(0xfffcd9bc),
      ),
    );
  }
}

// Slide 2: All your favorites
class FavoritesSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildSlide(
        imageAsset: 'assets/images/hot-pot.png',
        title: 'All your favorites',
        subtitle:
            'Order from the best local restaurants with on-demand delivery.',
        backgroundColor: Color(0xfffcd9bc),
      ),
    );
  }
}

// Slide 3: Free delivery offers
class DeliverySlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildSlide(
        imageAsset: 'assets/images/pizza.png',
        title: 'Free delivery offers',
        subtitle:
            'Free delivery for new customers via Apple Pay and other payment methods.',
        backgroundColor: Color(0xfffcd9bc),
      ),
    );
  }
}

// Slide 4: Choose your food
class FoodChoiceSlide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildSlide(
        imageAsset: 'assets/images/ramen.png',
        title: 'Choose your food',
        subtitle:
            'Easily find your type of food craving and you\'ll get delivery in wide range.',
        backgroundColor: Color(0xfffcd9bc),
      ),
    );
  }
}

Widget _buildSlide({
  required String imageAsset,
  required String title,
  required String subtitle,
  required Color backgroundColor,
}) {
  return Container(
    color: backgroundColor,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/logo.png',
          height: 220,
          width: 220,
        ),
        SizedBox(height: 10),
       
        Image.asset(imageAsset, height: 150, width: 150),
        SizedBox(height: 20),
        
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
       
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      ],
    ),
  );
}
