import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/home%20pages/chats_model.dart';
import 'package:fish_cab/review-rating%20pages/make_review_screen.dart';
import 'package:fish_cab/review-rating%20pages/view_reviews_screen.dart';
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
                toolbarHeight: 80,
                titleSpacing: 20,
                backgroundColor: Colors.white,
                shadowColor: Colors.transparent,
                titleTextStyle:
                    const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewView(reviewee: userId)));
                            },
                            child: Text('Make review')),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewReviewView(reviewee: userId)));
                            },
                            child: Text('View reviews')),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatsPage(receiverUserEmail: sellerEmail, receiverUserID: userId)));
                            },
                            child: Text('Chat')),
                      ],
                    )
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
                      Navigator.pushReplacementNamed(context, '/seller_fish_options_view');
                      break;
                    case 2:
                      // Navigate to Schedule Page
                      Navigator.pushReplacementNamed(context, '/seller_schedule_view');
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
