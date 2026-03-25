import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import '../donor/donation_detail_screen.dart';
import 'ngo_history_screen.dart';

class NgoHomeScreen extends StatefulWidget {
  final UserModel user;
  const NgoHomeScreen({super.key, required this.user});

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  final _service = DonationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.rose,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.rose,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.user.name} 🏠',
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
                icon: const Icon(Icons.history, color: AppColors.roseDark),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NgoHistoryScreen(user: widget.user),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.roseDark),
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: const Text(
                'Available Donations',
                style: TextStyle(
                  fontFamily: 'DM Serif Display',
                  fontSize: 18,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),

          // ── Donation stream ───────────────────────────────────────────────
          StreamBuilder<List<DonationModel>>(
            stream: _service.allPendingDonations(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Text('🍽️', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text(
                            'No pending donations',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 14,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _NgoDonationCard(
                      donation: list[i],
                      ngoUser: widget.user,
                      service: _service,
                    ),
                  ),
                  childCount: list.length,
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

class _NgoDonationCard extends StatefulWidget {
  final DonationModel donation;
  final UserModel ngoUser;
  final DonationService service;

  const _NgoDonationCard({
    required this.donation,
    required this.ngoUser,
    required this.service,
  });

  @override
  State<_NgoDonationCard> createState() => _NgoDonationCardState();
}

class _NgoDonationCardState extends State<_NgoDonationCard> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final deadline = widget.donation.createdAt.add(const Duration(minutes: 30));
    final now = DateTime.now();
    _secondsLeft = deadline.difference(now).inSeconds;
    if (_secondsLeft <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    if (_secondsLeft <= 0) return 'Expired';
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsLeft <= 0) return Colors.grey;
    if (_secondsLeft < 300) return Colors.red;
    if (_secondsLeft < 600) return Colors.orange;
    return AppColors.teal;
  }

  Future<void> _accept() async {
    await widget.service.acceptDonation(
      donationId: widget.donation.id,
      ngoId: widget.ngoUser.uid,
      ngoName: widget.ngoUser.name,
      ngoPhone: widget.ngoUser.phone,
    );
    if (mounted) _snack('Donation accepted! Donor notified.');
  }

  Future<void> _reject() async {
    await widget.service.rejectDonation(widget.donation.id);
    if (mounted) _snack('Donation rejected.');
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationDetailScreen(donation: widget.donation),
        ),
      ),
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
                if (widget.donation.photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.donation.photoUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                else
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
                      Text(
                        widget.donation.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.donation.quantity,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        widget.donation.donorName,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _timerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _timerColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        _timerText,
                        style: TextStyle(
                          color: _timerColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'remaining',
                      style: TextStyle(color: _timerColor, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.donation.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Accept / Reject
            if (_secondsLeft > 0)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[200]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _accept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Timer expired',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
