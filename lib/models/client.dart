class Client {
  String id;
  String name;
  String document;
  String phone;
  String email;
  String address;
  String createdAt;

  Client({
    required this.id,
    required this.name,
    required this.document,
    required this.phone,
    required this.email,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'document': document,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': createdAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      document: map['document'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}
