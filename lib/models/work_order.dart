import 'dart:convert';

class WorkOrder {
  String id;
  String code;
  String clientId;
  String equipmentId;
  String description;
  String priority;
  String? technicianId;
  String openDate;
  String? deadline;
  String status;
  String? diagnosis;
  String? solution;
  double laborCost;
  double partsCost;
  double totalCost;

  WorkOrder({
    required this.id,
    required this.code,
    required this.clientId,
    required this.equipmentId,
    required this.description,
    required this.priority,
    this.technicianId,
    required this.openDate,
    this.deadline,
    required this.status,
    this.diagnosis,
    this.solution,
    this.laborCost = 0.0,
    this.partsCost = 0.0,
    this.totalCost = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'clientId': clientId,
      'equipmentId': equipmentId,
      'description': description,
      'priority': priority,
      'technicianId': technicianId,
      'openDate': openDate,
      'deadline': deadline,
      'status': status,
      'diagnosis': diagnosis,
      'solution': solution,
      'laborCost': laborCost,
      'partsCost': partsCost,
      'totalCost': totalCost,
    };
  }

  factory WorkOrder.fromMap(Map<String, dynamic> map) {
    return WorkOrder(
      id: map['id'],
      code: map['code'],
      clientId: map['clientId'],
      equipmentId: map['equipmentId'],
      description: map['description'],
      priority: map['priority'],
      technicianId: map['technicianId'],
      openDate: map['openDate'],
      deadline: map['deadline'],
      status: map['status'],
      diagnosis: map['diagnosis'],
      solution: map['solution'],
      laborCost: map['laborCost'],
      partsCost: map['partsCost'],
      totalCost: map['totalCost'],
    );
  }
}

class WorkOrderItem {
  String id;
  String workOrderId;
  String description;
  int quantity;
  double unitPrice;

  WorkOrderItem({
    required this.id,
    required this.workOrderId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory WorkOrderItem.fromMap(Map<String, dynamic> map) {
    return WorkOrderItem(
      id: map['id'],
      workOrderId: map['workOrderId'],
      description: map['description'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
    );
  }
}

class WorkOrderImage {
  String id;
  String workOrderId;
  String imagePath;

  WorkOrderImage({
    required this.id,
    required this.workOrderId,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workOrderId': workOrderId,
      'imagePath': imagePath,
    };
  }

  factory WorkOrderImage.fromMap(Map<String, dynamic> map) {
    return WorkOrderImage(
      id: map['id'],
      workOrderId: map['workOrderId'],
      imagePath: map['imagePath'],
    );
  }
}
