import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  double? _latitude;
  double? _longitude;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _addressDetailsCtrl = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    _getCurrentLocation();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    if (data != null) {
      _nameCtrl.text = data['name'] ?? "";
      _phoneCtrl.text = data['phone'] ?? "";
      _addressCtrl.text = data['address'] ?? "";
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable location services")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _latitude = position.latitude;
    _longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _latitude!,
      _longitude!,
    );

    Placemark place = placemarks.first;

    String address =
        "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

    setState(() {
      _addressCtrl.text = address;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Current location added")));
  }

  Future<void> saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name, Phone and Address cannot be empty"),
        ),
      );
      return;
    }
    if (_phoneCtrl.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 10 digit phone number")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      "name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "address":
          "${_addressDetailsCtrl.text.trim()}, ${_addressCtrl.text.trim()}",
      "latitude": _latitude,
      "longitude": _longitude,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Address"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _addressDetailsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Apartment / Landmark / Extra Details",
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Use Current Location"),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
