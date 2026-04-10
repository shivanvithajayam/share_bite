import '../common/donation_detail_screen.dart';
import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../dummy_data.dart';
import '../auth/login_screen.dart';

class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  late List<DonationModel> donations;

  @override
  void initState() {
    super.initState();
    donations = DummyData.pendingDonations;
  }

  void _updateStatus(int index, String status) {
    setState(() {
      donations[index] = DonationModel(
        id: donations[index].id,
        donorId: donations[index].donorId,
        donorName: donations[index].donorName,
        donorPhone: donations[index].donorPhone,
        foodName: donations[index].foodName,
        quantity: donations[index].quantity,
        description: donations[index].description,
        expiryTime: donations[index].expiryTime,
        address: donations[index].address,
        latitude: donations[index].latitude,
        longitude: donations[index].longitude,
        status: status,
        createdAt: donations[index].createdAt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.rose,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'NGO Dashboard 🏠',
                      style: const TextStyle(
                        color: AppColors.roseDark,
                        fontFamily: 'DM Serif Display',
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Available food donations near you',
                      style: TextStyle(color: AppColors.roseDark, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.roseDark),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Available Donations',
                style: TextStyle(fontFamily: 'DM Serif Display', fontSize: 18),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              final d = donations[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _NgoCard(
                  donation: d,
                  onAccept: () => _updateStatus(i, 'accepted'),
                  onReject: () => _updateStatus(i, 'rejected'),
                ),
              );
            }, childCount: donations.length),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── CARD ─────────────────────────

class _NgoCard extends StatefulWidget {
  final DonationModel donation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _NgoCard({
    required this.donation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_NgoCard> createState() => _NgoCardState();
}

class _NgoCardState extends State<_NgoCard> {
  late Duration remaining;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  void _updateTime() {
    remaining = widget.donation.expiryTime.difference(DateTime.now());
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _updateTime();
      });

      return true;
    });
  }

  String formatTime(Duration d) {
    if (d.isNegative) return "Expired";

    final h = d.inHours;
    final m = d.inMinutes % 60;

    return "${h}h ${m}m";
  }

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DonationDetailScreen(donation: donation),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🍱', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation.foodName),
                      Text(donation.quantity),
                      Text(
                        donation.donorName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // ⏱ TIMER
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        formatTime(remaining),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('remaining', style: TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(donation.address),

            const SizedBox(height: 10),

            // STATUS
            Text(
              donation.status.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: donation.status == 'accepted'
                    ? Colors.green
                    : donation.status == 'rejected'
                    ? Colors.red
                    : Colors.orange,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
