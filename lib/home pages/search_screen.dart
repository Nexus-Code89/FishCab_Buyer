import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
        title: Text('Search Screen'),
      ),
      body: Center(
        child: Text('This is the Search Screen!'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
          case 0:
            // Navigate to HomeScreen
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 2:
            // Navigate to ChatsScreen
            Navigator.pushReplacementNamed(context, '/chats');
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
