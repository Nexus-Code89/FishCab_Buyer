import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/model/fish_storage.dart';
import 'package:flutter/material.dart';

class AddFishOptionPage extends StatelessWidget {
  final String sellerId;
  AddFishOptionPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Fish Option'),
      ),
      body: AddFishOptionForm(),
    );
  }
}

class AddFishOptionForm extends StatefulWidget {
  @override
  _AddFishOptionFormState createState() => _AddFishOptionFormState();
}

class _AddFishOptionFormState extends State<AddFishOptionForm> {
  final TextEditingController fishController = TextEditingController();
  final TextEditingController photoController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: fishController,
            decoration: InputDecoration(labelText: 'Fish Name'),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: photoController,
            decoration: InputDecoration(labelText: 'Photo URL'),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Call a function to add the fish option to Firestore
              addFishOption();
            },
            child: Text('Add Fish Option'),
          ),
        ],
      ),
    );
  }

  // Function to add the fish option to Firestore
  Future<void> addFishOption() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String sellerId = _firebaseAuth.currentUser!.uid;
    String fishName = fishController.text;
    String photoUrl = photoController.text;
    double price = double.parse(priceController.text);

    // Check if all fields are filled
    if (fishName.isNotEmpty && photoUrl.isNotEmpty) {
      // Add the fish option to Firestore

      FishStorage newfish_storage = FishStorage(sellerId: sellerId, fishName: fishName, photoUrl: photoUrl, price: price);

      await _firestore.collection('seller_info').doc(sellerId).collection('fish_choices').add(newfish_storage.toMap());

      /*FirebaseFirestore.instance
        .collection('seller_info')
        .doc(sellerId)
        .collection('fish_choices')
        .add({
      'fish': fishName,
      'photo': photoUrl,
      'price': price,
    });*/

      // Navigate back to the previous screen
      Navigator.pop(context);
    } else {
      // Show an error message or handle the case where fields are not filled
      // You can display a SnackBar or any other UI element to inform the user.
    }
  }
}
