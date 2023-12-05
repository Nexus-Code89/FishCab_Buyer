import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class SellerHomePage extends StatefulWidget {
  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign user out method
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacementNamed(context, '/auth'); // Navigate to AuthPage
    }).catchError((error) {
      // Handle error, if any
      print("Error signing out: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      // Add a WillPopScope to handle the Android back button
      onWillPop: () async {
        // Handle the back button press
        if (Navigator.of(context).canPop()) {
          // If there are screens to pop, pop the current screen
          Navigator.of(context).pop();
          return false; // Return false to prevent the app from closing
        } else {
          return true; // Allow the app to close if there are no screens to pop
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => signUserOut(context), // Pass the context to the function
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      "Welcome, " + snapshot.data!['firstName'] + ' ' + snapshot.data!['lastName'] + '!',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                'To get started, set up your fish options.\n\nYou can modify your route & schedule time through the schedule tab.\n\nCommunicate with buyers through chats.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
        bottomNavigationBar: SellerNavBar(
          currentIndex: 0, // Set the default selected index
          onTap: (index) {
            // Handle item taps here, based on the index
            switch (index) {
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
      ),
    );
  }
}
