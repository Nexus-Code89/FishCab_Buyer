import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewModel {
  late String reviewer;
  late String reviewee;

  ReviewModel(this.reviewer, this.reviewee);

  Future<String> makeReview(String review, int starRating) async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .doc(reviewee)
        .collection("user_reviews")
        .add({'starRating': starRating, 'review': review, 'reviewedBy': reviewer}).catchError((onError) {
      return onError.toString();
    });
    return "success";
  }

  Future<List<dynamic>> getReviews() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("reviews").doc(reviewee).collection("user_reviews").get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    return allData;
  }
}

class ReviewController {
  late ReviewModel model;

  ReviewController(this.model);

  Future<SnackBar> makeReview(String review, int starRating) async {
    String message = await model.makeReview(review, starRating).onError((error, stackTrace) {
      return "Error: $error";
    });

    if (message == "success") {
      return const SnackBar(
        content: Text(
          "Successfully sent review",
          style: TextStyle(
            fontSize: 36,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      );
    }
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 36,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );
  }

  Future<List<ExpansionTile>> getReviews() async {
    List<dynamic> list = await model.getReviews();
    List<ExpansionTile> reviews = [];
    for (var review in list) {
      List<Icon> stars = [];
      for (int i = 0; i < review["starRating"]; i++) {
        stars.add(const Icon(Icons.star));
      }
      reviews.add(ExpansionTile(
        title: Row(
          children: stars,
        ),
        subtitle: Text(review["reviewedBy"]),
        children: [
          ListTile(
            title: const Text("Review:"),
            subtitle: Text(review["review"]),
          )
        ],
      ));
    }
    return reviews;
  }
}

class ReviewView extends StatefulWidget {
  late String reviewee;
  late ReviewController controller = ReviewController(ReviewModel(FirebaseAuth.instance.currentUser!.email!, reviewee));

  ReviewView({super.key, required this.reviewee});

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  bool buttonEnabled = false;
  double currentSlideVal = 1;
  String review = "";
  List<Icon> stars = [
    const Icon(Icons.star),
    const Icon(Icons.star_border),
    const Icon(Icons.star_border),
    const Icon(Icons.star_border),
    const Icon(Icons.star_border),
  ];

  void onChanged(double val) {
    setState(() {
      currentSlideVal = val;
      stars = List.generate(5, (index) {
        return Icon(
          index < currentSlideVal ? Icons.star : Icons.star_border,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make review"),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: stars,
              ),
              Slider(
                value: currentSlideVal,
                onChanged: onChanged,
                min: 1,
                max: 5,
                divisions: 4,
              ),
              SizedBox(
                height: 100,
                child: TextField(
                  decoration: const InputDecoration(hintText: "write review here"),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    setState(() {
                      buttonEnabled = !(value == "");
                      review = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: buttonEnabled
                    ? () async {
                        int ratingVal = currentSlideVal.floor();
                        SnackBar snackBar = await widget.controller.makeReview(review, ratingVal);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    : null,
                child: const Text("Review and Rate"),
              ),
              const SizedBox(height: 10),
              Text(buttonEnabled ? "" : "please enter a review to submit"),
            ],
          ),
        ),
      ),
    );
  }
}
