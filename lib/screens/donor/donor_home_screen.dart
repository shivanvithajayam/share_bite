import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_donation_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/edit_profile_sheet.dart';
import 'live_tracking_screen.dart';
import 'donor_review_dialog.dart';
import 'ngo_reviews_screen.dart';
import '../../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  bool showToday = true;
Set<String> shownNotifications = {};
@override
void initState() {
  super.initState();
  listenForNotifications();
}

void listenForNotifications() {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .listen((snapshot) {
    for (final doc in snapshot.docs) {
      if (!shownNotifications.contains(doc.id)) {
        shownNotifications.add(doc.id);

        final data = doc.data();
      
        NotificationService.localNotifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          data['title'] ?? 'Notification',
          data['message'] ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sharebite_channel',
              'ShareBite Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  });
}
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: AppColors.cream,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F6E56),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDonationScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: CustomScrollView(
        slivers: [
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            'Hi 👋',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return Text(
                          'Hi, ${data['name'] ?? 'Donor'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Ready to share some kindness?',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        final user = FirebaseAuth.instance.currentUser;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .get(),

                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            return Container(
                              padding: const EdgeInsets.all(20),

                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),

                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 38,
                                      backgroundColor: const Color(0xFF0F6E56),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      data['name'] ?? "",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      data['email'] ?? "",
                                      style: const TextStyle(
                                        color: AppColors.mutedText,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    ListTile(
                                      leading: const Icon(Icons.phone),
                                      title: Text(data['phone'] ?? ""),
                                    ),

                                    ListTile(
                                      leading: const Icon(Icons.location_on),
                                      title: Text(
                                        data['address'] == null ||
                                                data['address']
                                                    .toString()
                                                    .isEmpty
                                            ? "No address added"
                                            : data['address'],
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text("Edit Profile"),
                                      onTap: () {
                                        Navigator.pop(context);

                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return const EditProfileSheet();
                                          },
                                        );
                                      },
                                    ),

                                    ListTile(
                                      leading: const Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                      ),

                                      title: const Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.red),
                                      ),

                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut();

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                          (_) => false,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppColors.teal),
                  ),
                ),
              ),
            ],
          ),

          /// 🔘 TOGGLE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showToday = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: showToday
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Today",
                            style: TextStyle(
                              color: showToday
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
                      onTap: () => setState(() => showToday = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !showToday
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "Past",
                            style: TextStyle(
                              color: !showToday
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

          /// 📦 LIST
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('donations')
                  .where('donorId', isEqualTo: user!.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final donations = docs
                    .map((doc) => DonationModel.fromFirestore(doc))
                    .toList();

                final activeDonations = donations.where((d) {
                  return d.status == 'accepted' ||
                      d.status == 'pickup_started' ||
                      d.status == 'arrived';
                }).toList();

                final normalDonations = donations.where((d) {
                  return d.status == 'pending';
                }).toList();

                final pastDonations = donations.where((d) {
                  return (d.status == 'completed' || d.status == 'rejected');
                }).toList();

                final displayList = showToday
                    ? [...activeDonations, ...normalDonations]
                    : pastDonations;
                if (showToday &&
                    activeDonations.isEmpty &&
                    normalDonations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.volunteer_activism_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No Donations Today",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Tap + to create a new donation",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!showToday && pastDonations.isEmpty) {
  return const Padding(
    padding: EdgeInsets.only(top: 120),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 70,
            color: Colors.grey,
          ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// ACTIVE PICKUPS
                    if (showToday && activeDonations.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 12),

                        child: Text(
                          "🚚 Active Pickup",

                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ...activeDonations.map(
                        (donation) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),

                          child: _DonationCard(donation: donation),
                        ),
                      ),
                    ],

                    /// OTHER DONATIONS
                    if (showToday && normalDonations.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),

                        child: Text(
                          "My Donations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ...normalDonations.map(
                        (donation) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),

                          child: _DonationCard(donation: donation),
                        ),
                      ),
                    ],

                    /// PAST DONATIONS
                    /// PAST DONATIONS
                    if (!showToday && pastDonations.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text(
                          "Past Donations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ...pastDonations.map(
                        (donation) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _DonationCard(donation: donation),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),
      child: ExpansionTile(
        key: PageStorageKey(donation.id), // ✅ IMPORTANT
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

        title: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE8F5E9),
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.foodName,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (donation.ngoName != null) ...[
                    Text(
                      donation.ngoName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(donation.acceptedByNgoId!)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                            {};

                        final rating = ((data['averageRating'] ?? 0) as num)
                            .toDouble();
                        final reviews = ((data['totalReviews'] ?? 0) as num)
                            .toInt();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NgoReviewsScreen(
                                  ngoId: donation.acceptedByNgoId!,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reviews == 0
                                    ? "None"
                                    : "${rating.toStringAsFixed(1)} ($reviews)",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: rating > 0 ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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

                if (donation.status == 'accepted' && !donation.pickupStarted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: const Text(
                      "Waiting",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (donation.pickupStarted && donation.status != 'completed')
                  SizedBox(
                    height: 30,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.green,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LiveTrackingScreen(donationId: donation.id),
                          ),
                        );
                      },

                      child: const Text(
                        "Track NGO",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ),
                  ),
                if (donation.status == 'completed' &&
                    donation.donorReviewSubmitted)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (donation.donorReviewRating ?? 0)
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
          _infoRow("🍽 Quantity", donation.quantity),
          _infoRow("📍 Address", donation.address),
          _infoRow("📝 Description", donation.description ?? "No description"),

          if (donation.status != 'completed' &&
    donation.status != 'rejected')
  _infoRow(
    "⏰ Expiry",
    getExpiryText(donation.expiryTime),
  ),

          _infoRow("📦 Status", donation.status),

          /// SHOW OTP
          if (donation.pickupStarted &&
              donation.pickupOtp != null &&
              donation.status != 'completed') ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),

                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  const Text(
                    "Your Pickup OTP",

                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    donation.pickupOtp!,

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,

                      letterSpacing: 6,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Share this OTP with NGO",

                    style: TextStyle(fontSize: 15, color: AppColors.tealDark),
                  ),
                ],
              ),
            ),
          ],

          if (donation.ngoName != null) ...[
            _infoRow("🤝 Accepted by", donation.ngoName!),

            if (donation.ngoPhone != null)
              _infoRow("📞 NGO Phone", donation.ngoPhone!),
          ],
          if (donation.status == 'completed' &&
              donation.donorAcknowledged &&
              !donation.donorReviewSubmitted) ...[
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DonorReviewDialog(
                      ngoId: donation.acceptedByNgoId!,
                      donationId: donation.id,
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text("Rate NGO"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 🔧 HELPER
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

String getExpiryText(DateTime expiry) {
  final now = DateTime.now();
  final diff = expiry.difference(now);

  if (diff.isNegative) {
    return "Expired";
  }

  if (diff.inHours > 0) {
    return "Expires in ${diff.inHours} hr";
  } else {
    return "Expires in ${diff.inMinutes} min";
  }
}
