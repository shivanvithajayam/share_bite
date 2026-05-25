import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/app_theme.dart';
import 'edit_ngo_profile_sheet.dart';

class NgoProfileSheet extends StatelessWidget {
  const NgoProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(20),

          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.teal,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                data['name'] ?? "",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                data['email'] ?? "",
                style: const TextStyle(
                  color: AppColors.mutedText,
                ),
              ),

              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(data['phone'] ?? ""),
              ),

              ListTile(
                leading: const Icon(Icons.badge),
                title: Text(
                  data['ngoRegId'] ?? "No NGO Registration ID",
                ),
              ),

              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                  data['address'] == null ||
                          data['address'].toString().isEmpty
                      ? "No address added"
                      : data['address'],
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),

                onTap: () {
                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,

                    builder: (context) {
                      return const EditNgoProfileSheet();
                    },
                  );
                },
              ),
              ListTile(
  leading: const Icon(
    Icons.logout,
    color: Colors.red,
  ),

  title: const Text(
    "Logout",
    style: TextStyle(color: Colors.red),
  ),

  onTap: () async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  },
),
            
            ],
          ),
        );
      },
    );
  }
}