class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? ngoRegId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.latitude,
    this.longitude,
    this.ngoRegId,
  });
}
