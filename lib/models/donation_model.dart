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
  final String? photoUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? acceptedByNgoId;
  final String? acceptedByNgoName;
  final String? acceptedByNgoPhone;
  final DateTime createdAt;
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
    this.photoUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.acceptedByNgoId,
    this.acceptedByNgoName,
    this.acceptedByNgoPhone,
    required this.createdAt,
    this.acceptedAt,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      id: id,
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? '',
      donorPhone: map['donorPhone'] ?? '',
      foodName: map['foodName'] ?? '',
      quantity: map['quantity'] ?? '',
      description: map['description'] ?? '',
      expiryTime: (map['expiryTime'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      acceptedByNgoId: map['acceptedByNgoId'],
      acceptedByNgoName: map['acceptedByNgoName'],
      acceptedByNgoPhone: map['acceptedByNgoPhone'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      acceptedAt: map['acceptedAt'] != null
          ? (map['acceptedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'donorId': donorId,
    'donorName': donorName,
    'donorPhone': donorPhone,
    'foodName': foodName,
    'quantity': quantity,
    'description': description,
    'expiryTime': Timestamp.fromDate(expiryTime),
    'photoUrl': photoUrl,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'acceptedByNgoId': acceptedByNgoId,
    'acceptedByNgoName': acceptedByNgoName,
    'acceptedByNgoPhone': acceptedByNgoPhone,
    'createdAt': Timestamp.fromDate(createdAt),
    'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
  };

  DonationModel copyWith({
    String? status,
    String? acceptedByNgoId,
    String? acceptedByNgoName,
    String? acceptedByNgoPhone,
    DateTime? acceptedAt,
  }) {
    return DonationModel(
      id: id,
      donorId: donorId,
      donorName: donorName,
      donorPhone: donorPhone,
      foodName: foodName,
      quantity: quantity,
      description: description,
      expiryTime: expiryTime,
      photoUrl: photoUrl,
      address: address,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      acceptedByNgoId: acceptedByNgoId ?? this.acceptedByNgoId,
      acceptedByNgoName: acceptedByNgoName ?? this.acceptedByNgoName,
      acceptedByNgoPhone: acceptedByNgoPhone ?? this.acceptedByNgoPhone,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}
