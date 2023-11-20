import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/aunthentication%20pages/login_model.dart';
import 'package:flutter/material.dart';

// Controller
class LoginController {
  final LoginModel _loginModel;

  // Constructor
  LoginController(this._loginModel);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void signIn(BuildContext context) async {
    try {
      await _loginModel.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navigate to the next page or perform any other action upon successful login
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
