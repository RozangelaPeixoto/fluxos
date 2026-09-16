class Technician {
  String id;
  String name;
  String contact;
  String specialty;
  String matricula;
  String senha;
  int isActive; 

  Technician({
    required this.id,
    required this.name,
    required this.contact,
    required this.specialty,
    required this.matricula,
    required this.senha,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'specialty': specialty,
      'matricula': matricula,
      'senha': senha,
      'isActive': isActive,
    };
  }

  factory Technician.fromMap(Map<String, dynamic> map) {
    return Technician(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      specialty: map['specialty'],
      matricula: map['matricula'] ?? '',
      senha: map['senha'] ?? '',
      isActive: map['isActive'],
    );
  }
}
