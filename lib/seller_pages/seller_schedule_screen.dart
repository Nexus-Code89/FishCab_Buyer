import 'package:fish_cab/seller_pages/seller_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SellerScheduleScreen extends StatelessWidget {
  final String sellerId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  SellerScheduleScreen({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule & Route'),
        toolbarHeight: 80,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: _firestore.collection("seller_info").doc(sellerId).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  double latitude = snapshot.data!['loc_start'].latitude;
                  double longitude = snapshot.data!['loc_start'].longitude;
                  double latitudeEnd = snapshot.data!['loc_end'].latitude;
                  double longitudeEnd = snapshot.data!['loc_end'].longitude;

                  String schedStart = snapshot.data!['sched_start'];
                  String schedEnd = snapshot.data!['sched_end'];
                  DateTime startTime = DateFormat.Hm().parse(schedStart);
                  DateTime endTime = DateFormat.Hm().parse(schedEnd);

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

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data!['loc_start_address'] + "  ====>  " + snapshot.data!['loc_end_address'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 25.0),
                            Text(
                              DateFormat("h:mma").format(startTime) + ' - ' + DateFormat("h:mma").format(endTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(25.0),
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
                      ),
                    ],
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SellerNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              // Navigate to Home Page
              Navigator.pushReplacementNamed(context, '/seller_home_view');
              break;
            case 1:
              // Navigate to Fish Options Page
              Navigator.pushReplacementNamed(context, '/seller_fish_options_view');
              break;
          }
        },
      ),
    );
  }
}
