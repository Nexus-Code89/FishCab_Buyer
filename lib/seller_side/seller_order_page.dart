import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';

class SellerOrderPage extends StatefulWidget {
  @override
  _SellerOrderPageState createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerID', isEqualTo: _firebaseAuth.currentUser!.uid)
            .where('isConfirmed', isEqualTo: 'unconfirmed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending orders.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var buyerID = order['userID'];
              var totalPrice = order['totalPrice'];
              var fishItems = order['items'];

              return FutureBuilder(
                future: getBuyerName(buyerID),
                builder: (context, buyerSnapshot) {
                  if (buyerSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var buyerName = buyerSnapshot.data;

                  return Card(
                    child: ListTile(
                      title: Text('Buyer: $buyerName'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price: \₱$totalPrice'),
                          Text('Fish Items: ${getFishItemNames(fishItems)}'),
                        ],
                      ),
                      onTap: () {
                        // Show order details when tapped
                        showOrderDetails(order, buyerName!);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: SellerNavBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home');
              break;
            case 1:
              // Navigate to Fish Options Page
              Navigator.pushReplacementNamed(context, '/seller_fish_options');
              break;
            case 2:
              // Navigate to Schedule Page
              Navigator.pushReplacementNamed(context, '/seller_schedule');
              break;
            /*case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/chats');
              break;*/
            /*case 4:
              // Navigate to Orders Page
              Navigator.pushReplacementNamed(context, '/seller_orders');
              break;*/
          }
        },
      ),
    );
  }

  Future<String> getBuyerName(String buyerID) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(buyerID).get();
    var firstName = userDoc['firstName'];
    var lastName = userDoc['lastName'];
    return '$firstName $lastName';
  }

  String getFishItemNames(List<dynamic> fishItems) {
    List<String> itemNames = [];
    for (var item in fishItems) {
      var itemName = item['name'];
      itemNames.add(itemName);
    }
    return itemNames.join(', ');
  }

  void showOrderDetails(QueryDocumentSnapshot order, String buyerName) {
  List<dynamic> items = order['items'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Order Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Buyer: $buyerName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            for (var item in items)
              ListTile(
                title: Text(
                  '${item['name']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price: \₱${item['price']} per kg'),
                    Text('Quantity: ${item['quantity']} kg'),
                    Text(
                      'Total: \₱${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                contentPadding: EdgeInsets.all(0),
              ),
            SizedBox(height: 16.0),
            Divider(thickness: 1),
            ListTile(
              title: Text(
                'Total Price: \₱${order['totalPrice']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              //"Confirm" button press
              confirmOrder(order.id);
              Navigator.pop(context);
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void confirmOrder(String orderId) {
  FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId)
    .update({'isConfirmed': 'confirmed'})
    .then((value) {
      // Order marked as confirmed successfully
      // Show a confirmation message
      showConfirmationDialog();
    })
    .catchError((error) {
      // Handle errors, e.g., show an error message
      print('Error marking order as confirmed: $error');
    });
}

void showConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Order Confirmed'),
        content: Text('The order has been confirmed.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
 }
}