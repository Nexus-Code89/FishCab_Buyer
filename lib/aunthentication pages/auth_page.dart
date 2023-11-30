import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/aunthentication%20pages/login_or_register_page.dart';
import 'package:fish_cab/seller_side/seller_home_page.dart';
import 'package:fish_cab/seller_side/seller_singleton.dart';
import 'package:flutter/material.dart';
import '../home pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            User? user = snapshot.data;
            String userId = user!.uid;

            // Access the user type from Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading user data'),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                    String userType = userData['type'] ?? ''; // Get type
                    if (userType == 'seller') {
                      // Store the userId in SellerSingleton
                    SellerSingleton.instance.userId = userId;
                      // User is a seller, navigate to SellerHomePage
                      return SellerHomePage();
                    } else {
                      // User is not a seller, navigate to regular/user home page 
                      return HomePage();
                    }
                  }
                }
                // Handle loading state
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }
          // user is NOT logged in
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
