import 'package:firebase_auth/firebase_auth.dart';

class RegisterModel {
  final FirebaseAuth _auth;

  // Named Constructor
  RegisterModel(this._auth);

  // Factory method to use default instance
  factory RegisterModel.fromDefaultInstance() {
    return RegisterModel(FirebaseAuth.instance);
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}
