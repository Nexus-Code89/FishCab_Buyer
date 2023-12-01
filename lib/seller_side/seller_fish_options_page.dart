import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class FishOptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Options Page'),
      ),
      body: Center(
        child: Text('Welcome to the Fish Options Page!'),
      ),
      bottomNavigationBar: SellerNavBar(
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
            /*case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/chats');
              break;*/
          }
        },
      ),
    );
  }
}
