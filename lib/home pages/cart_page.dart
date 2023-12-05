import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/model/order.dart';
import 'package:fish_cab/model/shopping_cart.dart';
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  final ShoppingCart cart;
  final sellerID;
  final userID;
  
  const CartPage({Key? key, required this.cart, required this.sellerID, required this.userID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                CartItem item = cart.items[index];
                double totalPerItem = item.price * item.quantity;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: \₱${item.price} per kg'),
                            Text('Quantity: ${item.quantity} kg'),
                          ],
                        ),
                        Text('Total: \₱${totalPerItem.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          BottomAppBar(
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \₱${cart.getTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      placeOrder(context, cart, sellerID, userID);
                      // Optionally, navigate to a success page or show a confirmation message
                    },
                    child: Text('Place Order'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder method for placing an order
void placeOrder(BuildContext context, ShoppingCart cart, String sellerID, String userID) {
  Orders order = Orders(
    documentID: '$sellerID$userID',
    sellerID: sellerID,
    userID: userID,
    status: 'pending', 
    isConfirmed: 'unconfirmed', 
    items: cart.items,
    totalPrice: cart.getTotalPrice(),
    timestamp: Timestamp.now(),
  );

  // Add the order to Firebase
  FirebaseFirestore.instance
      .collection('orders')
      .doc(order.documentID)
      .set({
        'sellerID': order.sellerID,
        'userID': order.userID,
        'status': order.status,
        'isConfirmed': order.isConfirmed,
        'items': order.items.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        'totalPrice': order.totalPrice,
        'timestamp': order.timestamp,
      })
      .then((value) {
        // Order placed successfully, we can add additional logic here
        // For example, clear the cart or show a success message
      })
      .catchError((error) {
        // Handle errors, e.g., show an error message
        //print('Error placing order: $error');
      });
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Placed'),
          content: Text('Thank you for your order!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the current dialog
                Navigator.pop(context); // Close the CartPage
                Navigator.pushReplacementNamed(context, '/orders'); // Navigate to OrdersScreen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}