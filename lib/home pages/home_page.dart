import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';
import 'package:fish_cab/home%20pages/map_ongoing.dart';
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
  List<String> sellers = [];
  bool _isLoaded = false;

  @override
  void initState() {
    getSellerList();
    super.initState();
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

  getSellerList() async {
    QuerySnapshot querySnapshot_Orders = await FirebaseFirestore.instance
        .collection("orders")
        .where("userID", isEqualTo: user?.uid)
        .where("isConfirmed", isEqualTo: "unconfirmed")
        .get();

    List<dynamic> orderData = querySnapshot_Orders.docs.map((doc) => doc.data()).toList();
    List<String> sellerData = [];
    for (var data in orderData) {
      sellerData.add(data["sellerID"]);
    }

    setState(() {
      sellers = sellerData;
      _isLoaded = true;
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
            children: snapshot.data!.docs.map((document) => _buildSellerItem(document)).toList(),
          );
        });
  }

  Widget _buildSellerItem(DocumentSnapshot document) {
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
                return Container(
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Text(sellerName),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MapOngoingPage(sellerId: document.id)));
                        },
                        child: const Text('Track'))
                  ]),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: const Text('Loading...'),
                );
              }
            }),
      );
    }

    return SizedBox.shrink();
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 10.0),
            child: AppBar(
              title: const Text("Home"),
              backgroundColor: Colors.white,
              shadowColor: Colors.transparent,
              titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
              actions: [
                IconButton(
                  onPressed: () => signUserOut(context), // Pass the context to the function
                  icon: const Icon(Icons.logout, color: Colors.blue),
                ),
              ],
            ),
          ),
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
            const Padding(
              padding: EdgeInsets.all(25.0),
              child: Text(
                'To get started, search for sellers via the search function or through the map.\n\nCommunicate with sellers through chats.\n\nView your orders through the orders tab.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/chatmvc');
                },
                child: const Text('Chat screen mvc test')),
            _isLoaded ? Expanded(child: _buildSellerList()) : Text("Loading"),
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
                Navigator.pushReplacementNamed(context, '/search');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/map');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/chats');
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/orders');
                break;
            }
          },
        ),
      ),
    );
  }
}
