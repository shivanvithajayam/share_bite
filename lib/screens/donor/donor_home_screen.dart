import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';
import '../../dummy_data.dart';
import '../auth/login_screen.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donations = DummyData.activeDonations.toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hi, Donor👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'DM Serif Display',
                        fontSize: 24,
                      ),
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
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Donations',
                    style: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 18,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // List
          donations.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(child: Text('No donations yet')),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    final d = donations[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _DonationCard(donation: d),
                    );
                  }, childCount: donations.length),
                ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final DonationModel donation;
  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sand),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🍱', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.foodName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(donation.quantity, style: const TextStyle(fontSize: 12)),
                Text(donation.address, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              donation.status.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
