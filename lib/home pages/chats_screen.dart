import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/home%20pages/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';

class ChatsScreen extends StatefulWidget {
  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // get instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').orderBy('firstName').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            if (snapshot.hasData) {
              return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 10);
                  },
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatsPage(receiverUserEmail: data['email'], receiverUserID: data.id)));
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          //backgroundImage: NetworkImage(data['profileUrl']),
                        ),
                        title: Text(data['firstName'] + ' ' + data['lastName']));
                  });
            } else {
              return Text('Ongoing');
            }
          }),
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
              // Navigate to OrdersScreen
              Navigator.pushReplacementNamed(context, '/orders');
              break;
          }
        },
      ),
    );
  }
}
