import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:fish_cab/seller_side/seller_order_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home pages/bottom_navigation_bar.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapOngoingPage extends StatefulWidget {
  final String sellerId;

  MapOngoingPage({required this.sellerId});

  @override
  _MapOngoingPageState createState() => _MapOngoingPageState();
}

class _MapOngoingPageState extends State<MapOngoingPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // get instance of auth
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

    // TODO: implement dispose
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

    final DocumentSnapshot doc = await _firestore.collection('seller_info').doc(widget.sellerId).get();

    final Marker marker = Marker(
      markerId: MarkerId('your_marker'),
      position: _currentPosition!,
      infoWindow: InfoWindow(title: 'You', snippet: 'Your current location'),
      onTap: () {},
    );
    markers.add(marker);

    final MarkerId markerId = MarkerId(doc.id);
    final latitude = (doc.data() as dynamic)?['loc_current'].latitude;
    final longitude = (doc.data() as dynamic)?['loc_current'].longitude;
    final address = await getPlaceAddress(latitude, longitude);

    final Marker marker_seller = Marker(
      markerId: markerId,
      position: LatLng(
        latitude,
        longitude,
      ),
      infoWindow: InfoWindow(title: address, snippet: ''),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    markers.add(marker_seller);

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

  getPolyPoints() async {
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
        polylineCoordinates.clear();
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
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.done),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
