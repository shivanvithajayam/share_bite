import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String donationId;

  const LiveTrackingScreen({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("NGO Live Tracking")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .doc(donationId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final lat = data['ngoLiveLat'];
          final lng = data['ngoLiveLng'];

          if (lat == null || lng == null) {
            return const Center(child: Text("NGO has not started pickup"));
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 15,
            ),

            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.share_bite',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),

                    width: 80,
                    height: 80,

                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
