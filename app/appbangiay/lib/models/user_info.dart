class UserInfoModel {
  String name;
  String email;
  String phone;
  String address;

  UserInfoModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
  };

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
  );
}
