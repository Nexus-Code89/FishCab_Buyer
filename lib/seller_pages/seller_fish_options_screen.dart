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
    // TODO: Fetch actual fish options data from Firebase
    // For now, use dummy data
    List<Map<String, dynamic>> dummyFishOptions = [
      {"fish": "Salmon", "photo": "salmon.jpg", "price": 15.99},
      {"fish": "Tuna", "photo": "tuna.jpg", "price": 12.99},
      {"fish": "Cod", "photo": "cod.jpg", "price": 9.99},
    ];

    return ListView.builder(
      itemCount: dummyFishOptions.length,
      itemBuilder: (context, index) {
        var fishOption = dummyFishOptions[index];
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              // You can load the image using NetworkImage(fishOption['photo'])
              backgroundImage: AssetImage('assets/images/${fishOption['photo']}'),
            ),
            title: Text(
              fishOption['fish'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '\$${fishOption['price']}',
              style: TextStyle(fontSize: 16),
            ),
            // TODO: Implement onTap to show more details or perform other actions
            onTap: () {
              // TODO: Handle tap on fish option
            },
          ),
        );
      },
    );
  }
}
