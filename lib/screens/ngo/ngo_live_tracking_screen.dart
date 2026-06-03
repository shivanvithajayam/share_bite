import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'dart:math';

class NgoLiveTrackingScreen extends StatefulWidget {
  final String donationId;

  const NgoLiveTrackingScreen({
  super.key,
  required this.donationId,
});

@override
State<NgoLiveTrackingScreen>
    createState() =>
        _NgoLiveTrackingScreenState();
}

class _NgoLiveTrackingScreenState
    extends State<NgoLiveTrackingScreen> {

  final otpController =
      TextEditingController();

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295;

    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;

    return 12742 * asin(sqrt(a));
  }

  String calculateETA(double distanceKm) {
    const speed = 30.0;

    final hours = distanceKm / speed;

    final minutes = (hours * 60).round();

    return "$minutes mins";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.cream,

      appBar: AppBar(
        title: const Text(
          "Navigate to Donor",
        ),

        backgroundColor: AppColors.teal,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .doc(widget.donationId)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          final ngoLat = data['ngoLat'];
          final ngoLng = data['ngoLng'];

          if (ngoLat == null ||
              ngoLng == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final donorLat = data['latitude'];
          final donorLng = data['longitude'];

          final ngoLatitude =
              (ngoLat as num).toDouble();

          final ngoLongitude =
              (ngoLng as num).toDouble();

          final donorLatitude =
              (donorLat as num).toDouble();

          final donorLongitude =
              (donorLng as num).toDouble();

          final distanceKm =
              calculateDistance(
            ngoLatitude,
            ngoLongitude,
            donorLatitude,
            donorLongitude,
          );

          final eta =
    calculateETA(distanceKm);

final hasArrived =
    distanceKm <= 0.1;
    final status =
    data['status'] ?? '';

          return Stack(
            children: [

              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    ngoLatitude,
                    ngoLongitude,
                  ),

                  initialZoom: 15,
                ),

                children: [

                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName:
                        'com.example.share_bite',
                  ),

                  /// ROUTE LINE
                  PolylineLayer(
                    polylines: [

                      Polyline(
                        points: [

                          LatLng(
                            ngoLatitude,
                            ngoLongitude,
                          ),

                          LatLng(
                            donorLatitude,
                            donorLongitude,
                          ),
                        ],

                        strokeWidth: 5,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  /// MARKERS
                  MarkerLayer(
                    markers: [

                      /// NGO
                      Marker(
                        point: LatLng(
                          ngoLatitude,
                          ngoLongitude,
                        ),

                        width: 80,
                        height: 80,

                        child: const Column(
                          children: [

                            Icon(
                              Icons.delivery_dining,
                              size: 42,
                              color: Colors.green,
                            ),

                            Text(
                              "You",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// DONOR
                      Marker(
                        point: LatLng(
                          donorLatitude,
                          donorLongitude,
                        ),

                        width: 80,
                        height: 80,

                        child: const Column(
                          children: [

                            Icon(
                              Icons.location_pin,
                              size: 42,
                              color: Colors.red,
                            ),

                            Text(
                              "Donor",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /// BOTTOM CARD
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,

                child: Container(
                  padding:
                      const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(22),

                    boxShadow: [

                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.12),

                        blurRadius: 12,
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

  data['status'] == 'arrived'
      ? "Pickup Verification 🔐"
      : "Navigating to donor 🚚",

  style: const TextStyle(
    fontSize: 18,
    fontWeight:
        FontWeight.bold,
  ),
),

                      const SizedBox(height: 14),

                      Row(
                        children: [

                          const Icon(
                            Icons.access_time,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "ETA: $eta",

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [

                          const Icon(
                            Icons.route,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 8),

                          Text(

  hasArrived
      ? "You have arrived 🎉"
      : "${distanceKm.toStringAsFixed(2)} km away",
),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// SHOW BUTTON ONLY
/// WHEN NGO IS NEAR DONOR
/// ARRIVED BUT OTP NOT VERIFIED
if (status == 'arrived' &&
    !(data['otpVerified'] ?? false))

  Column(
    children: [

      const SizedBox(height: 10),

      const Text(
        "Enter Pickup OTP",

        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 10),

      TextField(
        controller: otpController,

        keyboardType: TextInputType.number,

        decoration: InputDecoration(
          hintText: "Enter OTP",

          filled: true,
          fillColor: AppColors.cream,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),

            borderSide: BorderSide.none,
          ),
        ),
      ),

      const SizedBox(height: 14),

      SizedBox(
        width: double.infinity,

        child: ElevatedButton(

          onPressed: () async {

            if (otpController.text.trim() ==
                data['pickupOtp']) {

await FirebaseFirestore
    .instance
    .collection(
      'donations',
    )
    .doc(widget.donationId)
    .update({

      'otpVerified': true,

      'status': 'completed',

      'donorAcknowledged': false,
    });
    await FirebaseFirestore.instance
    .collection('notifications')
    .add({
  'userId': data['donorId'],
  'title': 'Donation Completed',
  'message': 'Food pickup completed successfully',
  'createdAt': Timestamp.now(),
});

if (!context.mounted) return;

showDialog(
  context: context,

  builder: (_) => AlertDialog(

    title: const Text(
      "Pickup Completed 🎉",
    ),

    content: const Text(
      "Food pickup completed successfully.",
    ),

    actions: [

      TextButton(

        onPressed: () {

          Navigator.pop(context);

          Navigator.pop(context);
        },

        child: const Text("OK"),
      ),
    ],
  ),
);

            } else {

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(

                const SnackBar(
                  content: Text(
                    "Wrong OTP",
                  ),
                ),
              );
            }
          },

          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                Colors.green,
          ),

          child: const Text(
            "Verify OTP",

            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    ],
  )
else if (
    status == 'pickup_started' &&
    hasArrived)

  SizedBox(
    width: double.infinity,

    child: ElevatedButton(

      onPressed: () async {

        final otp =
            (1000 +
                    Random().nextInt(
                      9000,
                    ))
                .toString();

        await FirebaseFirestore
            .instance
            .collection(
              'donations',
            )
            .doc(widget.donationId)
            .update({

              'status': 'arrived',
'pickupStarted': true,

              

              'pickupOtp': otp,

              'otpVerified': false,
            });
            await FirebaseFirestore.instance
    .collection('notifications')
    .add({
  'userId': data['donorId'],
  'title': 'NGO Arrived',
  'message': 'NGO has arrived at your location',
  'createdAt': Timestamp.now(),
});
      },

      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            Colors.green,
      ),

      child: const Text(
        "Reached Donor",

        style: TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}