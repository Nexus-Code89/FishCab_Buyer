import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'seller_navigation_bar.dart';

class SellerHomeScreen extends StatelessWidget {
  final String userId;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  SellerHomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading seller details'),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            Map<String, dynamic> sellerData = snapshot.data!.data() as Map<String, dynamic>;

            String sellerName = sellerData['firstName'] ?? 'Unknown';
            String sellerEmail = sellerData['email'] ?? 'Unknown';

            return Scaffold(
              appBar: AppBar(
                title: Text('Seller Profile'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      // Set the background image using the fetched seller's profile URL
                      // backgroundImage: NetworkImage(sellerProfileImageUrl),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Seller Name: $sellerName',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: $sellerEmail',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SellerNavigationBar(
                currentIndex: 0,
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
                  }
                },
              ),
            );
          } else {
            return Center(
              child: Text('Seller data not found'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
