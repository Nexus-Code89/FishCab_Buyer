import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/aunthentication%20pages/register_model.dart';
import 'package:flutter/material.dart';

class RegisterController {
  final RegisterModel _registerModel;

  // Constructor
  RegisterController(this._registerModel);

  // call instance getter on FireStore to interact with it
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  void signUp(BuildContext context) async {
    try {
      // // check if password is confirmed
      // if (passwordController.text == confirmPasswordController.text) {
      // create credentials and return the created credetnial
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      User? user = result.user;

      // insert user information in the firestore
      final data = {
        "id": user?.uid,
        "email": emailController.text,
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "type": "buyer"
      };
      firestore.collection("users").doc(user?.uid).set(data, SetOptions(merge: true));
      // } else {
      //   // show error message, passwords don't match
      //   showErrorMessage(context, "Passwords don't match");
      // }
    } on FirebaseAuthException catch (e) {
      // show error message
      showErrorMessage(context, e.code);
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }
}
