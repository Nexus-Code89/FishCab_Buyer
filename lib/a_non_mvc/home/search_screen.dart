import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreens extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreens> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Add any necessary state variables here

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Search"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      body: SearchView(), // Extracted into a separate stateful widget
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // Set the default selected index
        onTap: (index) {
          // Handle item taps here, based on the index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/search');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/map');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/chats');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/orders');
              break;
          }
        },
      ),
    );
  }
}

class SearchView extends StatefulWidget {
  SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  var searchName = "";
  bool isSellerSelected = true;
  bool isNearbySelected = false;
  LatLng? _currentPosition;
  LatLng basePosition = LatLng(10.30943566786076, 123.88635816441766);
  bool _isLoading = true;
  List<String> userList = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getLocation().then((value) {
      getUsersWithinRadius(_currentPosition!, 500).then((value) {});
    });
  }

  // Function to fetch and display seller data
  Widget buildSellerListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'seller')
          .orderBy('firstName')
          .startAt([searchName.toUpperCase()]).endAt([searchName + "\uf8ff"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SellerProfileView(
                      userId: data.id,
                    ),
                  ),
                );
              },
              leading: CircleAvatar(
                radius: 24,
                //backgroundImage: NetworkImage(data['profileUrl']),
              ),
              title: Text(data['firstName']),
              subtitle: Text(data['email']),
            );
          },
        );
      },
    );
  }

  Future<String> getSellerName(String sellerID) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(sellerID).get();
    var firstName = userDoc['firstName'];
    var lastName = userDoc['lastName'];
    return '$firstName $lastName';
  }

  // Function to fetch and display fish data
  Widget buildFishListView() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('seller_info').get(),
      builder: (context, sellerInfoSnapshot) {
        if (sellerInfoSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (sellerInfoSnapshot.hasError) {
          return Text('Error loading seller info');
        }

        // Extract all seller_info documents
        var sellerInfoDocs = sellerInfoSnapshot.data!.docs;

        return ListView.builder(
          itemCount: sellerInfoDocs.length,
          itemBuilder: (context, index) {
            var sellerInfoDoc = sellerInfoDocs[index];
            var sellerInfoDocId = sellerInfoDoc.id;

            // Use a StreamBuilder to listen to the fish_choices subcollection
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('seller_info')
                  .doc(sellerInfoDocId)
                  .collection('fish_choices')
                  .orderBy('fishName')
                  .startAt([searchName.toUpperCase()]).endAt([searchName + "\uf8ff"]).snapshots(),
              builder: (context, fishChoicesSnapshot) {
                if (fishChoicesSnapshot.hasError) {
                  return Text('Error loading fish choices');
                }

                if (fishChoicesSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                // Extract all fish choices for the current seller
                var fishChoicesDocs = fishChoicesSnapshot.data!.docs;

                return FutureBuilder<String>(
                  future: getSellerName(sellerInfoDocId),
                  builder: (context, sellerNameSnapshot) {
                    if (sellerNameSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (sellerNameSnapshot.hasError) {
                      return Text('Error loading seller name');
                    }

                    var sellerName = sellerNameSnapshot.data;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: fishChoicesDocs.length,
                      itemBuilder: (context, index) {
                        var fishData = fishChoicesDocs[index];

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerProfileView(
                                  userId: sellerInfoDocId,
                                ),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            radius: 24,
                            // Replace with the logic to load fish images
                            // backgroundImage: NetworkImage(fishData['photoUrl']),
                          ),
                          title: Text(fishData['fishName']),
                          subtitle: Text('Seller: $sellerName | Price: P${fishData['price']}'),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
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

// get all users within a certain radius
  getUsersWithinRadius(LatLng center, double radius) async {
    final QuerySnapshot querySnapshot =
        await _firestore.collection('seller_info').where('loc_start_address', isNotEqualTo: 'Start Location Not Set').get();

    // loop through all docs and add them to the users set
    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final String userId = doc.id;
      final latitude = (doc.data() as dynamic)?['loc_start'].latitude;
      final longitude = (doc.data() as dynamic)?['loc_start'].longitude;

      // only get users within a certain radius
      var _distanceInMeters = await Geolocator.distanceBetween(
        latitude,
        longitude,
        center.latitude,
        center.longitude,
      );

      if (_distanceInMeters > 500) {
        continue;
      } else {
        userList.add(userId);
      }
    }
  }

  // Function to fetch and display nearby date
  Widget buildNearbyListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'seller')
          .orderBy('firstName')
          .startAt([searchName.toUpperCase()]).endAt([searchName + "\uf8ff"]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            if (userList.contains(data.id)) {
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfileView(
                        userId: data.id,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 24,
                  //backgroundImage: NetworkImage(data['profileUrl']),
                ),
                title: Text(data['firstName']),
                subtitle: Text(data['email']),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchName = value;
                  });
                },
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 232, 232, 232)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Search for something...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 5),

              // row of buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // seller button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSellerSelected = true;
                        isNearbySelected = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || isSellerSelected) {
                            // Selected
                            return Colors.blue;
                          } else {
                            // Not Selected
                            return Colors.grey;
                          }
                        },
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                      ),
                    ),
                    child: Text(
                      'Seller',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // fish button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSellerSelected = false;
                        isNearbySelected = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || (!isSellerSelected && !isNearbySelected)) {
                            // Sellected
                            return Colors.blue;
                          } else {
                            // Not Selected
                            return Colors.grey;
                          }
                        },
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                      ),
                    ),
                    child: Text(
                      'Fish',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  // nearby button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSellerSelected = false;
                        isNearbySelected = true;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || isNearbySelected) {
                            // Sellected
                            return Colors.blue;
                          } else {
                            // Not Selected
                            return Colors.grey;
                          }
                        },
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                      ),
                    ),
                    child: Text(
                      'Nearby',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: (isSellerSelected)
          ? buildSellerListView()
          : (isNearbySelected)
              ? buildNearbyListView()
              : buildFishListView(),
    );
  }
}
