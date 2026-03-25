class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'donor' or 'ngo'
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

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'donor',
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      ngoRegId: map['ngoRegId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'ngoRegId': ngoRegId,
  };
}
