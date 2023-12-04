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
      body: Center(
        child: Text(
          user != null ? "LOGGED IN AS: ${user?.email}" : "NOT LOGGED IN",
          style: TextStyle(fontSize: 20),
        ),
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
            /*case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/chats');
              break;*/
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