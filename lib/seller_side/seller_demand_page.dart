import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SellerDemandPage extends StatefulWidget {
  final String sellerID;

  SellerDemandPage({required this.sellerID});

  @override
  _SellerDemandPageState createState() => _SellerDemandPageState();
}

class _SellerDemandPageState extends State<SellerDemandPage> {
  late List<String> demandDates = [];

  @override
  void initState() {
    super.initState();
    // Load demand dates when the page is initialized
    loadDemandDates();
  }

  Future<void> loadDemandDates() async {
    try {
      // Query Firestore to get unique demand dates for the current seller
      QuerySnapshot demandSnapshot =
          await FirebaseFirestore.instance.collection('demands').where('sellerID', isEqualTo: widget.sellerID).get();

      // Check if there are documents in the result set
      if (demandSnapshot.size > 0) {
        // Extract unique dates from the demands
        Set<String> uniqueDates = Set<String>();
        demandSnapshot.docs.forEach((doc) {
          // Handle Timestamp type for 'Date' field
          var dateValue = doc['Date'];
          if (dateValue is Timestamp) {
            // Convert Timestamp to DateTime and then to String
            var dateTime = dateValue.toDate();
            var dateString = DateFormat('yyyy-MM-dd').format(dateTime);
            uniqueDates.add(dateString);
          } else if (dateValue is String) {
            // If already a String, just add it to the set
            uniqueDates.add(dateValue);
          }
        });

        // Convert the set to a list for display
        demandDates = uniqueDates.toList();

        // Ensure that the list is sorted (you may adjust the sorting logic based on your needs)
        demandDates.sort((a, b) => a.compareTo(b));

        // Update the UI
        setState(() {});
      } else {
        // No documents found, handle accordingly (e.g., show a message)
        print('No demand dates found for the seller.');
      }
    } catch (error) {
      // Handle errors, e.g., show an error message
      print('Error loading demand dates: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demands'),
        toolbarHeight: 80,
        titleSpacing: 20,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 20, fontFamily: 'Montserrat'),
      ),
      body: Column(
        children: [
          // Display the list of demand dates
          Expanded(
            child: ListView.builder(
              itemCount: demandDates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(demandDates[index]),
                  onTap: () {
                    // Handle date selection (e.g., show top 5 most demanded fish for the selected date)
                    showTopDemandedFish(Timestamp.fromDate(DateTime.parse(demandDates[index])));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showTopDemandedFish(Timestamp selectedTimestamp) async {
    try {
      // Query Firestore to get demands for the selected date and seller
      QuerySnapshot demandSnapshot = await FirebaseFirestore.instance
          .collection('demands')
          .where('sellerID', isEqualTo: widget.sellerID)
          .where('Date', isEqualTo: selectedTimestamp)
          .get();

      // Check if there are documents in the result set
      if (demandSnapshot.size > 0) {
        // Extract fish items from demands
        List<dynamic> fishItems = [];
        demandSnapshot.docs.forEach((doc) {
          fishItems.addAll(doc['items']);
        });

        // Create a map to store the quantity of each fish
        Map<String, int> fishQuantityMap = {};

        // Count the quantity of each fish
        fishItems.forEach((fish) {
          var fishName = fish['fishName'];
          fishQuantityMap[fishName] = (fishQuantityMap[fishName] ?? 0) + 1;
        });

        // Convert the map to a list of MapEntry and sort it by quantity in descending order
        List<MapEntry<String, int>> sortedFishEntries = fishQuantityMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Extract the top 10 fish items
        List<String> topFishNames = sortedFishEntries.take(10).map((entry) => entry.key).toList();

        // Create a map to store the number of votes for each fish
        Map<String, int> fishVotesMap = {};
        sortedFishEntries.forEach((entry) {
          fishVotesMap[entry.key] = entry.value;
        });

        // Show the top demanded fish with votes and rank (you may display it in a dialog or navigate to another page)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Top Demanded Fish'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int rank = 1; rank <= topFishNames.length; rank++)
                    ListTile(
                      title: Text('${rank}. ${topFishNames[rank - 1]}'),
                      subtitle: Text('Votes: ${fishVotesMap[topFishNames[rank - 1]]}'),
                    ),
                ],
              ),
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
      } else {
        // No demands found for the selected date, handle accordingly (e.g., show a message)
        print('No demands found for the selected date.');
      }
    } catch (error) {
      // Handle errors, e.g., show an error message
      print('Error showing top demanded fish: $error');
    }
  }
}
