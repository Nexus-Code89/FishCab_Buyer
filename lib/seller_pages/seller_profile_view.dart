import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/seller_pages/seller_singleton.dart';
import 'package:flutter/material.dart';

class SellerProfileView extends StatelessWidget {
  final String userId;
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  SellerProfileView({Key? key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Update the userId in SellerSingleton
    SellerSingleton.instance.userId = userId;

    // Automatically navigate to the seller home screen
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/seller_home');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Profile'),
      ),
      body: Container(), // You can customize this part if needed
    );
  }
}

