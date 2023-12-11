import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/seller_pages/seller_search_singleton.dart';
import 'package:flutter/material.dart';

class SellerProfileView extends StatelessWidget {
  final String userId;
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  SellerProfileView({Key? key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Update the userId in SellerSingleton
    SellerSeacrhSingleton.instance.userId = userId;

    // Automatically navigate to the seller home screen
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/seller_home_view');
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Seller Profile"),
            toolbarHeight: 80,
            titleSpacing: 20,
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle:
                const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
          ),
        ),
      ),
      body: Container(), // You can customize this part if needed
    );
  }
}
