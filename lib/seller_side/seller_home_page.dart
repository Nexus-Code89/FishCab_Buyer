import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fish_cab/api/firebase_api.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:fish_cab/seller_side/seller_map_page.dart';
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
      _isLoading = false;
    });
  }

  // sign user out method
  void signUserOut(BuildContext context) async {
    FirebaseAuth.instance.signOut().then((_) async {
      // Navigate to AuthPage
      FirebaseMessaging.instance.deleteToken;
      await FirebaseFirestore.instance.collection("tokens").doc(user?.uid).delete().then((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SafeArea(
              child: Container(
                color: Colors.blue[300],
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => signUserOut(context), // Pass the context to the function
                            icon: const Icon(Icons.logout, color: Colors.white),
                          ),
                          FutureBuilder(
                            future: _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text(
                                    snapshot.data!['firstName'] + ' ' + snapshot.data!['lastName'],
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Montserrat'),
                                  ),
                                );
                              } else {
                                return const Text(
                                  'Loading...',
                                  style: TextStyle(fontFamily: 'Montserrat'),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Container(
                          width: 450,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 5,
                                offset: Offset(0, 0), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () async {
                              routeStarted = true;

                              await _firestore
                                  .collection('seller_info')
                                  .doc(user?.uid)
                                  .set({'routeStarted': true}, SetOptions(merge: true));

                              QuerySnapshot querySnapshot_Orders = await FirebaseFirestore.instance
                                  .collection("orders")
                                  .where("sellerID", isEqualTo: user?.uid)
                                  .where("isConfirmed", isEqualTo: "unconfirmed")
                                  .get();

                              if (querySnapshot_Orders.size != 0) {
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
                              }

                              Navigator.push(context, MaterialPageRoute(builder: (context) => SellerMapPage()));
                            },
                            child: Text("Start Route",
                                style: TextStyle(
                                    color: Colors.blue, fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 15)),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade100,
              ),
              padding: EdgeInsets.all(30),
              width: 350,
              child: const Column(
                children: [
                  Text(
                    'Welcome to Fish Cab!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'To get started, set up your fish options and schedule.\n\nCommunicate through chats and view orders through the orders tab.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'lib/images/fish_options.png',
                  ),
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  opacity: 0.2,
                ),
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade100,
              ),
              padding: EdgeInsets.all(30),
              width: 350,
              child: Column(
                children: [
                  Text(
                    'Edit your fish options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Let customers know what\'s up for sale',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
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
