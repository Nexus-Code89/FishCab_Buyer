import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/api/firebase_api.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:fish_cab/seller_side/seller_order_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  LatLng basePosition = LatLng(10.30943566786076, 123.88635816441766);
  bool _isLoading = true;
  List<LatLng> polylineCoordinates = [];
  StreamSubscription? positionStream;

  @override
  void initState() {
    super.initState();
    getUserLocation().then((value) {
      getPolyPoints();
    });
  }

  @override
  void dispose() {
    positionStream!.cancel();
    super.dispose();
  }

  getUserLocation() async {
    LocationPermission permission;
    LocationSettings locationSettings;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      LatLng location = LatLng(position.latitude, position.longitude);
      await _firestore
          .collection('seller_info')
          .doc(_firebaseAuth.currentUser?.uid)
          .set({'loc_current': new GeoPoint(location.latitude, location.longitude)}, SetOptions(merge: true)).then((value) {
        setState(() {
          _currentPosition = location;
          _isLoading = false;
        });
      });
    });

    permission = await Geolocator.requestPermission();
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 50,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      );
    }

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) async {
      LatLng location = LatLng(position!.latitude, position.longitude);
      await _firestore
          .collection('seller_info')
          .doc(_firebaseAuth.currentUser?.uid)
          .set({'loc_current': new GeoPoint(location.latitude, location.longitude)}, SetOptions(merge: true)).then((value) {
        setState(() {
          _currentPosition = location;
          _isLoading = false;
        });
      });
    });
  }

  sendNotif() async {
    await _firestore.collection('seller_info').doc(user?.uid).set({'routeStarted': true}, SetOptions(merge: true));
    QuerySnapshot querySnapshot_Orders = await FirebaseFirestore.instance
        .collection("orders")
        .where("sellerID", isEqualTo: user?.uid)
        .where("isConfirmed", isEqualTo: "unconfirmed")
        .get();

    List<dynamic> buyersData = querySnapshot_Orders.docs.map((doc) => doc.data()).toList();
    List<String> buyers = [];

    for (var data in buyersData) {
      buyers.add(data["userID"]);
    }

    QuerySnapshot querySnapshot_Tokens =
        await FirebaseFirestore.instance.collection("tokens").where(FieldPath.documentId, whereIn: buyers).get();

    List<dynamic> allData = querySnapshot_Tokens.docs.map((doc) => doc.data()).toList();

    DocumentSnapshot currentUserDataSnapshot = await FirebaseFirestore.instance.collection("users").doc(user?.uid).get();

    for (var data in allData) {
      FirebaseApi().sendPushMessage(
          "Seller ${currentUserDataSnapshot.get('firstName')} ${currentUserDataSnapshot.get('lastName')} has started route",
          "Fresh fish is on its way!",
          data!['token']!);
    }
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

    final QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .where('sellerID', isEqualTo: _firebaseAuth.currentUser!.uid)
        .where('isConfirmed', isEqualTo: 'unconfirmed')
        .get();

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
          showOrderDetails(doc, buyerName);
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

  void getPolyPoints() async {
    Set<Marker> markerList = await getMarkersWithinRadius();
    bool isFirstMarker = true;
    Marker previousMarker = Marker(markerId: new MarkerId('previousmarker'));
    for (Marker m in markerList) {
      if (isFirstMarker == true) {
        isFirstMarker = false;
        previousMarker = m;
      }
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDu18f9V_o0s-cAui7XtJdJN7H_Yq_NCpw', // Your Google Map Key
        PointLatLng(previousMarker!.position.latitude, previousMarker!.position.longitude),
        PointLatLng(m.position.latitude, m.position.longitude),
      );
      if (result.points.isNotEmpty) {
        result.points.forEach(
          (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          ),
        );
      }
      previousMarker = m;
      setState(() {});
    }
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
      setState(() {});
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: getMarkersWithinRadius(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GoogleMap(
                    mapType: MapType.terrain,
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 14.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: Set<Marker>.of(snapshot.data!),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: const Color(0xFF7B61FF),
                        width: 6,
                      ),
                    },
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _firestore
              .collection('seller_info')
              .doc(_firebaseAuth.currentUser!.uid)
              .set({'routeStarted': false}, SetOptions(merge: true)).then((value) {
            Navigator.pop(context);
          });
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.done),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
