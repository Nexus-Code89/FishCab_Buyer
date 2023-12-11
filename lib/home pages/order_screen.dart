import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';
import 'package:fish_cab/review-rating%20pages/make_review_screen.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Orders"),
            titleSpacing: 20,
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle:
                const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userID', isEqualTo: _firebaseAuth.currentUser!.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending orders.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var sellerID = order['sellerID'];
              var totalPrice = order['totalPrice'];
              var fishItems = order['items'];

              return FutureBuilder(
                future: getSellerName(sellerID),
                builder: (context, sellerSnapshot) {
                  if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  var sellerName = sellerSnapshot.data;

                  return Card(
                    child: ListTile(
                      title: Text('Seller: $sellerName'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Price: \₱$totalPrice'),
                          Text('Fish Items: ${getFishItemNames(fishItems)}'),
                        ],
                      ),
                      onTap: () {
                        // Show order details when tapped
                        showOrderDetails(order, sellerName!);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          // Handle navigation taps based on the index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chats');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/orders');
              break;
          }
        },
      ),
    );
  }

  Future<String> getSellerName(String sellerID) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(sellerID).get();
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

  void showOrderDetails(QueryDocumentSnapshot order, String sellerName) {
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
              Text('Seller: $sellerName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                // "Received" button press
                markOrderAsReceived(order.id);
                Navigator.pop(context);
              },
              child: Text('Received'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, (MaterialPageRoute(builder: (context) => ReviewView(reviewee: order['sellerID'])))); // Cl
              },
              child: Text('Rate'),
            ),
          ],
        );
      },
    );
  }

  void markOrderAsReceived(String orderId) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': 'received'}).then((value) {
      // Order marked as received successfully
      print('Order marked as received!');
      showReceivedDialog();
    }).catchError((error) {
      // Handle errors, e.g., show an error message
      print('Error marking order as received: $error');
    });
  }

  void showReceivedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Received'),
          content: Text('The order has been received.'),
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
