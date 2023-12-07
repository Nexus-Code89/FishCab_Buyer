import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:fish_cab/seller_side/seller_order_page.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SellerMapPage extends StatefulWidget {
  @override
  _SellerMapPageState createState() => _SellerMapPageState();
}

class _SellerMapPageState extends State<SellerMapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // get instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  LatLng basePosition = LatLng(10.30943566786076, 123.88635816441766);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // get address of place from coordinates
  Future<String> getPlaceAddress(double lat, double lng) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyDu18f9V_o0s-cAui7XtJdJN7H_Yq_NCpw');
    final response = await http.get(url);
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  // get all order markers
  Future<Set<Marker>> getMarkersWithinRadius() async {
    final Set<Marker> markers = {};

    final QuerySnapshot querySnapshot =
        await _firestore.collection('orders').where('sellerID', isEqualTo: _firebaseAuth.currentUser!.uid).get();

    final Marker marker = Marker(
      markerId: MarkerId('your_marker'),
      position: _currentPosition!,
      infoWindow: InfoWindow(title: 'You', snippet: 'Your current location'),
      onTap: () {},
    );
    markers.add(marker);

    // loop through all docs and add them to the markers set
    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final MarkerId markerId = MarkerId(doc.id);
      final latitude = (doc.data() as dynamic)?['location'].latitude;
      final longitude = (doc.data() as dynamic)?['location'].longitude;
      final address = await getPlaceAddress(latitude, longitude);
      final buyerName = await getBuyerName((doc.data() as dynamic)?['userID']);

      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
          latitude,
          longitude,
        ),
        infoWindow: InfoWindow(title: address, snippet: ''),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        onTap: () {
          showOrderDetails(doc, buyerName!);
        },
      );
      markers.add(marker);
    }
    return markers;
  }

  // get current location of device
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

  Future<String> getBuyerName(String buyerID) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(buyerID).get();
    var firstName = userDoc['firstName'];
    var lastName = userDoc['lastName'];
    return '$firstName $lastName';
  }

  void showOrderDetails(QueryDocumentSnapshot order, String buyerName) {
    List<dynamic> items = order['items'];

    // Define colors based on order status
    Color statusColor = order['status'] == 'received' ? Colors.green : Colors.yellow;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: SingleChildScrollView(
              child: Column(
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
                  SizedBox(height: 16.0),
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          'Status: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Text(
                          '${order['status']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                        SizedBox(width: 16.0), // Add space between status and Confirm button
                        ElevatedButton(
                          onPressed: () {
                            //"Confirm" button press
                            confirmOrder(order.id);
                            Navigator.pop(context);
                          },
                          child: Text('Confirm'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void confirmOrder(String orderId) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({'isConfirmed': 'confirmed'}).then((value) {
      // Order marked as confirmed successfully
      // Show a confirmation message
      showConfirmationDialog();
    }).catchError((error) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Route ongoing"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/seller_home');
                }, // Pass the context to the function
                icon: Icon(Icons.arrow_back, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: getMarkersWithinRadius(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                    child: Container(
                      height: 600,
                      child: GoogleMap(
                        mapType: MapType.terrain,
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 14.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: Set<Marker>.of(snapshot.data!),
                      ),
                    ),
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
    );
  }
}
