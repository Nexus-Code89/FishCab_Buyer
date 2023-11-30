// seller_scheduler.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleCreate extends StatelessWidget {
  final String sellerId;

  ScheduleCreate({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    // Implement the UI for creating a schedule
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Schedule'),
      ),
      body: Center(
        child: Text('Create Schedule Page'),
      ),
    );
  }
}

class ScheduleUpdate extends StatelessWidget {
  final String sellerId;
  final String scheduleId;

  ScheduleUpdate({required this.sellerId, required this.scheduleId});

  @override
  Widget build(BuildContext context) {
    // Implement the UI for updating a schedule
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Schedule'),
      ),
      body: Center(
        child: Text('Update Schedule Page'),
      ),
    );
  }
}

class ScheduleDelete extends StatelessWidget {
  final String sellerId;
  final String scheduleId;

  ScheduleDelete({required this.sellerId, required this.scheduleId});

  @override
  Widget build(BuildContext context) {
    // Implement the UI for deleting a schedule
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Schedule'),
      ),
      body: Center(
        child: Text('Delete Schedule Page'),
      ),
    );
  }
}
