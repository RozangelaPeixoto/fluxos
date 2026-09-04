class Technician {
  String id;
  String name;
  String contact;
  String specialty;
  int isActive; 

  Technician({
    required this.id,
    required this.name,
    required this.contact,
    required this.specialty,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'specialty': specialty,
      'isActive': isActive,
    };
  }

  factory Technician.fromMap(Map<String, dynamic> map) {
    return Technician(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      specialty: map['specialty'],
      isActive: map['isActive'],
    );
  }
}
