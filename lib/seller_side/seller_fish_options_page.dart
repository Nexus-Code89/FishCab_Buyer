import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class FishOptionsPage extends StatelessWidget {
  final String sellerId;

  FishOptionsPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Options Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FishOptionsList(sellerId: sellerId),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Navigate to AddFishOptionPage
                    Navigator.pushNamed(context, '/add_fish_option', arguments: sellerId);
                  },
                  tooltip: 'Add Fish Option',
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SellerNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/seller_home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/seller_schedule');
              break;
            // No case for 3 here
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance // firebase data navigation
          .collection('seller_info')
          .doc(sellerId)
          .collection('fish_choices')
          .doc('Fx9Cofjg8lGNA8CLdA1L') 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching fish options'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var fishOptionsData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> fishOptions = fishOptionsData['fish_options'];

        return ListView.builder(
          itemCount: fishOptions.length,
          itemBuilder: (context, index) {
            var fishOption = fishOptions[index] as Map<String, dynamic>;

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(fishOption['photo']),
                ),
                title: Text(
                  fishOption['fish'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '\$${fishOption['price']}',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  // TODO: Handle tap on fish option
                },
              ),
            );
          },
        );
      },
    );
  }
}
