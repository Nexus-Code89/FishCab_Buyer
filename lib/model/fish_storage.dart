import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FishStorage {
  final String sellerId;
  final String fishName;
  final String photoUrl;
  final double price; 

  FishStorage(
      {required this.sellerId,
      required this.fishName,
      required this.photoUrl,
      required this.price});

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'fishName': fishName,
      'photoUrl': photoUrl,
      'price': price,
    };
  }
}
