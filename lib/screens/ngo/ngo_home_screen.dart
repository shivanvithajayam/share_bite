import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../profile/ngo_profile_sheet.dart';
import '../profile/edit_ngo_profile_sheet.dart';
import 'package:geolocator/geolocator.dart';
class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  bool showPast = false;
  bool _popupShown = false;
  void _openNgoProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (context) {
      return const NgoProfileSheet();
    },
  );
}
Future<void> _checkNgoProfileCompletion() async {

  if (_popupShown) return;

  final user = FirebaseAuth.instance.currentUser;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

  final data = doc.data();

  final address = data?['address'] ?? "";

  if (address.toString().trim().isEmpty) {

    _popupShown = true;

    Future.delayed(Duration.zero, () {

      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,

        builder: (context) {
          return const EditNgoProfileSheet();
        },
      );
    });
  }
}
@override
void initState() {
  super.initState();

  _checkNgoProfileCompletion();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,

      body: CustomScrollView(
        slivers: [
          /// TOP BAR
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
  Padding(
    padding: const EdgeInsets.only(right: 12),
    child: GestureDetector(
      onTap: () {
        _openNgoProfileSheet(context);
      },

      child: const CircleAvatar(
        backgroundColor: Colors.white,

        child: Icon(
          Icons.person,
          color: AppColors.teal,
        ),
      ),
    ),
  ),
],
          ),

          /// TODAY / PAST TOGGLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPast = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: !showPast ? AppColors.blush : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Today"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPast = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: showPast ? AppColors.mint : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Past"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// DONATION LIST
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: showPast

? FirebaseFirestore.instance
    .collection('donations')
    .where('status', isEqualTo: 'accepted')
    .where(
      'acceptedByNgoId',
      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
    )
    .orderBy('createdAt', descending: true)
    .snapshots()

: FirebaseFirestore.instance
    .collection('donations')
    .where('status', isEqualTo: 'pending')
    .orderBy('createdAt', descending: true)
    .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
  return Center(
    child: Text(snapshot.error.toString()),
  );
}
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Center(
                      child: Text(
                        showPast
                            ? "No accepted donations yet"
                            : "No donations available right now",
                      ),
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
                      child: _DonationCard(
                        donation: donations[index],
                        showPast: showPast,
                      ),
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
  final bool showPast;

  const _DonationCard({required this.donation, required this.showPast});

  @override
  State<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<_DonationCard> {
  double? distanceKm;
  Duration? remainingTime;
  @override
void initState() {
  super.initState();

  calculateDistance();
  startTimer();
}
  Future<void> acceptDonation() async {

  final user = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance
      .collection('donations')
      .doc(widget.donation.id)
      .update({

    "status": "accepted",
    "acceptedAt": Timestamp.now(),
    "acceptedByNgoId": user!.uid,
  });
}

  Future<void> rejectDonation() async {
    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donation.id)
        .update({"status": "rejected"});
  }
  Future<void> calculateDistance() async {

  final user = FirebaseAuth.instance.currentUser;

  final ngoDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

  final ngoData = ngoDoc.data();

  if (ngoData == null) return;

  final ngoLat = ngoData['latitude'];
  final ngoLng = ngoData['longitude'];

  final donationLat = widget.donation.latitude;
  final donationLng = widget.donation.longitude;

  if (ngoLat == null ||
      ngoLng == null ||
      donationLat == 0 ||
      donationLng == 0) {
    return;
  }

  double meters = Geolocator.distanceBetween(
    ngoLat,
    ngoLng,
    donationLat,
    donationLng,
  );

  setState(() {
    distanceKm = meters / 1000;
  });
}

  
  void startTimer() {

  final createdAt = widget.donation.createdAt;

  Future.doWhile(() async {

    final now = DateTime.now();

    final difference = now.difference(createdAt);

    final remaining =
        const Duration(minutes: 30) - difference;

    if (!mounted) return false;

    setState(() {
      remainingTime = remaining;
    });

    await Future.delayed(const Duration(seconds: 1));

    return remaining.inSeconds > 0;
  });
}@override
  Widget build(BuildContext context) {
    final donation = widget.donation;
  if (
  (distanceKm != null && distanceKm! > 5) ||

  (remainingTime != null &&
      remainingTime!.inMinutes <= -5)
){
  return const SizedBox.shrink();
}
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),

      child: ExpansionTile(
        key: PageStorageKey(donation.id),

        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

        title: Row(
          children: [
            /// IMAGE
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.blush,
              ),

              child: donation.imageUrl != null && donation.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        donation.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Text('🍱', style: TextStyle(fontSize: 24)),
                    ),
            ),

            const SizedBox(width: 14),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.foodName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  Text(
  donation.quantity,
  style: const TextStyle(fontSize: 12),
),

if (distanceKm != null)
  Text(
    "📍 ${distanceKm!.toStringAsFixed(1)} km away",
    style: const TextStyle(
      fontSize: 11,
      color: AppColors.tealDark,
      fontWeight: FontWeight.w500,
    ),
  ),

if (remainingTime != null)
  Text(
    remainingTime!.inSeconds <= 0
        ? "⛔ Expired"
        : "⏰ ${remainingTime!.inMinutes} min left",
    style: TextStyle(
      fontSize: 11,
      color: remainingTime!.inMinutes <= 10
          ? Colors.red
          : AppColors.tealDark,
      fontWeight: FontWeight.w600,
    ),
  ),
                ],
              ),
            ),

            /// STATUS CHIP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                widget.showPast ? "ACCEPTED" : "PENDING",

                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        children: [
          const SizedBox(height: 10),

          _infoRow("🍱 Food", donation.foodName),

_infoRow("📦 Quantity", donation.quantity),

_infoRow("👤 Donor", donation.donorName),

_infoRow("📞 Phone", donation.donorPhone),

_infoRow("📍 Pickup Address", donation.address),

if (distanceKm != null)
  _infoRow(
    "📏 Distance",
    "${distanceKm!.toStringAsFixed(1)} km away",
  ),

if (remainingTime != null)

  _infoRow(
    "⏰ Time Left",

    remainingTime!.inSeconds <= 0
        ? "Expired"
        : "${remainingTime!.inMinutes} minutes",
  ),

_infoRow(
  "📝 Description",
  donation.description,
),

_infoRow(
  "🕒 Posted At",
  "${donation.createdAt.hour.toString().padLeft(2, '0')}:"
  "${donation.createdAt.minute.toString().padLeft(2, '0')}",
),

          const SizedBox(height: 14),

          /// BUTTONS ONLY FOR TODAY
          if (!widget.showPast)
            Row(
              children: [
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
    );
  }
}

/// INFO ROW
Widget _infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),

        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}
