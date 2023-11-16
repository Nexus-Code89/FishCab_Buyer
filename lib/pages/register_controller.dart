import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/pages/register_model.dart';
import 'package:flutter/material.dart';

class RegisterController {
  final RegisterModel _registerModel;

  // Constructor
  RegisterController(this._registerModel);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void signUp(BuildContext context) async {
    try {
      // Check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        await _registerModel.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
        // Navigate to the next page or perform any other action upon successful registration
      } else {
        // Show error message, passwords don't match
        showErrorMessage(context, "Passwords don't match");
      }
    } on FirebaseAuthException catch (e) {
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
