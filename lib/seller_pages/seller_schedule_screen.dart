import 'package:fish_cab/seller_pages/seller_navigation_bar.dart';
import 'package:flutter/material.dart';

class SellerScheduleScreen extends StatelessWidget {
  final String sellerId;

  SellerScheduleScreen({required this.sellerId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedules'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Welcome to the Schedule Page!'),
      ),
      bottomNavigationBar: SellerNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home');
              break;
            case 1:
              // Navigate to Fish Options Page
              Navigator.pushReplacementNamed(context, '/seller_fish_options');
              break;
          }
        },
      ),
    );
  }
}
