import 'package:flutter/material.dart';

class SellerNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  SellerNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Fish Options',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat), // Added chat icon
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Order',
        ),
      ],
      // selectedLabelStyle: TextStyle(color: Colors.blue),
      // unselectedLabelStyle: TextStyle(color: Colors.grey),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      iconSize: 30,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
