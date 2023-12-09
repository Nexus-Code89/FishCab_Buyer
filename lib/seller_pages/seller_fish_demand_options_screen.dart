import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/home%20pages/demand_page.dart';
import 'package:fish_cab/model/demand_ballot.dart';
import 'package:fish_cab/seller_pages/seller_navigation_bar.dart';
import 'package:flutter/material.dart';

class FishDemandOptionsScreen extends StatefulWidget {
  final String sellerId;

  FishDemandOptionsScreen({required this.sellerId});

  @override
  _FishDemandOptionsScreenState createState() => _FishDemandOptionsScreenState();
}

class _FishDemandOptionsScreenState extends State<FishDemandOptionsScreen> {
  DemandStorage mydemandStorage = DemandStorage();
  late final String userId;
  late FirebaseAuth _firebaseAuth; // Declare _firebaseAuth as a late variable

  @override
  void initState() {
    super.initState();
    _firebaseAuth = FirebaseAuth.instance;
    userId = _firebaseAuth.currentUser!.uid; // Initialize userId in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Demand Options'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FishDemandOptionsList(sellerId: widget.sellerId, demand: mydemandStorage),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to DemandPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DemandPage(demandStorage: mydemandStorage, sellerID: widget.sellerId, userID: userId),
            ),
          );
        },
        tooltip: 'View Demand',
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.how_to_vote),
      ),
      bottomNavigationBar: SellerNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home_view');
              break;
            case 2:
              // Navigate to Schedule Page
              Navigator.pushReplacementNamed(context, '/seller_schedule_view');
              break;
          }
        },
      ),
    );
  }
}

class FishDemandOptionsList extends StatefulWidget {
  final String sellerId;
  final DemandStorage demand;

  FishDemandOptionsList({required this.sellerId, required this.demand});

  @override
  State<FishDemandOptionsList> createState() => _FishOptionsListState();
}

class _FishOptionsListState extends State<FishDemandOptionsList> {
  int selectedQuantity = 1;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('seller_info').doc(widget.sellerId).collection('fish_demand_choices').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        final fishChoices = snapshot.data!.docs;

        return _buildFishOptionsList(fishChoices);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text('Error fetching fish options: $error'),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFishOptionsList(List<DocumentSnapshot> fishChoices) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: fishChoices.length,
      itemBuilder: (context, index) {
        final fishOptionData = fishChoices[index].data() as Map<String, dynamic>?;

        if (fishOptionData != null) {
          // final photoUrl = fishOptionData['photoUrl'] as String?;
          final fishName = fishOptionData['fishName'] as String?;
          final price = fishOptionData['price'] as num?;
          //photoUrl != null &&
          if (fishName != null && price != null) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 3,
                child: Column(
                  children: [
                    // Fish photo
                    Container(
                      height: 64,
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     image: NetworkImage(photoUrl),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),

                    // Fish name
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        fishName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Fish price (pressable, hoverable, and color change)
                    GestureDetector(
                      onTap: () {
                        _showDemandConfirmationDialog(context, fishName, price);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue, // Set the initial color
                        ),
                        child: Text(
                          '\₱$price',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return Container(); // or any other fallback for null or incomplete data
      },
    );
  }

  Future<void> _showDemandConfirmationDialog(BuildContext context, String fishName, num price) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Demand Confirmation'),
          content: Text('Do you want to demand $fishName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel demand
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add the demand to the list
                DemandItem newDemand = DemandItem(fishName: fishName);
                widget.demand.addDemand(newDemand);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

