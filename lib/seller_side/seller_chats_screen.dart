import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:fish_cab/seller_side/seller_chats_page.dart';
import 'package:flutter/material.dart';

class SellerChatsScreen extends StatefulWidget {
  @override
  _SellerChatsScreenState createState() => _SellerChatsScreenState();
}

class _SellerChatsScreenState extends State<SellerChatsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // get instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Chats"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('users').where('type', isEqualTo: 'buyer').orderBy('firstName').snapshots(),
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
                                  builder: (context) =>
                                      SellerChatsPage(receiverUserEmail: data['email'], receiverUserID: data.id)));
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
      bottomNavigationBar: SellerNavBar(
        currentIndex: 3, // Set the default selected index
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
            case 2:
              // Navigate to Schedule Page
              Navigator.pushReplacementNamed(context, '/seller_schedule');
              break;
            case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/seller_chats');
              break;
            case 4:
              // Navigate to Orders Page
              Navigator.pushReplacementNamed(context, '/seller_orders');
              break;
          }
        },
      ),
    );
  }
}
