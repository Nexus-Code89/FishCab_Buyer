import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/model/shopping_cart.dart';

class Orders {
  String documentID;
  String sellerID;
  String userID;
  String isConfirmed;
  String status;
  List<CartItem> items;
  double totalPrice;
  Timestamp timestamp;

  Orders({
    required this.documentID,
    required this.sellerID,
    required this.userID,
    required this.isConfirmed,
    required this.status,
    required this.items,
    required this.totalPrice,
    required this.timestamp,
  });
}

