import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fish_cab/model/demand.dart';
import 'package:fish_cab/model/demand_ballot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DemandController {
  late DateTime selectedDate;
  late DemandStorage demandStorage;
  late String userId; // Added userId
  late String sellerId; // Added sellerId

  DemandController() {
    demandStorage = DemandStorage();
  }

  // Getters and setters for userId and sellerId
  String get getUserId => userId;

  set setUserId(String id) {
    userId = id;
  }

  String get getSellerId => sellerId;

  set setSellerId(String id) {
    sellerId = id;
  }

  // Getter for selectedDate
  DateTime get getselectedDate => selectedDate;

  // Setter for selectedDate
  set setselectedDate(DateTime date) {
    selectedDate = date;
  }

  void addDemand(DemandItem item) {
    demandStorage.addDemand(item);
  }

  void removeItem(int index) {
    demandStorage.removeItem(index);
  }

  Future<bool> demandExists(String userID, String sellerID, DateTime selectedDate) async {
    print('Selected Date: $selectedDate');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('demands')
        .where('userID', isEqualTo: userID)
        .where('sellerID', isEqualTo: sellerID)
        .where('Date', isEqualTo: selectedDate)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> placeDemand(BuildContext context) async {
    String demandID = UniqueKey().toString();

    Demands demand = Demands(
      documentID: demandID,
      sellerID: sellerId,
      userID: userId,
      items: demandStorage.demandItems,
      selectedDate: selectedDate,
    );

    // Add the order to Firebase
    await FirebaseFirestore.instance.collection('demands').doc(demand.documentID).set({
      'sellerID': demand.sellerID,
      'userID': demand.userID,
      'items': demand.items
          .map((item) => {
                'fishName': item.fishName,
              })
          .toList(),
      'Date': demand.selectedDate,
    });

    // Additional logic after placing the demand (if needed)

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Demand Placed'),
          content: Text('Seller has received your demand!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the current dialog
                Navigator.pop(context); // Close the DemandPage
                // Navigate to another screen if needed
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void deleteDemandItem(BuildContext context, int index) {
    // Call the removeItem method on your DemandStorage instance
    demandStorage.removeItem(index);

    // Update the UI (optional)
    // Additional logic to update state variables if needed

    // Optionally, show a message to indicate that the item has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from the demand list.'),
      ),
    );
  }
}


class DemandPage extends StatefulWidget {
  final DemandController controller;
  final sellerID;
  final userID;

  DemandPage({
    Key? key,
    required this.controller,
    this.sellerID,
    this.userID,
    required DemandStorage demandStorage,
  }) : super(key: key) {
    // Set the userID and sellerID in the controller when creating an instance
    controller.setUserId = userID;
    controller.setSellerId = sellerID;
    controller.demandStorage = demandStorage;
  }

  @override
  State<DemandPage> createState() => _DemandPageState();
}


class _DemandPageState extends State<DemandPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

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
            itemCount: widget.controller.demandStorage.demandItems.length,
            itemBuilder: (context, index) {
              DemandItem item = widget.controller.demandStorage.demandItems[index];

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
              if (await widget.controller.demandExists(widget.controller.getUserId, widget.controller.getSellerId, _selectedDate)) {
                showExistingDemandPrompt(context);
                return;
              } else if (widget.controller.demandStorage != null && widget.controller.demandStorage.demandItems.isNotEmpty) {
                widget.controller.placeDemand(context);
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
    final DateTime currentDate = DateTime.now();
    final DateTime lastSelectableDate = currentDate.add(Duration(days: 30));

    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: currentDate, 
      lastDate: lastSelectableDate,
    )) ?? _selectedDate;

    if (picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.controller.setselectedDate = picked;
      });
    }
  }

  void showExistingDemandPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Demand Notice'),
          content: Text('You already had placed a demand on that day.'),
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
                widget.controller.deleteDemandItem(context, index);
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
}
