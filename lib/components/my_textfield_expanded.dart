import 'package:flutter/material.dart';

class MyTextFieldExpanded extends StatelessWidget {
  final Function(String)? onChanged;
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextFieldExpanded({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 232, 232, 232)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
      ),
    );
  }
}
