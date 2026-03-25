import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import 'add_donation_screen.dart';
import 'donation_history_screen.dart';
import '../../widgets/active_donation_card.dart';
import '../../widgets/donation_status_badge.dart';

class DonorHomeScreen extends StatelessWidget {
  final UserModel user;
  const DonorHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final _donationService = DonationService();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.teal,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Hi, ${user.name.split(' ').first} 👋',
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
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
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
                  // ── Quick action buttons ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: '🍱',
                          label: 'Add\nDonation',
                          color: AppColors.mint,
                          textColor: AppColors.tealDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddDonationScreen(user: user),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: '📋',
                          label: 'Donation\nHistory',
                          color: AppColors.blush,
                          textColor: AppColors.roseDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DonationHistoryScreen(user: user),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Active donations ──────────────────────────────────────
                  const Text(
                    'Active Donations',
                    style: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 18,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pending until accepted or rejected',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Active donations stream ───────────────────────────────────────
          StreamBuilder<List<DonationModel>>(
            stream: _donationService.donorActiveDonations(user.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final donations = snap.data ?? [];
              if (donations.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Text('🍽️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No active donations',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap "Add Donation" to share food with those in need',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: ActiveDonationCard(donation: donations[i]),
                  ),
                  childCount: donations.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
