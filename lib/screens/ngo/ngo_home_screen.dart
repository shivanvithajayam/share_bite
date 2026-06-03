import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../profile/ngo_profile_sheet.dart';
import '../profile/edit_ngo_profile_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'review_dialog.dart';
import 'dart:async';
import 'ngo_live_tracking_screen.dart';
import 'donor_reviews_screen.dart';

class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  bool showPast = false;
  bool _popupShown = false;
  StreamSubscription<Position>? positionStream;
  Future<void> fixAllDonorRatings() async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('targetRole', isEqualTo: 'donor')
        .get();

    Map<String, List<double>> donorRatings = {};

    for (var doc in reviewsSnapshot.docs) {
      final data = doc.data();

      final donorId = data['targetId'];
      final rating = ((data['rating'] ?? 0) as num).toDouble();

      donorRatings.putIfAbsent(donorId, () => []);
      donorRatings[donorId]!.add(rating);
    }

    for (var entry in donorRatings.entries) {
      final donorId = entry.key;
      final ratings = entry.value;

      final avg = ratings.reduce((a, b) => a + b) / ratings.length;

      await FirebaseFirestore.instance.collection('users').doc(donorId).update({
        'averageRating': avg,
        'totalReviews': ratings.length,
      });

      print("Updated $donorId → ${avg.toStringAsFixed(1)} (${ratings.length})");
    }
  }

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
    fixAllDonorRatings();

    _checkNgoProfileCompletion();
  }

  @override

Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get(),
    builder: (context, userSnapshot) {

      if (!userSnapshot.hasData) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final userData =
          userSnapshot.data!.data() as Map<String, dynamic>;

      final ngoCreatedAt =
          userData['createdAt'] as Timestamp;

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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F6E56), // dark teal
                      Color(0xFF1D9E75), // mid teal
                      Color(0xFF5DCAA5), // light teal
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
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

                    child: Icon(Icons.person, color: AppColors.teal),
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
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showPast = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !showPast
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Today",
                            style: TextStyle(
                              color: !showPast
                                  ? Colors.white
                                  : AppColors.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showPast = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: showPast
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Past",
                            style: TextStyle(
                              color: showPast
                                  ? Colors.white
                                  : AppColors.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
          .where(
            'acceptedByNgoId',
            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
          )
          .where('status', whereIn: ['completed', 'rejected'])
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: ngoCreatedAt,
          )
          .orderBy('createdAt', descending: true)
          .snapshots()
    : FirebaseFirestore.instance
          .collection('donations')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: ngoCreatedAt,
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.data!.docs;

               

                final donations = docs
                    .map((doc) => DonationModel.fromFirestore(doc))
                    .toList();

                /// ACTIVE PICKUPS
                final activeDonations = donations.where((donation) {
                  return donation.status == 'accepted' ||
                      donation.status == 'pickup_started' ||
                      donation.status == 'arrived';
                }).toList();

                /// AVAILABLE DONATIONS
                final availableDonations = donations.where((donation) {
                  return donation.status == 'pending';
                }).toList();

                /// PAST DONATIONS
                final pastDonations = donations.where((donation) {
                  return donation.status == 'completed' ||
                      donation.status == 'rejected';
                }).toList();
                if (!showPast &&
                    activeDonations.isEmpty &&
                    availableDonations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No Donations Available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Check back later for new donations",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (showPast && pastDonations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 70, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            "No Past Donations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Completed donations will appear here",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    /// TODAY TAB
                    if (!showPast) ...[
                      /// ACTIVE PICKUPS
                      if (activeDonations.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 2, 20, 6),

                          child: Align(
                            alignment: Alignment.centerLeft,

                            child: Text(
                              " Active Pickups",

                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          children: activeDonations.map((donation) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),

                              child: _DonationCard(
                                donation: donation,
                                showPast: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      /// AVAILABLE DONATIONS
                      if (availableDonations.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              " Available Donations",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        Column(
                          children: availableDonations.map((donation) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                              child: _DonationCard(
                                donation: donation,
                                showPast: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      if (activeDonations.isEmpty &&
                          availableDonations.isEmpty) ...[
                        const SizedBox(height: 140),

                        Center(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "No Donations Available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Check back later for new donations",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    /// PAST TAB
                    /// PAST TAB
                    if (showPast) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            " Past Accepted Donations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pastDonations.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                            child: _DonationCard(
                              donation: pastDonations[index],
                              showPast: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
            ),
    );
    },
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
  bool pickupStartedLocal = false;
  StreamSubscription<Position>? positionStream;
  @override
  void initState() {
    super.initState();

    calculateDistance();
    startTimer();
  }

  Future<void> acceptDonation() async {
    final user = FirebaseAuth.instance.currentUser;

    final ngoDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final ngoData = ngoDoc.data();

    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donation.id)
        .update({
          "status": "accepted",
          "pickupStarted": false,
          "acceptedAt": Timestamp.now(),
          "acceptedByNgoId": user.uid,
          "ngoName": ngoData?['name'] ?? "",
          "ngoPhone": ngoData?['phone'] ?? "",
        });
        await FirebaseFirestore.instance
    .collection('notifications')
    .add({
  'userId': widget.donation.donorId,
  'title': 'Donation Accepted',
  'message': '${ngoData?['name']} accepted your donation',
  'createdAt': Timestamp.now(),
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

      final remaining = const Duration(minutes: 30) - difference;

      if (!mounted) return false;

      setState(() {
        remainingTime = remaining;
      });

      await Future.delayed(const Duration(seconds: 1));

      return remaining.inSeconds > 0;
    });
  }

  Future<void> startLiveTracking() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    /// immediately show tracking button
    /// GET CURRENT LOCATION FIRST
    Position currentPosition = await Geolocator.getCurrentPosition();

    /// SAVE INITIAL LOCATION

    await FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donation.id)
        .update({
          'pickupStarted': true,
          'status': 'pickup_started',

          'ngoLat': currentPosition.latitude,

          'ngoLng': currentPosition.longitude,
        });
        await FirebaseFirestore.instance
    .collection('notifications')
    .add({
  'userId': widget.donation.donorId,
  'title': 'Pickup Started',
  'message': 'NGO is on the way',
  'createdAt': Timestamp.now(),
});

    setState(() {
      pickupStartedLocal = true;
    });

    /// THEN START LIVE UPDATES
    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,

            distanceFilter: 15,
          ),
        ).listen((Position position) async {
          if (position.accuracy > 20) {
            return;
          }

          await FirebaseFirestore.instance
              .collection('donations')
              .doc(widget.donation.id)
              .update({
                'ngoLat': position.latitude,
                'ngoLng': position.longitude,
              });
        });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;
    if (donation.status == 'pending') {
      if ((distanceKm != null && distanceKm! > 5) ||
          (remainingTime != null && remainingTime!.inMinutes <= -5)) {
        return const SizedBox.shrink();
      }
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

                  Text(donation.quantity, style: const TextStyle(fontSize: 12)),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(donation.donorId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.data() == null) {
                        return const SizedBox();
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      final rating = ((data['averageRating'] ?? 0) as num)
                          .toDouble();

                      final reviews = ((data['totalReviews'] ?? 0) as num)
                          .toInt();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DonorReviewsScreen(donorId: donation.donorId),
                            ),
                          );
                        },

                        child: Row(
                          children: [
                            const SizedBox(width: 3),

                            reviews == 0
    ? const SizedBox()
                                : Text(
                                    "⭐ ${rating.toStringAsFixed(1)}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: 16,

                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.tealDark,
                          fontWeight: FontWeight.w500,
                        ),

                        children: [
                          const TextSpan(text: "📍 "),

                          TextSpan(
                            text: distanceKm == null
                                ? "     " // 5 spaces
                                : distanceKm!.toStringAsFixed(1),
                          ),

                          const TextSpan(text: " km away"),
                        ],
                      ),
                    ),
                  ),
                  if (remainingTime != null && donation.status == 'pending')
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
            /// RIGHT SIDE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,

              children: [
                /// STATUS CHIP
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: donation.status == 'pending'
                        ? const Color(0xFFFFF3CD)
                        : donation.status == 'accepted'
                        ? const Color(0xFFD6EAF8)
                        : donation.status == 'pickup_started'
                        ? const Color(0xFFD5F5E3)
                        : donation.status == 'completed'
                        ? const Color(0xFFE5E7E9)
                        : const Color(0xFFFADBD8),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    donation.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: donation.status == 'pending'
                          ? Colors.orange.shade800
                          : donation.status == 'accepted'
                          ? Colors.blue.shade800
                          : donation.status == 'pickup_started'
                          ? Colors.green.shade800
                          : donation.status == 'completed'
                          ? Colors.black87
                          : Colors.red.shade800,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                /// START PICKUP
                if (donation.status == 'accepted')
                  SizedBox(
                    height: 30,

                    child: ElevatedButton(
                      onPressed: () async {
                        await startLiveTracking();
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,

                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),

                      child: const Text(
                        "Start Pickup",

                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ),

                /// NAVIGATE
                if (donation.status == 'pickup_started' ||
                    donation.status == 'arrived')
                  SizedBox(
                    height: 30,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                NgoLiveTrackingScreen(donationId: donation.id),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,

                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),

                      child: const Text(
                        "Navigate",

                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ),

                /// REVIEW
                if (widget.showPast &&
                    donation.status == 'completed' &&
                    !donation.reviewSubmitted)
                  SizedBox(
                    height: 30,

                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ReviewDialog(
                            donorId: donation.donorId,
                            donationId: donation.id,
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),

                      child: const Text(
                        "⭐ Review",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ),

                /// SHOW RATING AFTER REVIEW
                if (widget.showPast &&
                    donation.status == 'completed' &&
                    donation.reviewSubmitted)
                  Row(
                    mainAxisSize: MainAxisSize.min,

                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (donation.reviewRating ?? 0)
                            ? Icons.star
                            : Icons.star_border,

                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
              ],
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

          if (remainingTime != null && donation.status == 'pending')
            _infoRow(
              "⏰ Time Left",

              remainingTime!.inSeconds <= 0
                  ? "Expired"
                  : "${remainingTime!.inMinutes} minutes",
            ),

          _infoRow("📝 Description", donation.description),

          _infoRow(
            "🕒 Posted At",
            "${donation.createdAt.hour.toString().padLeft(2, '0')}:"
                "${donation.createdAt.minute.toString().padLeft(2, '0')}",
          ),

          const SizedBox(height: 14),

          /// ACTIVE PICKUPS

          /// BUTTONS ONLY FOR TODAY
          /// PENDING DONATIONS
          if (donation.status == 'pending')
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

                    child: const Text(
                      "Accept",

                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,

                      padding: const EdgeInsets.symmetric(vertical: 12),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: rejectDonation,

                    child: const Text(
                      "Reject",

                      style: TextStyle(color: Colors.black),
                    ),
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
