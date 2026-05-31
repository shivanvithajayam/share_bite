import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewDialog extends StatefulWidget {
  final String donorId;
  final String donationId;

  const ReviewDialog({
    super.key,
    required this.donorId,
    required this.donationId,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int rating = 5;
  final reviewCtrl = TextEditingController();

  Future<void> submitReview() async {
    final ngoId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.donationId)
        .set({
          'reviewType': 'ngo_to_donor',

          'reviewerId': ngoId,
          'reviewerRole': 'ngo',

          'targetId': widget.donorId,
          'targetRole': 'donor',

          'donationId': widget.donationId,

          'rating': rating,
          'review': reviewCtrl.text.trim(),

          'createdAt': Timestamp.now(),
        });
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donationId)
        .update({'reviewSubmitted': true, 'reviewRating': rating});

    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Review submitted")));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rate Donor"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: List.generate(
              5,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 30,
                ),
              ),
            ),
          ),
          TextField(
            controller: reviewCtrl,
            decoration: const InputDecoration(hintText: "Write review"),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: submitReview, child: const Text("Submit")),
      ],
    );
  }
}
