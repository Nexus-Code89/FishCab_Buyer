import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
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

  // get all markers within a certain radius
  Future<Set<Marker>> getMarkersWithinRadius(LatLng center, double radius) async {
    final Set<Marker> markers = {};

    final QuerySnapshot querySnapshot =
        await _firestore.collection('seller_info').where('loc_start_address', isNotEqualTo: 'Start Location Not Set').get();
    final Marker marker = Marker(
      markerId: MarkerId('your_marker'),
      position: center,
      infoWindow: InfoWindow(title: 'You', snippet: 'Your current location'),
      onTap: () {},
    );
    markers.add(marker);

    // loop through all docs and add them to the markers set
    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final MarkerId markerId = MarkerId(doc.id);
      final latitude = (doc.data() as dynamic)?['loc_start'].latitude;
      final longitude = (doc.data() as dynamic)?['loc_start'].longitude;

      // only get markers within a certain radius
      var _distanceInMeters = await Geolocator.distanceBetween(
        latitude,
        longitude,
        center.latitude,
        center.longitude,
      );

      if (_distanceInMeters > 500) {
        continue;
      } else {
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(
            latitude,
            longitude,
          ),
          infoWindow: InfoWindow(title: (doc.data() as dynamic)?['loc_start_address'], snippet: ''),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerProfileView(
                        userId: doc.id,
                      )),
            );
          },
        );

        markers.add(marker);
      }
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Sellers Near You"),
            titleSpacing: 20,
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle:
                const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: getMarkersWithinRadius(_currentPosition!, 500),
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
                        circles: {
                          Circle(
                            circleId: CircleId('1'),
                            center: _currentPosition!,
                            radius: 500,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                            fillColor: Colors.blue.withOpacity(0.2),
                          )
                        },
                      ),
                    ),
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // Set the default selected index
        onTap: (index) {
          // Handle item taps here, based on the index
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
}
