class Equipment {
  String id;
  String clientId;
  String type;
  String brand;
  String model;
  String serialNumber;
  String patrimony;
  String observations;

  Equipment({
    required this.id,
    required this.clientId,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.patrimony,
    required this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'type': type,
      'brand': brand,
      'model': model,
      'serialNumber': serialNumber,
      'patrimony': patrimony,
      'observations': observations,
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['id'],
      clientId: map['clientId'],
      type: map['type'],
      brand: map['brand'],
      model: map['model'],
      serialNumber: map['serialNumber'],
      patrimony: map['patrimony'],
      observations: map['observations'],
    );
  }
}
