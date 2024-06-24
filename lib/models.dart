class TeriyaUser {
  final int id;
  final String email;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeriyaUser(
      {required this.id,
      required this.email,
      required this.fullName,
      required this.createdAt,
      required this.updatedAt});

  factory TeriyaUser.fromJson(Map<String, dynamic> json) {
    return TeriyaUser(
        id: json["id"],
        email: json["email"],
        fullName: json["full_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]));
  }
}
