import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/components/my_textfield.dart';
import 'package:fish_cab/components/my_textfield_expanded.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class SellerSetLocation1 extends StatefulWidget {
  const SellerSetLocation1({super.key});

  @override
  State<SellerSetLocation1> createState() => SellerSetLocation1State();
}

class SellerSetLocation1State extends State<SellerSetLocation1> {
  String tokenForSession = '12345';
  List<dynamic> listForPlaces = [];
  var uuid = Uuid();

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  void suggest(String input) async {
    String googlePlacesApiKey = 'AIzaSyDu18f9V_o0s-cAui7XtJdJN7H_Yq_NCpw';
    String groundURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$googlePlacesApiKey&sessiontoken=$tokenForSession';

    var responseResult = await http.get(Uri.parse(request));
    var Resultdata = responseResult.body.toString();

    print('Result Data');
    print(Resultdata);

    if (responseResult.statusCode == 200) {
      setState(() {
        listForPlaces = jsonDecode(responseResult.body.toString())['predictions'];
      });
    } else {
      throw Exception("Failed to show location data. Try again.");
    }
  }

  void onModify() {
    if (tokenForSession == null) {
      setState(() {
        tokenForSession = uuid.v4();
      });
    }

    suggest(_searchController.text);
  }

  Future<void> setLocation(double latitude, double longitude, String location_address) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUID = _firebaseAuth.currentUser!.uid;
    // List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    // Placemark place = placemarks[0];
    // print(place.name);

    await _firestore.collection('seller_info').doc(currentUID).set(
        {'loc_start': new GeoPoint(latitude, longitude), 'loc_start_address': location_address},
        SetOptions(merge: true)).then((value) {});
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      onModify();
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
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
            title: Text("Set Start Location"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/seller_schedule');
                }, // Pass the context to the function
                icon: Icon(Icons.arrow_back, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextFieldExpanded(
              onChanged: (value) {
                print(value);
              },
              controller: _searchController,
              hintText: 'Search for a location...',
              obscureText: false,
            ),
          ),
          Row(),
          Expanded(
              child: ListView.builder(
            itemCount: listForPlaces.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () async {
                  List<Location> locations = await locationFromAddress(listForPlaces[index]['description']);
                  setLocation(locations.last.latitude, locations.last.longitude, listForPlaces[index]['description']);
                  Navigator.pushReplacementNamed(context, '/seller_set_route');
                },
                title: Text(listForPlaces[index]['description']),
              );
            },
          )),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.pushReplacementNamed(context, '/seller_schedule');
      //   },
      //   label: const Text('Return'),
      //   icon: const Icon(Icons.arrow_back),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
