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
        currentIndex: 4, // Set the default selected index
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/chats');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/notifications');
              break;
          }
        },
      ),
    );
  }
}
