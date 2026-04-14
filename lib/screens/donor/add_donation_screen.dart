import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _foodCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;

  // 🔥 Upload to Cloudinary
  Future<String?> _uploadToCloudinary(File imageFile) async {
    print("Uploading started...");
    try {
      final url = Uri.parse(
          "https://api.cloudinary.com/v1_1/dnalkvgi3/image/upload");

      final request = http.MultipartRequest("POST", url);

      request.fields['upload_preset'] = 'donation_upload';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final resData = await http.Response.fromStream(response);

      final data = jsonDecode(resData.body);

      return data['secure_url'];
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
    
  }

  // 📸 Pick Image
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 25,   // 🔥 VERY IMPORTANT
  maxWidth: 800,      // 🔥 reduce size
);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  // 🚀 Submit Donation
  Future<void> _submit() async {
    if (_foodCtrl.text.isEmpty ||
        _qtyCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadToCloudinary(_image!);
    }

    await FirebaseFirestore.instance.collection('donations').add({
      "donorId": user.uid,
      "donorName": userDoc['name'],
      "donorPhone": userDoc['phone'],
      "foodName": _foodCtrl.text,
      "quantity": _qtyCtrl.text,
      "description": _descCtrl.text,
      "expiryTime": Timestamp.now().toDate().add(const Duration(hours: 3)),
      "address": _addressCtrl.text,
      "latitude": 0,
      "longitude": 0,
      "status": "pending",
      "createdAt": Timestamp.now(),
      "imageUrl": imageUrl ?? "",
    });

    setState(() => _loading = false);

    Navigator.pop(context);
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text("Add Donation"),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Food Donation",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 20),

            // 📸 Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Text("Tap to add image 📸"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            _inputField("Food Name", _foodCtrl),
            _inputField("Quantity (e.g. 10 plates)", _qtyCtrl),
            _inputField("Description", _descCtrl),
            _inputField("Pickup Address", _addressCtrl),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Donation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}