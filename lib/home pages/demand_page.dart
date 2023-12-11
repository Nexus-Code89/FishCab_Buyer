import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/model/demand.dart';
import 'package:flutter/material.dart';
import 'package:fish_cab/model/demand_ballot.dart';
import 'package:intl/intl.dart';

class DemandPage extends StatefulWidget {
  final DemandStorage demandStorage;
  final sellerID;
  final userID;
  const DemandPage({Key? key, required this.demandStorage, this.sellerID, this.userID}) : super(key: key);

  @override
  State<DemandPage> createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with the current date
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demand Page'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Selected Date:'),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.demandStorage.demandItems.length,
              itemBuilder: (context, index) {
                DemandItem item = widget.demandStorage.demandItems[index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      '${item.fishName}',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        showDeleteConfirmationDialog(context, index);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (await demandExists(widget.userID, widget.sellerID, _selectedDate)) {
                // Show an error message or handle the case where a demand already exists
                showExistingDemandPrompt(context);
                return; // Exit the method early if a demand already exists
              } else if (widget.demandStorage != null && widget.demandStorage.demandItems.isNotEmpty) {
                placeDemand(context, widget.demandStorage, widget.sellerID, widget.userID, _selectedDate);
              } else {
                showEmptyDemandPrompt(context);
              }
            },
            child: Text('Place Demand'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        )) ??
        _selectedDate;

    if (picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<bool> demandExists(String userID, String sellerID, DateTime selectedDate) async {
    // Perform a query to check if a demand with the given parameters already exists
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('demands')
        .where('userID', isEqualTo: userID)
        .where('sellerID', isEqualTo: sellerID)
        .where('Date', isEqualTo: selectedDate)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void placeDemand(BuildContext context, DemandStorage demandStorage, String sellerID, String userID, DateTime selectedDate) {
    String demandID = UniqueKey().toString();

    Demands demand = Demands(
        documentID: demandID, sellerID: sellerID, userID: userID, items: demandStorage.demandItems, selectedDate: selectedDate);

    // Add the order to Firebase
    FirebaseFirestore.instance.collection('demands').doc(demand.documentID).set({
      'sellerID': demand.sellerID,
      'userID': demand.userID,
      'items': demand.items
          .map((item) => {
                'fishName': item.fishName,
              })
          .toList(),
      'Date': demand.selectedDate,
    }).then((value) {
      // Order placed successfully, we can add additional logic here
      // For example, clear the cart or show a success message
    }).catchError((error) {
      // Handle errors, e.g., show an error message
      //print('Error placing order: $error');
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Demand Placed'),
          content: Text('Seller has recieved your demand!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the current dialog
                Navigator.pop(context); // Close the CartPage
                Navigator.pushReplacementNamed(context, '/seller_fish_options_view'); // Navigate to OrdersScreen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showExistingDemandPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Demand Notice'),
          content: Text('You already had place a demand on that day.'),
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

  void showEmptyDemandPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Empty Ballot'),
          content: Text('Your demand ballot is empty. Add items before placing a demand.'),
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

  void showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this item from the demand list?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Delete the item from the demand list
                Navigator.pop(context); // Close the confirmation dialog
                deleteDemandItem(context, index);
                setState(() {});
              },
              child: Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void deleteDemandItem(BuildContext context, int index) {
    // Call the removeItem method on your DemandStorage instance
    widget.demandStorage.removeItem(index);

    // Update the UI (optional)
    setState(() {
      // Additional logic to update state variables if needed
    });

    // Optionally, show a message to indicate that the item has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from the demand list.'),
      ),
    );
  }
}
