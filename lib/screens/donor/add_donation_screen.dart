import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/user_model.dart';
import '../../models/donation_model.dart';
import '../../services/donation_service.dart';
import '../../utils/app_theme.dart';

class AddDonationScreen extends StatefulWidget {
  final UserModel user;
  const AddDonationScreen({super.key, required this.user});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _foodNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  DateTime? _expiryTime;
  File? _photo;
  bool _loading = false;
  double? _lat, _lng;
  final _service = DonationService();

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _quantityCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(
      () => _expiryTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('Location services disabled');
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        _snack('Permission denied');
        return;
      }
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _addressCtrl.text =
          'Current location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
    });
  }

  Future<void> _post() async {
    if (_foodNameCtrl.text.isEmpty ||
        _quantityCtrl.text.isEmpty ||
        _expiryTime == null ||
        _addressCtrl.text.isEmpty) {
      _snack('Please fill all required fields');
      return;
    }
    if (_lat == null) {
      _snack('Please set location');
      return;
    }
    setState(() => _loading = true);

    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      String? photoUrl;
      if (_photo != null) {
        photoUrl = await _service.uploadPhoto(_photo!, tempId);
      }

      final donation = DonationModel(
        id: '',
        donorId: widget.user.uid,
        donorName: widget.user.name,
        donorPhone: widget.user.phone,
        foodName: _foodNameCtrl.text.trim(),
        quantity: _quantityCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        expiryTime: _expiryTime!,
        photoUrl: photoUrl,
        address: _addressCtrl.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _service.postDonation(donation);
      if (!mounted) return;
      _snack('Donation posted! NGOs nearby will be notified.');
      Navigator.pop(context);
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Donation',
          style: TextStyle(fontFamily: 'DM Serif Display'),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Auto-filled donor info ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.tealDark, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.tealDark,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.user.phone,
                        style: const TextStyle(
                          color: AppColors.tealDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Auto-filled',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _sectionLabel('Food Details'),
            _field(
              _foodNameCtrl,
              'Food name *',
              'e.g. Biryani, Chapati',
              Icons.restaurant_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              _quantityCtrl,
              'Quantity *',
              'e.g. 10 plates, 5 kg',
              Icons.format_list_numbered_outlined,
            ),
            const SizedBox(height: 12),
            _field(
              _descCtrl,
              'Description',
              'Any special notes...',
              Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Expiry time
            _sectionLabel('Expiry Time *'),
            GestureDetector(
              onTap: _pickExpiry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sand, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _expiryTime == null
                          ? 'Select expiry date & time'
                          : '${_expiryTime!.day}/${_expiryTime!.month}/${_expiryTime!.year} '
                                '${_expiryTime!.hour.toString().padLeft(2, '0')}:'
                                '${_expiryTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _expiryTime == null
                            ? AppColors.mutedText
                            : AppColors.darkText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photo upload
            _sectionLabel('Photo (Optional)'),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sand,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: AppColors.mutedText,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to upload photo',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Address
            _sectionLabel('Pickup Address *'),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _addressCtrl,
                    'Address',
                    'Enter pickup address',
                    Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.tealDark,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _post,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism, size: 20),
                          SizedBox(width: 8),
                          Text('Post Donation', fontSize: 16),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: AppColors.mutedText,
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.mutedText),
      ),
    );
  }
}
