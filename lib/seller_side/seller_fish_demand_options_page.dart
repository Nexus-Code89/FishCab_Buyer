import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class FishDemandOptionsPage extends StatelessWidget {
  final String sellerId;

  FishDemandOptionsPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Fish Demands'),
        toolbarHeight: 80,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FishOptionsList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Navigate to AddFishOptionPage
                    Navigator.pushNamed(context, '/add_fish_demand_option', arguments: sellerId);
                  },
                  tooltip: 'Add Fish Option',
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FishOptionsList extends StatelessWidget {
  final String sellerId;

  FishOptionsList() : sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('seller_info').doc(sellerId).collection('fish_demand_choices').snapshots(),
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
    print('Number of fish choices: ${fishChoices.length}');
    return ListView.builder(
      itemCount: fishChoices.length,
      itemBuilder: (context, index) {
        final fishOptionData = fishChoices[index].data() as Map<String, dynamic>?;

        if (fishOptionData != null) {
          final photoUrl = fishOptionData['photoUrl'] as String?;
          final fishName = fishOptionData['fishName'] as String?;
          final price = fishOptionData['price'] as num?;

          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(photoUrl ?? ''),
              ),
              title: Text(
                fishName ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '\$$price',
                style: TextStyle(fontSize: 16),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  // Call a function to delete the fish option
                  _deleteFishOption(fishChoices[index].reference);
                },
              ),
              onTap: () {
                // TODO: Handle tap on fish option
              },
            ),
          );
        }

        return Container(); // or any other fallback for null or incomplete data
      },
    );
  }

  // Function to delete a fish option
  Future<void> _deleteFishOption(DocumentReference fishOptionRef) async {
    try {
      await fishOptionRef.delete();
      // Optionally, update the UI to reflect the deletion
    } catch (e) {
      print('Error deleting fish option: $e');
    }
  }
}
