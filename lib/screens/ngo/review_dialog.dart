import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(widget.donationId)
        .set({
          'ngoId': widget.donorId,
          'donationId': widget.donationId,
          'rating': rating,
          'review': reviewCtrl.text.trim(),
          'createdAt': Timestamp.now(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
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
