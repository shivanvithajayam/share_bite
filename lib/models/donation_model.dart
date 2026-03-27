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
  final String status;
  final String? acceptedByNgoId;
  final String? acceptedByNgoName;
  final String? acceptedByNgoPhone;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? imageUrl;

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
    this.imageUrl,
    required this.status,
    this.acceptedByNgoId,
    this.acceptedByNgoName,
    this.acceptedByNgoPhone,
    required this.createdAt,
    this.acceptedAt,
  });
}
