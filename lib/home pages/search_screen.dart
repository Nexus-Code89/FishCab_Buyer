import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/seller_pages/seller_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/home%20pages/bottom_navigation_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Add any necessary state variables here

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Screen'),
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

  // Function to fetch and display seller data
  Widget buildSellerListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'seller')
          .orderBy('firstName')
          .startAt([searchName.toUpperCase()])
          .endAt([searchName + "\uf8ff"]).snapshots(),
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
                  .startAt([searchName.toUpperCase()])
                  .endAt([searchName + "\uf8ff"])
                  .snapshots(),
              builder: (context, fishChoicesSnapshot) {
                if (fishChoicesSnapshot.hasError) {
                  return Text('Error loading fish choices');
                }

                if (fishChoicesSnapshot.connectionState ==
                    ConnectionState.waiting) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Two buttons side by side
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSellerSelected = true;
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
                        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                    child: Text(
                      'Seller',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSellerSelected = false;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed) || !isSellerSelected) {
                            // Sellected
                            return Colors.blue;
                          } else {
                            // Not Selected
                            return Colors.grey;
                          }
                        },
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                    child: Text(
                      'Fish',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isSellerSelected ? buildSellerListView() : buildFishListView(),
    );
  }
}
