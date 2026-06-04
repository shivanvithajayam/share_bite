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
    final ngoDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(ngoId)
        .get();

    final ngoData = ngoDoc.data() ?? {};
    final ngoName = ngoData['name'] ?? 'NGO';
    final donorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.donorId)
        .get();

    final donorName = donorDoc.data()?['name'] ?? 'Donor';

    await FirebaseFirestore.instance.collection('reviews').add({
      'reviewType': 'ngo_to_donor',

      'reviewerId': ngoId,
      'reviewerRole': 'ngo',
      'ngoName': ngoName,

      'targetId': widget.donorId,
      'targetRole': 'donor',
      'targetName': donorName,

      'donationId': widget.donationId,

      'rating': rating,
      'review': reviewCtrl.text.trim(),

      'createdAt': Timestamp.now(),
    });
    print("NGO REVIEW SAVED FOR ${widget.donorId}");
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donationId)
        .update({'reviewSubmitted': true, 'reviewRating': rating});
    print("DONATION UPDATED");

    final data = donorDoc.data() ?? {};

    final oldAverage = ((data['averageRating'] ?? 0) as num).toDouble();

    final totalReviews = ((data['totalReviews'] ?? 0) as num).toInt();

    final newAverage =
        ((oldAverage * totalReviews) + rating) / (totalReviews + 1);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.donorId)
        .update({
          'averageRating': newAverage,
          'totalReviews': totalReviews + 1,
        });

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
                  size: 25,
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
