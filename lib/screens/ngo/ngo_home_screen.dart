import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';

class NgoHomeScreen extends StatelessWidget {
  const NgoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,

      body: CustomScrollView(
        slivers: [
          /// TOP BAR (same style as donor)
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.teal,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Available Donations",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Nearby food donations",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            /// LOGOUT
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),

          /// DONATION LIST
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Text("No donations available right now"),
                    ),
                  );
                }

                final donations = docs
                    .map((doc) => DonationModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _DonationCard(donation: donations[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatefulWidget {
  final DonationModel donation;

  const _DonationCard({required this.donation});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  bool expanded = false;
  Duration getRemainingTime() {
    final created = widget.donation.createdAt.toDate();
    final expiry = created.add(const Duration(minutes: 30));
    final remaining = expiry.difference(DateTime.now());

    if (remaining.isNegative) {
      rejectDonation(); // auto reject
      return Duration.zero;
    }

    return remaining;
  }

  Future<void> acceptDonation() async {
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donation.id)
        .update({
          "status": "accepted",
          "ngoName": "Helping Hands NGO",
          "ngoPhone": "9876543210",
          "acceptedAt": Timestamp.now(),
        });
  }

  Future<void> rejectDonation() async {
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donation.id)
        .update({"status": "rejected"});
  }

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),

      child: Column(
        children: [
          /// CARD HEADER
          ListTile(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },

            leading: donation.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      donation.imageUrl!,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Text("🍱", style: TextStyle(fontSize: 28)),

            title: Text(
              donation.foodName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            subtitle: Text(donation.quantity),

            trailing: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
          ),

          /// EXPANDED DETAILS
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),

                  _infoRow("Donor", donation.donorName),
                  _infoRow("Phone", donation.donorPhone),
                  _infoRow("Address", donation.address),
                  _infoRow("Description", donation.description),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      /// ACCEPT BUTTON
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: acceptDonation,
                          child: const Text("Accept"),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// REJECT BUTTON
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: rejectDonation,
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// INFO ROW
Widget _infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
