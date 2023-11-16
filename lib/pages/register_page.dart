import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/components/my_textfield.dart';
import 'package:fish_cab/components/square_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // call instance getter on FireStore to interact with it
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sign user up method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      // check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        // create credentials and return the created credetnial
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        User? user = result.user;

        // insert user information in the firestore
        final data = {
          "email": emailController.text,
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "type": "buyer"
        };
        firestore.collection("users").doc(user?.uid).set(data, SetOptions(merge: true));
      } else {
        // show error message, passwords don't match
        showErrorMessage("Passwords don't match");
      }

      // pop loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      Navigator.pop(context);
      // show error message
      showErrorMessage(e.code);
    }
  }

  // error message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('lib/images/bg.png'), fit: BoxFit.cover)),
        child: SafeArea(
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),

                // Sign Up
                Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Image.asset(
                //   'lib/images/logo.png',
                //   width: 100,
                //   height: 100,
                // ),

                // const SizedBox(height: 50),

                // // let's create an account for you!
                // Text(
                //   'Let\'s create an account for you!',
                //   style: TextStyle(
                //     color: Colors.grey[700],
                //     fontSize: 16,
                //   ),
                // ),

                const SizedBox(height: 25),

                // firstname textfield
                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // last name textfield
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign up button
                MyButton(
                  onTap: signUserUp,
                  text: "Sign Up",
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
        ),
      ),
    );
  }
}
