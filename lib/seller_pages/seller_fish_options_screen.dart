import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'seller_navigation_bar.dart';

class FishOptionsScreen extends StatelessWidget {
  final String sellerId;

  FishOptionsScreen({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Options Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FishOptionsList(sellerId: sellerId),
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

class FishOptionsList extends StatelessWidget {
  final String sellerId;

  FishOptionsList({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('seller_info')
          .doc(sellerId)
          .collection('fish_choices')
          .snapshots(),
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

        if (photoUrl != null && fishName != null && price != null) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(photoUrl),
              ),
              title: Text(
                fishName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '\$$price',
                style: TextStyle(fontSize: 16),
              ),
              // TODO: Implement onTap to show more details or perform other actions
              onTap: () {
                // TODO: Handle tap on fish option
              },
            ),
          );
        }
      }

      return Container(); // or any other fallback for null or incomplete data
    },
  );
}
}
