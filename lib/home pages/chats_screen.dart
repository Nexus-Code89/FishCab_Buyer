import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Chats Screen!'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to HomeScreen
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Navigate to SearchScreen
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 3:
              // Navigate to NotificationsScreen
              Navigator.pushReplacementNamed(context, '/notifications');
              break;
          }
        },
      ),
    );
  }
}
