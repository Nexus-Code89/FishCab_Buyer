import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/components/my_textfield.dart';
import 'package:fish_cab/components/my_textfield_expanded.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';

class SellerSetRoute extends StatefulWidget {
  const SellerSetRoute({super.key});

  @override
  State<SellerSetRoute> createState() => SellerSetRouteState();
}

class SellerSetRouteState extends State<SellerSetRoute> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const CameraPosition _kInitial = CameraPosition(
    target: LatLng(10.294676066330009, 123.88111254232928),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: AppBar(
            title: Text("Set Route"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _firestore.collection("seller_info").doc(_firebaseAuth.currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                  child: Text(
                    snapshot.data!['loc_start_address'] + " - " + snapshot.data!['loc_end_address'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              } else {
                return Text('Loading...');
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/seller_set_location1');
                  },
                  child: const Text('Set start location'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/seller_set_location2');
                  },
                  child: const Text('Set end location'),
                ),
              ),
            ],
          ),
          FutureBuilder(
            future: _firestore.collection("seller_info").doc(_firebaseAuth.currentUser!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                double latitude = snapshot.data!['loc_start'].latitude;
                double longitude = snapshot.data!['loc_start'].longitude;
                double latitudeEnd = snapshot.data!['loc_end'].latitude;
                double longitudeEnd = snapshot.data!['loc_end'].longitude;

                CameraPosition _kInitial = CameraPosition(
                  target: LatLng(latitude, longitude),
                  zoom: 14.4746,
                );

                final List<Marker> myMarker = [
                  Marker(
                      markerId: MarkerId('Start'),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(title: 'Start Location: ' + snapshot.data!['loc_start_address']),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
                  Marker(
                      markerId: MarkerId('End'),
                      position: LatLng(latitudeEnd, longitudeEnd),
                      infoWindow: InfoWindow(title: 'End Location: ' + snapshot.data!['loc_end_address']),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
                ];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                  child: Container(
                    child: GoogleMap(
                      mapType: MapType.terrain,
                      initialCameraPosition: _kInitial,
                      markers: Set<Marker>.of(myMarker),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    height: 450,
                  ),
                );
              } else {
                return Text('Loading...');
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: SellerNavBar(
        currentIndex: 2, // Set the default selected index
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home');
              break;
            case 1:
              // Navigate to Fish Options Page
              Navigator.pushReplacementNamed(context, '/seller_fish_options');
              break;
            case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/seller_chats');
              break;
          }
        },
      ),
    );
  }
}
