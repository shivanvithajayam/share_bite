import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/donation_model.dart';

class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── Upload photo ───────────────────────────────────────────────────────────
  Future<String?> uploadPhoto(File photo, String donationId) async {
    final ref = _storage.ref().child('donations/$donationId.jpg');
    await ref.putFile(photo);
    return await ref.getDownloadURL();
  }

  // ─── Post donation ──────────────────────────────────────────────────────────
  Future<String> postDonation(DonationModel donation) async {
    final ref = await _db.collection('donations').add(donation.toMap());
    return ref.id;
  }

  // ─── Donor: stream of own donations ─────────────────────────────────────────
  Stream<List<DonationModel>> donorDonations(String donorId) {
    return _db
        .collection('donations')
        .where('donorId', isEqualTo: donorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DonationModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ─── Donor: current pending donation ─────────────────────────────────────────
  Stream<List<DonationModel>> donorActiveDonations(String donorId) {
    return _db
        .collection('donations')
        .where('donorId', isEqualTo: donorId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DonationModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ─── NGO: all pending donations ──────────────────────────────────────────────
  Stream<List<DonationModel>> allPendingDonations() {
    return _db
        .collection('donations')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DonationModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ─── NGO: get nearby donations within 10 km ──────────────────────────────────
  Future<List<DonationModel>> getNearbyDonations(
    double ngoLat,
    double ngoLng,
  ) async {
    final snapshot = await _db
        .collection('donations')
        .where('status', isEqualTo: 'pending')
        .get();

    final all = snapshot.docs
        .map((d) => DonationModel.fromMap(d.data(), d.id))
        .toList();

    return all.where((d) {
      final dist = _distanceKm(ngoLat, ngoLng, d.latitude, d.longitude);
      return dist <= 10.0;
    }).toList()..sort((a, b) {
      final da = _distanceKm(ngoLat, ngoLng, a.latitude, a.longitude);
      final db2 = _distanceKm(ngoLat, ngoLng, b.latitude, b.longitude);
      return da.compareTo(db2);
    });
  }

  // ─── Accept donation ─────────────────────────────────────────────────────────
  Future<void> acceptDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    required String ngoPhone,
  }) async {
    await _db.collection('donations').doc(donationId).update({
      'status': 'accepted',
      'acceptedByNgoId': ngoId,
      'acceptedByNgoName': ngoName,
      'acceptedByNgoPhone': ngoPhone,
      'acceptedAt': Timestamp.now(),
    });
  }

  // ─── Reject donation ─────────────────────────────────────────────────────────
  Future<void> rejectDonation(String donationId) async {
    await _db.collection('donations').doc(donationId).update({
      'status': 'rejected',
    });
  }

  // ─── NGO history ─────────────────────────────────────────────────────────────
  Stream<List<DonationModel>> ngoHistory(String ngoId) {
    return _db
        .collection('donations')
        .where('acceptedByNgoId', isEqualTo: ngoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DonationModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  // ─── Single donation stream ───────────────────────────────────────────────────
  Stream<DonationModel?> donationStream(String donationId) {
    return _db.collection('donations').doc(donationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DonationModel.fromMap(doc.data()!, doc.id);
    });
  }

  // ─── Haversine distance ───────────────────────────────────────────────────────
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;
}
