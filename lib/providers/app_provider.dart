import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/technician.dart';
import '../models/equipment.dart';
import '../models/work_order.dart';
import '../services/db_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AppProvider with ChangeNotifier {
  final DbService _db = DbService();
  final _uuid = const Uuid();

  List<Client> clients = [];
  List<Technician> technicians = [];
  List<Equipment> equipments = [];
  List<WorkOrder> workOrders = [];
  List<WorkOrderItem> workOrderItems = [];
  List<WorkOrderImage> workOrderImages = [];

  bool isLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    clients = await _db.getClients();
    technicians = await _db.getTechnicians();
    equipments = await _db.getEquipments();
    workOrders = await _db.getWorkOrders();

    if (clients.isEmpty && technicians.isEmpty) {
      await _generateMockData();
    }

    isLoading = false;
    notifyListeners();
  }

  // --- Mock Data ---
  Future<void> _generateMockData() async {
    var c1 = Client(id: _uuid.v4(), name: 'Clínica Vida', document: '11.111.111/0001-11', phone: '11999999999', email: 'contato@vida.com', address: 'Rua A, 123');
    var c2 = Client(id: _uuid.v4(), name: 'Mercado Central', document: '22.222.222/0001-22', phone: '11888888888', email: 'contato@mercado.com', address: 'Rua B, 456');
    await _db.insertClient(c1);
    await _db.insertClient(c2);

    var t1 = Technician(id: _uuid.v4(), name: 'Mariana', contact: '11777777777', specialty: 'Refrigeração');
    var t2 = Technician(id: _uuid.v4(), name: 'Carlos', contact: '11666666666', specialty: 'Eletrônica');
    await _db.insertTechnician(t1);
    await _db.insertTechnician(t2);

    var e1 = Equipment(id: _uuid.v4(), clientId: c1.id, type: 'Autoclave', brand: 'Stermax', model: 'A100', serialNumber: 'SN123', patrimony: 'PAT001', observations: '');
    var e2 = Equipment(id: _uuid.v4(), clientId: c2.id, type: 'Câmara Fria', brand: 'FrioBom', model: 'C200', serialNumber: 'SN456', patrimony: 'PAT002', observations: '');
    await _db.insertEquipment(e1);
    await _db.insertEquipment(e2);
    
    var formatter = DateFormat('yyyy-MM-dd HH:mm');
    var now = DateTime.now();

    var os1 = WorkOrder(
      id: _uuid.v4(),
      code: 'OS-0248',
      clientId: c1.id,
      equipmentId: e1.id,
      description: 'Não liga',
      priority: 'Atrasada',
      technicianId: t1.id,
      openDate: formatter.format(now.subtract(const Duration(days: 2))),
      deadline: formatter.format(now.subtract(const Duration(days: 1))),
      status: 'Aberta',
    );

    var os2 = WorkOrder(
      id: _uuid.v4(),
      code: 'OS-0241',
      clientId: c2.id,
      equipmentId: e2.id,
      description: 'Temperatura não baixa',
      priority: 'Urgente',
      technicianId: t1.id,
      openDate: formatter.format(now),
      deadline: formatter.format(now.add(const Duration(hours: 4))),
      status: 'Aberta',
    );

    await _db.insertWorkOrder(os1);
    await _db.insertWorkOrder(os2);

    await loadData();
  }

  // --- Clients ---
  Future<void> saveClient(Client client) async {
    if (clients.any((c) => c.id == client.id)) {
      await _db.updateClient(client);
    } else {
      await _db.insertClient(client);
    }
    await loadData();
  }

  Future<void> deleteClient(String id) async {
    await _db.deleteClient(id);
    await loadData();
  }

  // --- Technicians ---
  Future<void> saveTechnician(Technician tech) async {
    if (technicians.any((t) => t.id == tech.id)) {
      await _db.updateTechnician(tech);
    } else {
      await _db.insertTechnician(tech);
    }
    await loadData();
  }

  Future<void> deleteTechnician(String id) async {
    await _db.deleteTechnician(id);
    await loadData();
  }

  // --- Equipments ---
  Future<void> saveEquipment(Equipment eq) async {
    if (equipments.any((e) => e.id == eq.id)) {
      await _db.updateEquipment(eq);
    } else {
      await _db.insertEquipment(eq);
    }
    await loadData();
  }

  Future<void> deleteEquipment(String id) async {
    await _db.deleteEquipment(id);
    await loadData();
  }

  // --- Work Orders ---
  Future<void> saveWorkOrder(WorkOrder os) async {
    if (workOrders.any((o) => o.id == os.id)) {
      await _db.updateWorkOrder(os);
    } else {
      await _db.insertWorkOrder(os);
    }
    await loadData();
  }

  Future<void> deleteWorkOrder(String id) async {
    await _db.deleteWorkOrder(id);
    await loadData();
  }

  // Work Order details
  Future<void> loadWorkOrderDetails(String osId) async {
    workOrderItems = await _db.getWorkOrderItems(osId);
    workOrderImages = await _db.getWorkOrderImages(osId);
    notifyListeners();
  }

  Future<void> saveWorkOrderItem(WorkOrderItem item) async {
    await _db.insertWorkOrderItem(item);
    await _recalculateTotal(item.workOrderId);
    await loadWorkOrderDetails(item.workOrderId);
  }

  Future<void> deleteWorkOrderItem(String itemId, String osId) async {
    await _db.deleteWorkOrderItem(itemId);
    await _recalculateTotal(osId);
    await loadWorkOrderDetails(osId);
  }

  Future<void> saveWorkOrderImage(WorkOrderImage img) async {
    await _db.insertWorkOrderImage(img);
    await loadWorkOrderDetails(img.workOrderId);
  }

  Future<void> deleteWorkOrderImage(String id, String osId) async {
    await _db.deleteWorkOrderImage(id);
    await loadWorkOrderDetails(osId);
  }

  Future<void> _recalculateTotal(String osId) async {
    var items = await _db.getWorkOrderItems(osId);
    double partsTotal = 0;
    for (var item in items) {
      partsTotal += item.quantity * item.unitPrice;
    }
    var osIndex = workOrders.indexWhere((o) => o.id == osId);
    if (osIndex != -1) {
      var os = workOrders[osIndex];
      os.partsCost = partsTotal;
      os.totalCost = os.laborCost + os.partsCost;
      await _db.updateWorkOrder(os);
      await loadData();
    }
  }

  Future<void> updateLaborCost(String osId, double laborCost) async {
    var osIndex = workOrders.indexWhere((o) => o.id == osId);
    if (osIndex != -1) {
      var os = workOrders[osIndex];
      os.laborCost = laborCost;
      os.totalCost = os.laborCost + os.partsCost;
      await _db.updateWorkOrder(os);
      await loadData();
    }
  }
}

// calculo financeiro e validacoes de status adicionados
