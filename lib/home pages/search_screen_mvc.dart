import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  final SearchModel model = SearchModel();
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
      body: SearchView(model: model,), // Extracted into a separate stateful widget
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

class SearchModel {
  bool _isSellerSelected = true;
  bool _isNearbySelected = false;
  LatLng? _currentPosition;
  String _searchName = "";
  bool _isLoading = true;
  LatLng _basePosition = LatLng(10.30943566786076, 123.88635816441766);
  List<String> _userList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getter for isSellerSelected
  bool get isSellerSelected => _isSellerSelected;

  // Setter for isSellerSelected
  set isSellerSelected(bool value) {
    _isSellerSelected = value;
  }

  // Getter for isNearbySelected
  bool get isNearbySelected => _isNearbySelected;

  // Setter for isNearbySelected
  set isNearbySelected(bool value) {
    _isNearbySelected = value;
  }

  // Getter for currentPositon
  LatLng? get currentPositon => _currentPosition;

  // Setter for currentPositon
  set currentPositon(LatLng? value) {
    _currentPosition = value;
  }

  // Getter for searchName
  String get searchName => _searchName;

  // Setter for searchName
  set searchName(String value) {
    _searchName = value;
  }

  // Getter for isLoading
  bool get isLoading => _isLoading;

  // Setter for isLoading
  set isLoading(bool value) {
    _isLoading = value;
  }

  // Getter for userList
  List<String> get userList => _userList;

  // Setter for userList
  set userList(List<String> value) {
    _userList = value;
  }

  // Getter for firestore
  FirebaseFirestore get firestore => _firestore;
}


class SearchView extends StatefulWidget {
  final SearchModel model;
  late SearchController controller = SearchController(models: model);

  SearchView({required this.model, Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  void initState() {
    super.initState();
    widget.controller.getLocation().then((value) {
      widget.controller.getUsersWithinRadius(widget.model._currentPosition!, 500).then((value) {});
    });
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
                    widget.model.searchName = value;
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
                    hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Montserrat', fontWeight: FontWeight.bold)
                ),
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
                        widget.model.isSellerSelected = true;
                        widget.model.isNearbySelected = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || widget.model.isSellerSelected) {
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
                        widget.model.isSellerSelected = false;
                        widget.model.isNearbySelected = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || (!widget.model.isSellerSelected && !widget.model.isNearbySelected)) {
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
                        widget.model.isSellerSelected = false;
                        widget.model.isNearbySelected = true;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || widget.model.isNearbySelected) {
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
      body: widget.controller.buildSearchBody(),
    );
  }
}

class SearchController {
  final SearchModel models;

  SearchController({required this.models});

  Widget buildSearchBody() {
    if (models.isSellerSelected) {
      return _buildSellerListView();
    } else if (models.isNearbySelected) {
      return _buildNearbyListView();
    } else {
      return _buildFishListView();
    }
  }

  Widget _buildSellerListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'seller')
          .orderBy('firstName')
          .startAt([models.searchName.toUpperCase()]).endAt([models.searchName + "\uf8ff"]).snapshots(),
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
  
  Widget _buildNearbyListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'seller')
          .orderBy('firstName')
          .startAt([models.searchName.toUpperCase()]).endAt([models.searchName + "\uf8ff"]).snapshots(),
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
            if (models.userList.contains(data.id)) {
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

  Widget _buildFishListView() {
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
                  .startAt([models.searchName.toUpperCase()]).endAt([models.searchName + "\uf8ff"]).snapshots(),
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
                          subtitle: Text('Seller: $sellerName | Price: \$${fishData['price']}'),
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
  
  Future<void> getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;
    LatLng location = LatLng(lat, long);
    
    models.currentPositon = location;
    models.isLoading = false;
  }

  // get all users within a certain radius
  Future<void> getUsersWithinRadius(LatLng center, double radius) async {
    final QuerySnapshot querySnapshot =
        await models.firestore.collection('seller_info').where('loc_start_address', isNotEqualTo: 'Start Location Not Set').get();

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

      if (_distanceInMeters <= 500) {
        models.userList.add(userId);
      }
    }
  }

  Future<void> initializeData() async {
    await getLocation();
    await getUsersWithinRadius(models.currentPositon!, 500);
  }
}