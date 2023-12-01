import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/model/fish_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFishOptionPage extends StatelessWidget {
  final String sellerId;
  AddFishOptionPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Fish Option'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddFishOptionForm(),
      ),
    );
  }
}

class AddFishOptionForm extends StatefulWidget {
  @override
  _AddFishOptionFormState createState() => _AddFishOptionFormState();
}

class _AddFishOptionFormState extends State<AddFishOptionForm> {
  final TextEditingController fishController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: fishController,
          decoration: InputDecoration(
            labelText: 'Fish Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // Call function to pick image
            await _pickImage();
          },
          child: Text('Pick Image'),
        ),
        _pickedImage != null
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_pickedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(),
        TextFormField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
            prefix: Text('\$'),
          ),
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
    );
  }

  // Function to add the fish option to Firestore
  void addFishOption() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String sellerId = _firebaseAuth.currentUser!.uid;
    String fishName = fishController.text;
    double price = double.parse(priceController.text);

    // Check if all fields are filled
    if (fishName.isNotEmpty && _pickedImage != null) {
      // Upload image to Firebase Storage
      String imageUrl = await uploadImage(_pickedImage!);
      
      // create FishStorage
      /*FishStorage newfish_storage= FishStorage(sellerId: sellerId, fishName: fishName, photoUrl: imageUrl, price: price);

      await _firestore.collection('seller_info').doc(sellerId).collection('fish_choices').add(newfish_storage.toMap());*/
      // Add the fish option to Firestore with the image URL
      FirebaseFirestore.instance
          .collection('seller_info')
          .doc(sellerId)
          .collection('fish_choices')
          .add({
        'fish': fishName,
        'photo': imageUrl,
        'price': price,
      });

      // Navigate back to the previous screen
      Navigator.pop(context);
    } else {
      // Show an error message or handle the case where fields are not filled
      // You can display a SnackBar or any other UI element to inform the user.
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedImage = await _picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      String filePath = 'images/${DateTime.now()}.png'; // Adjust the path as needed
      firebase_storage.Reference storageReference =
          firebase_storage.FirebaseStorage.instance.ref().child(filePath);
      await storageReference.putFile(imageFile);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      // Handle the error (display an error message or throw the exception)
      throw Exception('Failed to upload image');
    }
  }
}
