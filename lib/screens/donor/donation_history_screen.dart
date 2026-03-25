import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../utils/app_theme.dart';
import 'donation_detail_screen.dart';

class DonationHistoryScreen extends StatelessWidget {
  final UserModel user;
  const DonationHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final service = DonationService();
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'My Donations',
          style: TextStyle(fontFamily: 'DM Serif Display'),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<DonationModel>>(
        stream: service.donorDonations(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📦', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'No donations yet',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final d = list[i];
              return _HistoryCard(donation: d);
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DonationModel donation;
  const _HistoryCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final statusColor = donation.status == 'accepted'
        ? AppColors.teal
        : donation.status == 'rejected'
        ? const Color(0xFFE57373)
        : AppColors.sand;
    final statusBg = donation.status == 'accepted'
        ? AppColors.mint
        : donation.status == 'rejected'
        ? const Color(0xFFFFEBEE)
        : AppColors.cream;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationDetailScreen(donation: donation),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sand, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    donation.foodName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    donation.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.tag, size: 13, color: AppColors.mutedText),
                const SizedBox(width: 4),
                Text(
                  donation.id.substring(0, 8).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  '${donation.createdAt.day}/${donation.createdAt.month}/${donation.createdAt.year}',
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (donation.status == 'accepted' &&
                donation.acceptedByNgoName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.acceptedByNgoName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColors.tealDark,
                          ),
                        ),
                        Text(
                          donation.acceptedByNgoPhone ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.tealDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap for details →',
                style: TextStyle(color: AppColors.teal, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
