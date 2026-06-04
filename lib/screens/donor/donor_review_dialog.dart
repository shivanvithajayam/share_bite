import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonorReviewDialog extends StatefulWidget {
  final String ngoId;
  final String donationId;

  const DonorReviewDialog({
    super.key,
    required this.ngoId,
    required this.donationId,
  });

  @override
  State<DonorReviewDialog> createState() => _DonorReviewDialogState();
}

class _DonorReviewDialogState extends State<DonorReviewDialog> {
  int rating = 5;
  final reviewCtrl = TextEditingController();

  Future<void> submitReview() async {
    final donorId = FirebaseAuth.instance.currentUser!.uid;

    final donorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(donorId)
        .get();

    final donorData = donorDoc.data() ?? {};
    final donorName = donorData['name'] ?? 'Donor';
    final ngoDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ngoId)
        .get();
    final ngoName = ngoDoc.data()?['name'] ?? 'NGO';

    await FirebaseFirestore.instance.collection('reviews').add({
      'reviewType': 'donor_to_ngo',

      'reviewerRole': 'donor',
      'donorName': donorName,

      'targetId': widget.ngoId,
      'targetRole': 'ngo',
      'targetName': ngoName,

      'donationId': widget.donationId,

      'rating': rating,
      'review': reviewCtrl.text.trim(),

      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donationId)
        .update({'donorReviewSubmitted': true, 'donorReviewRating': rating});

    final ngoData = ngoDoc.data() ?? {};

    final oldAverage = ((ngoData['averageRating'] ?? 0) as num).toDouble();

    final totalReviews = ((ngoData['totalReviews'] ?? 0) as num).toInt();

    final newAverage =
        ((oldAverage * totalReviews) + rating) / (totalReviews + 1);
    print("Updating NGO: ${widget.ngoId}");
    print("Old Avg: $oldAverage");
    print("Total Reviews: $totalReviews");
    print("New Avg: $newAverage");
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.ngoId)
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
      title: const Text("Rate NGO"),
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
