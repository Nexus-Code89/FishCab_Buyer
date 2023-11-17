import 'package:firebase_auth/firebase_auth.dart';

class RegisterModel {
  final FirebaseAuth _auth;

  // Constructor
  RegisterModel() : _auth = FirebaseAuth.instance;

  Future<void> signUp(
      {required String email, required String password, required String firstName, required String lastName}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
