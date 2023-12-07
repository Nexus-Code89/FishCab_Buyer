import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/api/firebase_api.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class SellerHomePage extends StatefulWidget {
  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _isLoading = true;
  bool routeStarted = true;
  String buttonText = "Loading...";

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getRouteStatus();
  }

  getRouteStatus() async {
    DocumentSnapshot sellerInfo = await _firestore.collection('seller_info').doc(user?.uid).get();
    var data = sellerInfo.data() as Map;

    setState(() {
      routeStarted = data['routeStarted'];
      buttonText = routeStarted ? "Finish route" : "Start route";
      _isLoading = false;
    });
  }

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
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Text(
                      '${"Welcome, " + snapshot.data!['firstName'] + ' ' + snapshot.data!['lastName']}!',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  );
                } else {
                  return const Text('Loading...');
                }
              },
            ),
            // placeholder text
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text(
                'To get started, set up your fish options.\n\nYou can modify your route & schedule time through the schedule tab.\n\nCommunicate with buyers through chats.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),

            // start route button
            ElevatedButton(
                style: ButtonStyle(minimumSize: MaterialStateProperty.all(Size(200, 80))),
                onPressed: routeStarted
                    ? () async {
                        routeStarted = false;
                        setState(() {
                          buttonText = "Start Route";
                        });

                        await _firestore
                            .collection('seller_info')
                            .doc(user?.uid)
                            .set({'routeStarted': false}, SetOptions(merge: true));
                      }
                    : () async {
                        routeStarted = true;

                        setState(() {
                          buttonText = "Finish Route";
                        });

                        await _firestore
                            .collection('seller_info')
                            .doc(user?.uid)
                            .set({'routeStarted': true}, SetOptions(merge: true));
                        QuerySnapshot querySnapshot_Orders = await FirebaseFirestore.instance
                            .collection("orders")
                            .where("sellerID", isEqualTo: user?.uid)
                            .where("isConfirmed", isEqualTo: "unconfirmed")
                            .get();

                        List<dynamic> buyersData = querySnapshot_Orders.docs.map((doc) => doc.data()).toList();
                        List<String> buyers = [];

                        for (var data in buyersData) {
                          buyers.add(data["userID"]);
                        }

                        QuerySnapshot querySnapshot_Tokens = await FirebaseFirestore.instance
                            .collection("tokens")
                            .where(FieldPath.documentId, whereIn: buyers)
                            .get();

                        List<dynamic> allData = querySnapshot_Tokens.docs.map((doc) => doc.data()).toList();

                        DocumentSnapshot currentUserDataSnapshot =
                            await FirebaseFirestore.instance.collection("users").doc(user?.uid).get();

                        for (var data in allData) {
                          FirebaseApi().sendPushMessage(
                              "Seller ${currentUserDataSnapshot.get('firstName')} ${currentUserDataSnapshot.get('lastName')} has started route",
                              "Fresh fish is on its way!",
                              data!['token']!);
                        }
                      },
                child: Text(buttonText, style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'))),
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
