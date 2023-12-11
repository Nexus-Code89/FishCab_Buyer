import 'package:fish_cab/model/demand_ballot.dart';

class Demands {
  String documentID;
  String sellerID;
  String userID;
  DateTime selectedDate;
  List<DemandItem> items;

  Demands({
    required this.documentID,
    required this.sellerID,
    required this.userID,
    required this.items,
    required this.selectedDate,
  });
}