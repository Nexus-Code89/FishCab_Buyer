import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/home%20pages/cart_page.dart';
import 'package:fish_cab/model/shopping_cart.dart';
import 'package:fish_cab/seller_pages/seller_fish_demand_options_screen.dart';
import 'package:fish_cab/seller_side/seller_fish_demand_options_page.dart';
import 'package:flutter/material.dart';
import 'seller_navigation_bar.dart';

class FishOptionsScreen extends StatefulWidget {
  final String sellerId;

  FishOptionsScreen({required this.sellerId});

  @override
  _FishOptionsScreenState createState() => _FishOptionsScreenState();
}

class _FishOptionsScreenState extends State<FishOptionsScreen> {
  ShoppingCart myShoppingCart = ShoppingCart();
  late final String userId;
  late FirebaseAuth _firebaseAuth; // Declare _firebaseAuth as a late variable

  @override
  void initState() {
    super.initState();
    _firebaseAuth = FirebaseAuth.instance;
    userId = _firebaseAuth.currentUser!.uid; // Initialize userId in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish Options Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navigate to FishDemandOptionsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FishDemandOptionsScreen(sellerId: widget.sellerId),
                ),
              );
            },
            tooltip: 'Demand',
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.article),
          ),
          SizedBox(height: 16), // Add some space between the buttons
          FloatingActionButton(
            onPressed: () {
              // Navigate to CartPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CartPage(cart: myShoppingCart, sellerID: widget.sellerId, userID: userId);
                  },
                ),
              );
            },
            tooltip: 'Cart',
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: FishOptionsList(sellerId: widget.sellerId, cart: myShoppingCart),
      bottomNavigationBar: SellerNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home_view');
              break;
            case 2:
              // Navigate to Schedule Page
              Navigator.pushReplacementNamed(context, '/seller_schedule_view');
              break;
          }
        },
      ),
    );
  }
}

class FishOptionsList extends StatefulWidget {
  final String sellerId;
  final ShoppingCart cart;

  FishOptionsList({required this.sellerId, required this.cart});

  @override
  State<FishOptionsList> createState() => _FishOptionsListState();
}

class _FishOptionsListState extends State<FishOptionsList> {
  int selectedQuantity = 1;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('seller_info').doc(widget.sellerId).collection('fish_choices').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        final fishChoices = snapshot.data!.docs;

        return _buildFishOptionsList(fishChoices);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Text('Error fetching fish options: $error'),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFishOptionsList(List<DocumentSnapshot> fishChoices) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: fishChoices.length,
      itemBuilder: (context, index) {
        final fishOptionData = fishChoices[index].data() as Map<String, dynamic>?;

        if (fishOptionData != null) {
          // final photoUrl = fishOptionData['photoUrl'] as String?;
          final fishName = fishOptionData['fishName'] as String?;
          final price = fishOptionData['price'] as num?;
          //photoUrl != null &&
          if (fishName != null && price != null) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 3,
                child: Column(
                  children: [
                    // Fish photo
                    Container(
                      height: 64,
                      // decoration: BoxDecoration(
                      //   image: DecorationImage(
                      //     image: NetworkImage(photoUrl),
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ),

                    // Fish name
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        fishName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Fish price (pressable, hoverable, and color change)
                    GestureDetector(
                      onTap: () {
                        _showQuantityDialog(context, fishName, price);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue, // Set the initial color
                        ),
                        child: Text(
                          '\₱$price',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return Container(); // or any other fallback for null or incomplete data
      },
    );
  }

  Future<void> _showQuantityDialog(BuildContext context, String fishName, num price) async {
    double selectedQuantity = 1.0; // Initialize with a default value
    TextEditingController _quantityController = TextEditingController(text: '1.0');

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: 300,
            child: AlertDialog(
              title: Text('Select Quantity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Choose the quantity of $fishName (kg):'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (selectedQuantity > 0.5) {
                            // Decrease by 0.5 kilos
                            setState(() {
                              selectedQuantity -= 0.5;
                              _quantityController.text = selectedQuantity.toString();
                            });
                          }
                        },
                      ),
                      Container(
                        width: 80,
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          controller: _quantityController,
                          onChanged: (value) {
                            // Update selectedQuantity when the user types
                            setState(() {
                              selectedQuantity = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // Increase by 0.5 kilos
                          setState(() {
                            selectedQuantity += 0.5;
                            _quantityController.text = selectedQuantity.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel button
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Confirm button
                    // Add the selected quantity to the cart
                    CartItem newItem = CartItem(name: fishName, price: price, quantity: selectedQuantity);
                    widget.cart.addItem(newItem);
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
