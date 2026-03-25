import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';

class DonationDetailScreen extends StatelessWidget {
  final DonationModel donation;
  const DonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final isAccepted = donation.status == 'accepted';
    final isRejected = donation.status == 'rejected';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'Donation Details',
          style: TextStyle(fontFamily: 'DM Serif Display'),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAccepted
                    ? AppColors.mint
                    : isRejected
                    ? const Color(0xFFFFEBEE)
                    : AppColors.blush,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    isAccepted
                        ? '✅'
                        : isRejected
                        ? '❌'
                        : '⏳',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAccepted
                            ? 'Donation Accepted'
                            : isRejected
                            ? 'Donation Rejected'
                            : 'Awaiting Response',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: isAccepted
                              ? AppColors.tealDark
                              : isRejected
                              ? const Color(0xFFC62828)
                              : AppColors.roseDark,
                        ),
                      ),
                      if (donation.acceptedAt != null)
                        Text(
                          '${donation.acceptedAt!.day}/${donation.acceptedAt!.month}/${donation.acceptedAt!.year} '
                          '${donation.acceptedAt!.hour.toString().padLeft(2, '0')}:'
                          '${donation.acceptedAt!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Photo
            if (donation.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  donation.photoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            // Details card
            _InfoCard(
              children: [
                _row('Food', donation.foodName),
                _row('Quantity', donation.quantity),
                if (donation.description.isNotEmpty)
                  _row('Description', donation.description),
                _row(
                  'Expiry',
                  '${donation.expiryTime.day}/${donation.expiryTime.month}/${donation.expiryTime.year} '
                      '${donation.expiryTime.hour.toString().padLeft(2, '0')}:'
                      '${donation.expiryTime.minute.toString().padLeft(2, '0')}',
                ),
                _row('Address', donation.address),
                _row('Donation ID', donation.id.substring(0, 8).toUpperCase()),
              ],
            ),
            const SizedBox(height: 16),

            // Donor info
            _InfoCard(
              title: 'Donor',
              children: [
                _row('Name', donation.donorName),
                _row('Phone', donation.donorPhone),
              ],
            ),

            // NGO info (if accepted)
            if (isAccepted && donation.acceptedByNgoName != null) ...[
              const SizedBox(height: 16),
              _InfoCard(
                title: 'Accepted by NGO',
                children: [
                  _row('NGO Name', donation.acceptedByNgoName!),
                  _row('Phone', donation.acceptedByNgoPhone ?? '-'),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 15,
                color: AppColors.darkText,
              ),
            ),
            const Divider(color: AppColors.sand),
          ],
          ...children,
        ],
      ),
    );
  }
}
