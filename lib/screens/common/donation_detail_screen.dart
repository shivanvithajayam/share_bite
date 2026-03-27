import 'package:flutter/material.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';

class DonationDetailScreen extends StatelessWidget {
  final DonationModel donation;

  const DonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Donation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍱 Image placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🍱', style: TextStyle(fontSize: 60)),
              ),
            ),

            const SizedBox(height: 20),

            // Food name
            Text(
              donation.foodName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              donation.quantity,
              style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
            ),

            const SizedBox(height: 16),

            // Donor Info
            _sectionTitle('Donor Details'),
            _infoRow('Name', donation.donorName),
            _infoRow('Phone', donation.donorPhone),

            const SizedBox(height: 16),

            // Address
            _sectionTitle('Pickup Location'),
            Text(donation.address, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 16),

            // Description
            _sectionTitle('Description'),
            Text(donation.description, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 20),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                donation.status.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.tealDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
