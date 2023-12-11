import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';
import 'package:fish_cab/home%20pages/map_ongoing.dart';
import 'package:fish_cab/home%20pages/search_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> sellers = {};

  @override
  void initState() {
    super.initState();
    getSellerList();
  }

  getSellerList() async {
    QuerySnapshot querySnapshot_Orders = await FirebaseFirestore.instance
        .collection("orders")
        .where("userID", isEqualTo: user?.uid)
        .where("isConfirmed", isEqualTo: "unconfirmed")
        .get();

    List<dynamic> orderData = querySnapshot_Orders.docs.map((doc) => doc.data()).toList();
    Set<String> sellersData = {};

    for (var data in orderData) {
      sellersData.add(data["sellerID"]);
    }

    setState(() {
      sellers = sellersData;
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

  Widget _buildSellerList() {
    return StreamBuilder(
        stream: _firestore.collection('seller_info').where('routeStarted', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data!.docs.map((document) => _buildSellerItem(document)).toList(),
          );
        });
  }

  Widget _buildSellerItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    if (sellers.contains(document.id)) {
      return Container(
        // TO DO: change email to name
        alignment: Alignment.center,
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').doc(document.id).get(),
            builder: (context, snapshot) {
              String sellerName = '';
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(
                    child: Text('Error loading user data'),
                  );
                } else {
                  Map<String, dynamic> sellerData = snapshot.data!.data() as Map<String, dynamic>;
                  sellerName = sellerData['firstName'] + ' ' + sellerData['lastName']; // Get type
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      Text(
                        sellerName,
                        style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => MapOngoingPage(sellerId: document.id)));
                          },
                          child: const Text('Track'))
                    ]),
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Text('Loading...'),
                );
              }
            }),
      );
    } else {
      return SizedBox.shrink();
    }
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
                      TextField(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/search');
                        },
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_outlined),
                            prefixIconColor: Colors.grey[400],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(255, 232, 232, 232)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Search for something...',
                            hintStyle: TextStyle(
                                color: Colors.grey[400], fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
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
                    'To get started, search for sellers via the search function or through the map.\n\nCommunicate through chats and view your orders through the orders tab.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Sellers En Route',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                width: 350,
                height: 120,
                child: _buildSellerList()),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 0, // Set the default selected index
          onTap: (index) {
            // Handle item taps here, based on the index
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/map');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/chats');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/orders');
                break;
            }
          },
        ),
      ),
    );
  }
}
