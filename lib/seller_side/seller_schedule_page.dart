import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_cab/components/my_button.dart';
import 'package:fish_cab/seller_side/seller_bottom_navbar.dart';
import 'package:fish_cab/seller_side/seller_set_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 10.0),
          child: AppBar(
            title: Text("Schedule & Route"),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
          ),
        ),
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
            FutureBuilder(
              future: _firestore.collection("seller_info").doc(_firebaseAuth.currentUser!.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String schedStart = snapshot.data!['sched_start'];
                  String schedEnd = snapshot.data!['sched_end'];
                  DateTime startTime = DateFormat.Hm().parse(schedStart);
                  DateTime endTime = DateFormat.Hm().parse(schedEnd);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: [
                        Text(
                          snapshot.data!['loc_start_address'] + "  TO  " + snapshot.data!['loc_end_address'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        TextButton(
                            child: const Text("Change Route",
                                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.blue)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SellerSetRoute()));
                            }),
                        Text(
                          DateFormat("h:mma").format(startTime) + ' - ' + DateFormat("h:mma").format(endTime),
                          style: const TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          child: const Text("Change Schedule",
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16, color: Colors.blue)),
                          onPressed: () async {
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
                                            timeTextStyle: const TextStyle(
                                                fontWeight: FontWeight.normal, fontSize: 22, color: Colors.white70),
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
                        ),
                      ],
                    ),
                  );
                } else {
                  return Text('Loading...');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
