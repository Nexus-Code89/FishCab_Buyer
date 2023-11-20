import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications Screen'),
      ),
      body: Center(
        child: Text('You are on the Notifications Screen!'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
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
            case 2:
              // Navigate to ChatsScreen
              Navigator.pushReplacementNamed(context, '/chats');
              break;
          }
        },
      ),
    );
  }
}


