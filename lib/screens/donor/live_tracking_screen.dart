import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class LiveTrackingScreen extends StatelessWidget {
  final String donationId;

  const LiveTrackingScreen({
    super.key,
    required this.donationId,
  });

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

    appBar: AppBar(
      title: const Text(
        "Track NGO",
      ),
    ),

    body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donations')
          .doc(donationId)
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>;
            if (data['status'] == 'completed' &&
    !(data['donorAcknowledged'] ?? false)) {

  return Scaffold(

   

    body: Center(

      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 90,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "Pickup Completed 🎉",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              "Your food has been successfully collected.",

              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 30,
            ),

            ElevatedButton(

              onPressed: () async {

                await FirebaseFirestore
                    .instance
                    .collection(
                      'donations',
                    )
                    .doc(donationId)
                    .update({

                      'donorAcknowledged':
                          true,
                    });

                if (context.mounted) {
                  Navigator.pop(
                    context,
                  );
                }
              },

              child: const Text(
                "OK",
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

        final ngoLat = data['ngoLat'];
        final ngoLng = data['ngoLng'];

        if (ngoLat == null || ngoLng == null) {
          return const SizedBox.shrink();
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

        final distanceKm = calculateDistance(
          ngoLatitude,
          ngoLongitude,
          donorLatitude,
          donorLongitude,
        );

        final eta = calculateETA(distanceKm);

        return Stack(
          children: [

            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
  (ngoLatitude + donorLatitude) / 2 - 0.002,
  (ngoLongitude + donorLongitude) / 2,
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

  width: 60,
  height: 60,

  child: Column(
    mainAxisSize: MainAxisSize.min,

    children: const [

      Icon(
        Icons.delivery_dining,
        size: 28,
        color: Colors.green,
      ),

      SizedBox(height: 2),

      Flexible(
        child: Text(
          "NGO",

          overflow:
              TextOverflow.ellipsis,

          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 11,
          ),
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

  child: Column(
    mainAxisSize: MainAxisSize.min,

    children: const [

      Icon(
        Icons.location_pin,
        size: 26,
        color: Colors.red,
      ),

      SizedBox(height: 2),

      Text(
        "Donor",

        overflow:
            TextOverflow.ellipsis,

        maxLines: 1,

        style: TextStyle(
          fontWeight:
              FontWeight.bold,
          fontSize: 10,
        ),
      ),
    ],
  ),
),
                  ],
                ),
              ],
            ),

            /// BOTTOM INFO CARD
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.12),

                      blurRadius: 12,
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

  data['status'] == 'arrived'
      ? "Your Pickup OTP 🔐"
      : "NGO Partner is on the way 🚚",

  style: const TextStyle(
    fontSize: 16,
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
      size: 20,
    ),

    const SizedBox(width: 8),

    Expanded(
      child: Text(
        "ETA: $eta",

        overflow:
            TextOverflow.ellipsis,

        style: const TextStyle(
          fontWeight:
              FontWeight.w600,
          fontSize: 14,
        ),
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
      size: 20,
    ),

    const SizedBox(width: 8),

    Expanded(
      child: Text(
        "${distanceKm.toStringAsFixed(2)} km away",

        overflow:
            TextOverflow.ellipsis,

        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ),
  ],
),

const SizedBox(height: 14),

if (data['status'] == 'arrived' &&
    data['pickupOtp'] != null)

  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius:
          BorderRadius.circular(12),
    ),

    child: Column(
      children: [

        const Text(
          "📍 NGO Arrived for Pickup",

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Your Pickup OTP",

          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          data['pickupOtp'],

          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  )

else

  const LinearProgressIndicator(
    minHeight: 7,
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