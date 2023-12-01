import 'package:flutter/material.dart';
import 'package:fish_cab/review-rating pages/make_review_screen.dart';

class ViewReviewView extends StatefulWidget {
  late String reviewee;
  late ReviewController controller = ReviewController(ReviewModel("sam for now", reviewee));

  ViewReviewView({super.key, required this.reviewee});

  @override
  State<ViewReviewView> createState() => _ViewReviewViewState();
}

class _ViewReviewViewState extends State<ViewReviewView> {
  late final Future<List<ExpansionTile>> r = widget.controller.getReviews();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reviews"),),
      body: FutureBuilder<List<ExpansionTile>>(
        future: r,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  // AsyncSnapshot<Your object type>
          if( snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: Text('Please wait its loading...'));
          }else{
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Column(
                children: snapshot.data,
              );
            }// snapshot.data  :- get your object which is pass from your downloadData() function
          }
        },),
    );
  }
}
