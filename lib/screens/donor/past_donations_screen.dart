import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';

class PastDonationsScreen extends StatelessWidget {
  const PastDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Past Donations"),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .where('donorId', isEqualTo: user!.uid)
            .where('createdAt', isLessThan: Timestamp.fromDate(startOfDay))
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No past donations"));
          }

          final donations = docs
              .map((doc) => DonationModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, i) {
              final donation = donations[i];

              return ListTile(
                title: Text(donation.foodName),
                subtitle: Text(donation.quantity),
              );
            },
          );
        },
      ),
    );
  }
}