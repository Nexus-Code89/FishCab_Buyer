import 'package:firebase_auth/firebase_auth.dart';

class LoginModel {
  final FirebaseAuth _auth;

  // Constructor
  LoginModel() : _auth = FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
