import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String donorPhone;
  final String foodName;
  final String quantity;
  final String description;
  final DateTime expiryTime;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;
  final String? acceptedByNgoId;
  final String? acceptedByNgoName;
  final String? acceptedByNgoPhone;
  final DateTime? acceptedAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.foodName,
    required this.quantity,
    required this.description,
    required this.expiryTime,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.imageUrl,
    this.acceptedByNgoId,
    this.acceptedByNgoName,
    this.acceptedByNgoPhone,
    this.acceptedAt,
  });

  // 🔹 Convert Firestore → Model
  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DonationModel(
      id: doc.id,
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      donorPhone: data['donorPhone'] ?? '',
      foodName: data['foodName'] ?? '',
      quantity: data['quantity'] ?? '',
      description: data['description'] ?? '',
      expiryTime: (data['expiryTime'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      acceptedByNgoId: data['acceptedByNgoId'],
      acceptedByNgoName: data['acceptedByNgoName'],
      acceptedByNgoPhone: data['acceptedByNgoPhone'],
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // 🔹 Convert Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'foodName': foodName,
      'quantity': quantity,
      'description': description,
      'expiryTime': Timestamp.fromDate(expiryTime),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'acceptedByNgoId': acceptedByNgoId,
      'acceptedByNgoName': acceptedByNgoName,
      'acceptedByNgoPhone': acceptedByNgoPhone,
      'acceptedAt': acceptedAt != null
          ? Timestamp.fromDate(acceptedAt!)
          : null,
    };
  }
}