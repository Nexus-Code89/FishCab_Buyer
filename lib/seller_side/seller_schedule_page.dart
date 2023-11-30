import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class SellerSchedulePage extends StatelessWidget {
  final String sellerId;

  SellerSchedulePage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is the Schedule Page for Seller: $sellerId'),
            // Add your form or input fields for schedule updates here
          ],
        ),
      ),
      bottomNavigationBar: SellerNavBar(
        currentIndex: 2, // Set the default selected index
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
