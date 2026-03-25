import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../utils/app_theme.dart';
import '../donor/donation_detail_screen.dart';

class NgoHistoryScreen extends StatelessWidget {
  final UserModel user;
  const NgoHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final service = DonationService();
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.rose,
        foregroundColor: AppColors.roseDark,
        title: const Text(
          'Donation History',
          style: TextStyle(fontFamily: 'DM Serif Display'),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<DonationModel>>(
        stream: service.ngoHistory(user.uid),
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
                  Text('📋', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'No history yet',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 14),
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
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DonationDetailScreen(donation: d),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.sand),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d.foodName,
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
                              color: d.status == 'accepted'
                                  ? AppColors.mint
                                  : const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              d.status.toUpperCase(),
                              style: TextStyle(
                                color: d.status == 'accepted'
                                    ? AppColors.tealDark
                                    : Colors.red[400],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Donor: ${d.donorName}',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${d.createdAt.day}/${d.createdAt.month}/${d.createdAt.year}  '
                        '${d.createdAt.hour.toString().padLeft(2, '0')}:'
                        '${d.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${d.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
