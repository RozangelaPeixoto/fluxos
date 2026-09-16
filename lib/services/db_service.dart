import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/client.dart';
import '../models/technician.dart';
import '../models/equipment.dart';
import '../models/work_order.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    String path = join(await getDatabasesPath(), 'fluxos.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id TEXT PRIMARY KEY,
        name TEXT,
        document TEXT,
        phone TEXT,
        email TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE technicians(
        id TEXT PRIMARY KEY,
        name TEXT,
        contact TEXT,
        specialty TEXT,
        isActive INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE equipments(
        id TEXT PRIMARY KEY,
        clientId TEXT,
        type TEXT,
        brand TEXT,
        model TEXT,
        serialNumber TEXT,
        patrimony TEXT,
        observations TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE work_orders(
        id TEXT PRIMARY KEY,
        code TEXT,
        clientId TEXT,
        equipmentId TEXT,
        description TEXT,
        priority TEXT,
        technicianId TEXT,
        openDate TEXT,
        deadline TEXT,
        status TEXT,
        diagnosis TEXT,
        solution TEXT,
        laborCost REAL,
        partsCost REAL,
        totalCost REAL,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE,
        FOREIGN KEY (equipmentId) REFERENCES equipments (id) ON DELETE CASCADE,
        FOREIGN KEY (technicianId) REFERENCES technicians (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE work_order_items(
        id TEXT PRIMARY KEY,
        workOrderId TEXT,
        description TEXT,
        quantity INTEGER,
        unitPrice REAL,
        FOREIGN KEY (workOrderId) REFERENCES work_orders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE work_order_images(
        id TEXT PRIMARY KEY,
        workOrderId TEXT,
        imagePath TEXT,
        FOREIGN KEY (workOrderId) REFERENCES work_orders (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Clients ---
  Future<List<Client>> getClients() async {
    final dbClient = await db;
    final maps = await dbClient.query('clients');
    return maps.map((m) => Client.fromMap(m)).toList();
  }

  Future<void> insertClient(Client client) async {
    final dbClient = await db;
    await dbClient.insert('clients', client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateClient(Client client) async {
    final dbClient = await db;
    await dbClient.update('clients', client.toMap(), where: 'id = ?', whereArgs: [client.id]);
  }

  Future<void> deleteClient(String id) async {
    final dbClient = await db;
    await dbClient.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  // --- Technicians ---
  Future<List<Technician>> getTechnicians() async {
    final dbClient = await db;
    final maps = await dbClient.query('technicians');
    return maps.map((m) => Technician.fromMap(m)).toList();
  }

  Future<void> insertTechnician(Technician technician) async {
    final dbClient = await db;
    await dbClient.insert('technicians', technician.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTechnician(Technician technician) async {
    final dbClient = await db;
    await dbClient.update('technicians', technician.toMap(), where: 'id = ?', whereArgs: [technician.id]);
  }

  Future<void> deleteTechnician(String id) async {
    final dbClient = await db;
    await dbClient.delete('technicians', where: 'id = ?', whereArgs: [id]);
  }

  // --- Equipments ---
  Future<List<Equipment>> getEquipments() async {
    final dbClient = await db;
    final maps = await dbClient.query('equipments');
    return maps.map((m) => Equipment.fromMap(m)).toList();
  }
  
  Future<List<Equipment>> getEquipmentsByClient(String clientId) async {
    final dbClient = await db;
    final maps = await dbClient.query('equipments', where: 'clientId = ?', whereArgs: [clientId]);
    return maps.map((m) => Equipment.fromMap(m)).toList();
  }

  Future<void> insertEquipment(Equipment eq) async {
    final dbClient = await db;
    await dbClient.insert('equipments', eq.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEquipment(Equipment eq) async {
    final dbClient = await db;
    await dbClient.update('equipments', eq.toMap(), where: 'id = ?', whereArgs: [eq.id]);
  }

  Future<void> deleteEquipment(String id) async {
    final dbClient = await db;
    await dbClient.delete('equipments', where: 'id = ?', whereArgs: [id]);
  }

  // --- Work Orders ---
  Future<List<WorkOrder>> getWorkOrders() async {
    final dbClient = await db;
    final maps = await dbClient.query('work_orders', orderBy: 'openDate DESC');
    return maps.map((m) => WorkOrder.fromMap(m)).toList();
  }

  Future<void> insertWorkOrder(WorkOrder os) async {
    final dbClient = await db;
    await dbClient.insert('work_orders', os.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWorkOrder(WorkOrder os) async {
    final dbClient = await db;
    await dbClient.update('work_orders', os.toMap(), where: 'id = ?', whereArgs: [os.id]);
  }

  Future<void> deleteWorkOrder(String id) async {
    final dbClient = await db;
    await dbClient.delete('work_orders', where: 'id = ?', whereArgs: [id]);
  }

  // --- Work Order Items ---
  Future<List<WorkOrderItem>> getWorkOrderItems(String workOrderId) async {
    final dbClient = await db;
    final maps = await dbClient.query('work_order_items', where: 'workOrderId = ?', whereArgs: [workOrderId]);
    return maps.map((m) => WorkOrderItem.fromMap(m)).toList();
  }

  Future<void> insertWorkOrderItem(WorkOrderItem item) async {
    final dbClient = await db;
    await dbClient.insert('work_order_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> deleteWorkOrderItem(String id) async {
    final dbClient = await db;
    await dbClient.delete('work_order_items', where: 'id = ?', whereArgs: [id]);
  }

  // --- Work Order Images ---
  Future<List<WorkOrderImage>> getWorkOrderImages(String workOrderId) async {
    final dbClient = await db;
    final maps = await dbClient.query('work_order_images', where: 'workOrderId = ?', whereArgs: [workOrderId]);
    return maps.map((m) => WorkOrderImage.fromMap(m)).toList();
  }

  Future<void> insertWorkOrderImage(WorkOrderImage img) async {
    final dbClient = await db;
    await dbClient.insert('work_order_images', img.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> deleteWorkOrderImage(String id) async {
    final dbClient = await db;
    await dbClient.delete('work_order_images', where: 'id = ?', whereArgs: [id]);
  }
}
