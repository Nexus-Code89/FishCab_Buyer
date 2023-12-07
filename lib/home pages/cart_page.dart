import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/model/order.dart';
import 'package:fish_cab/model/shopping_cart.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartPage extends StatefulWidget {
  final ShoppingCart cart;
  final sellerID;
  final userID;

  const CartPage({Key? key, required this.cart, required this.sellerID, required this.userID}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  LatLng? _currentPosition;
  LatLng basePosition = LatLng(10.30943566786076, 123.88635816441766);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

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
              itemCount: widget.cart.items.length,
              itemBuilder: (context, index) {
                CartItem item = widget.cart.items[index];
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          showDeleteConfirmationDialog(context, index);
                        },
                      )),
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
                    'Total: \₱${widget.cart.getTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.cart != null && widget.cart.items.isNotEmpty) {
                        placeOrder(context, widget.cart, widget.sellerID, widget.userID);
                      } else {
                        showEmptyCartPrompt(context);
                      }
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

  getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _isLoading = false;
    });
  }

  void showEmptyCartPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Empty Cart'),
          content: Text('Your cart is empty. Add items before placing an order.'),
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

  void showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this item from the cart?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Delete the item from the cart
                Navigator.pop(context); // Close the confirmation dialog
                deleteCartItem(context, index);
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void deleteCartItem(BuildContext context, int index) {
    // Call the removeItem method on your ShoppingCart instance
    widget.cart.removeItem(index);

    // Update the UI (optional)
    setState(() {
      // Additional logic to update state variables if needed
    });

    // Optionally, show a message to indicate that the item has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from the cart.'),
      ),
    );
  }

  //  method for placing an order
  void placeOrder(BuildContext context, ShoppingCart cart, String sellerID, String userID) {
    String orderID = UniqueKey().toString();

    Orders order = Orders(
      documentID: orderID,
      sellerID: sellerID,
      userID: userID,
      status: 'pending',
      isConfirmed: 'unconfirmed',
      items: cart.items,
      totalPrice: cart.getTotalPrice(),
      timestamp: Timestamp.now(),
      location: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
    );

    // Add the order to Firebase
    FirebaseFirestore.instance.collection('orders').doc(order.documentID).set({
      'sellerID': order.sellerID,
      'userID': order.userID,
      'status': order.status,
      'isConfirmed': order.isConfirmed,
      'items': order.items
          .map((item) => {
                'name': item.name,
                'quantity': item.quantity,
                'price': item.price,
              })
          .toList(),
      'totalPrice': order.totalPrice,
      'timestamp': order.timestamp,
      'location': order.location,
    }).then((value) {
      // Order placed successfully, we can add additional logic here
      // For example, clear the cart or show a success message
    }).catchError((error) {
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
