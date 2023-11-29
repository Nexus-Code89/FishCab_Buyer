import 'package:fish_cab/seller_pages/seller_navigation_bar.dart';
import 'package:flutter/material.dart';

class FishOptionsScreen extends StatelessWidget {
  final String sellerId;

  FishOptionsScreen({required this.sellerId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Options Page'),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Welcome to the Fish Options Page!'),
      ),
      bottomNavigationBar: SellerNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home');
              break;
            case 2:
              // Navigate to Schedule Page
              Navigator.pushReplacementNamed(context, '/seller_schedule');
              break;
          }
        },
      ),
    );
  }
}

