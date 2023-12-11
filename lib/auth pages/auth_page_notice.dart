import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthNoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAccountBannedDialog(context));
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication Notice'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          showAccountBannedDialog(context);
        },
        child: Center(
        child: Text(''),
      ),
      )
    );
  }
    void showAccountBannedDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Notice'),
            content: Text('Account has been banned. Please contact admin'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                  signUserOut(context);
                },
                child: Text('confirm'),
              ),
            ],
          );
        },
      );
    }

    Future<void> signUserOut(BuildContext context) async {
      try {
        await FirebaseAuth.instance.signOut();
        //Navigator.pushReplacementNamed(context, Routes.auth); // Redirect to the login page
      } catch (error) {
        // Handle error
        print("Error signing out: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out. Please try again.'),
          ),
        );
      }
    }
}