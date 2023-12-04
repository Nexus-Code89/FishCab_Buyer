import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:day_picker/day_picker.dart';

class SellerSchedulePage extends StatefulWidget {
  final String sellerId;
  const SellerSchedulePage({
    super.key,
    required this.sellerId,
  });

  @override
  _SellerSchedulePageState createState() => _SellerSchedulePageState();
}

class _SellerSchedulePageState extends State<SellerSchedulePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get the current sched and time

  // Update the scheduled days
  Future<void> updateSchedule(List<String> daysSelected) async {
    String id = _firebaseAuth.currentUser!.uid;
    final seller_db = _firestore.collection("seller_info").doc(id);
    final data = <String, List<String>>{"sched_days": daysSelected};

    // update db selected days
    await seller_db.set(data, SetOptions(merge: true));
  }

  // Update the start and end time
  Future<void> updateTime(String startTime, String endTime) async {
    String id = _firebaseAuth.currentUser!.uid;
    final seller_db = _firestore.collection("seller_info").doc(id);
    final data = <String, String>{"sched_start": startTime, "sched_end": endTime};

    // update db start and end time
    await seller_db.set(data, SetOptions(merge: true));
  }

  List<DayInWeek> _days = [
    DayInWeek("Mon", dayKey: "Monday"),
    DayInWeek("Tue", dayKey: "Tuesday"),
    DayInWeek("Wed", dayKey: "Wednesday"),
    DayInWeek("Thu", dayKey: "Thursday"),
    DayInWeek("Fri", dayKey: "Friday"),
    DayInWeek("Sat", dayKey: "Saturday"),
    DayInWeek("Sun", dayKey: "Sunday"),
  ];

  // // Initialize date picker with existing values
  // List<DayInWeek> initDatePicker() {
  //   List<DayInWeek> _days = [
  //     DayInWeek("Mon", dayKey: "Monday"),
  //     DayInWeek("Tue", dayKey: "Tuesday"),
  //     DayInWeek("Wed", dayKey: "Wednesday"),
  //     DayInWeek("Thu", dayKey: "Thursday"),
  //     DayInWeek("Fri", dayKey: "Friday"),
  //     DayInWeek("Sat", dayKey: "Saturday"),
  //     DayInWeek("Sun", dayKey: "Sunday"),
  //   ];

  //   String id = _firebaseAuth.currentUser!.uid;
  //   final seller_db = _firestore.collection("seller_info").doc(id);
  //   List<String> seller_days = [];
  //   seller_db.get().then(
  //     (DocumentSnapshot doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       seller_days = (data["sched_days"] as List)!.map((item) => item as String).toList();
  //     },
  //     onError: (e) => print("Error getting document: $e"),
  //   );

  //   for (var i = 0; i < 6; i++) {
  //     if (seller_days.contains(_days[i].dayKey)) {
  //       _days[i].isSelected = true;
  //     }
  //   }
  //   return _days;
  //   // add new message to db
  //   // await seller_db.set(data, SetOptions(merge: true));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SelectWeekDays(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                days: _days,
                border: false,
                boxDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.blue,
                ),
                onSelect: (values) {
                  // <== Callback to handle the selected days
                  print(values);
                  updateSchedule(values);
                },
              ),
            ),
            // Set Your Scheduled Time
            MyButton(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/seller_set_route');
              },
              text: 'Set Route',
            ),
            const SizedBox(height: 10),
            MyButton(
                onTap: () async {
                  TimeRange? result = await showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      TimeOfDay startTime = TimeOfDay.now();
                      TimeOfDay endTime = TimeOfDay.now();
                      return CupertinoAlertDialog(
                        content: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 340,
                            child: Column(
                              children: [
                                TimeRangePicker(
                                  padding: 22,
                                  hideButtons: true,
                                  handlerRadius: 8,
                                  strokeWidth: 4,
                                  ticks: 12,
                                  activeTimeTextStyle:
                                      const TextStyle(fontWeight: FontWeight.normal, fontSize: 22, color: Colors.white),
                                  timeTextStyle:
                                      const TextStyle(fontWeight: FontWeight.normal, fontSize: 22, color: Colors.white70),
                                  onStartChange: (start) {
                                    startTime = start;
                                  },
                                  onEndChange: (end) {
                                    endTime = end;
                                  },
                                ),
                              ],
                            )),
                        actions: <Widget>[
                          CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          CupertinoDialogAction(
                            child: const Text('Ok'),
                            onPressed: () {
                              updateTime("${startTime.hour}:${startTime.minute}", "${endTime.hour}:${endTime.minute}");
                              Navigator.of(context).pop(
                                TimeRange(startTime: startTime, endTime: endTime),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                text: "Set Time"),
          ],
        ),
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
            /*case 3:
              // Navigate to Chats Page
              Navigator.pushReplacementNamed(context, '/chats');
              break;*/
          }
        },
      ),
    );
  }
}
