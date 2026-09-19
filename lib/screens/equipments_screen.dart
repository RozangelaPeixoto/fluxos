import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/equipment.dart';

import 'package:uuid/uuid.dart';

import 'equipment_detail_screen.dart';

class EquipmentsScreen extends StatefulWidget {
  const EquipmentsScreen({super.key});

  @override
  State<EquipmentsScreen> createState() => _EquipmentsScreenState();
}

class _EquipmentsScreenState extends State<EquipmentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Equipamentos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            Consumer<AppProvider>(
              builder: (context, provider, _) => Text(
                '${provider.equipments.length} equipamentos cadastrados',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.equipments.where((e) {
            return e.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.model.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por tipo, marca ou modelo',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar equipamento'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EquipmentFormScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final eq = filtered[index];
                      final client = provider.clients.firstWhere(
                        (c) => c.id == eq.clientId,
                        orElse: () => throw Exception('Client not found'),
                      );
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EquipmentDetailScreen(equipment: eq),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                child: const Icon(
                                  Icons.precision_manufacturing,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${eq.type} ${eq.brand}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Cliente: ${client.name}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EquipmentFormScreen extends StatefulWidget {
  final Equipment? equipment;
  const EquipmentFormScreen({super.key, this.equipment});

  @override
  State<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends State<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  late String _type, _brand, _model, _serial, _patrimony, _observations;

  @override
  void initState() {
    super.initState();
    _clientId = widget.equipment?.clientId;
    _type = widget.equipment?.type ?? '';
    _brand = widget.equipment?.brand ?? '';
    _model = widget.equipment?.model ?? '';
    _serial = widget.equipment?.serialNumber ?? '';

    if (widget.equipment != null) {
      _patrimony = widget.equipment!.patrimony;
    } else {
      _patrimony = 'PAT-${Random().nextInt(99999).toString().padLeft(5, '0')}';
    }

    _observations = widget.equipment?.observations ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.equipment == null
                  ? 'Cadastrar equipamento'
                  : 'Editar equipamento',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 22,
              ),
            ),
            const Text(
              'Dados do equipamento',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vinculação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Cliente', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: provider.clients
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _clientId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Identificação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildField(
                'Tipo (Ex: Ar-condicionado)',
                _type,
                (val) => _type = val,
                true,
              ),
              _buildField('Marca', _brand, (val) => _brand = val, false),
              _buildField('Modelo', _model, (val) => _model = val, false),
              _buildField(
                'Número de Série',
                _serial,
                (val) => _serial = val,
                false,
              ),
              _buildField(
                'Patrimônio',
                _patrimony,
                (val) => _patrimony = val,
                false,
                readOnly: true,
              ),
              _buildField(
                'Observações',
                _observations,
                (val) => _observations = val,
                false,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newEq = Equipment(
                    id: widget.equipment?.id ?? const Uuid().v4(),
                    clientId: _clientId!,
                    type: _type,
                    brand: _brand,
                    model: _model,
                    serialNumber: _serial,
                    patrimony: _patrimony,
                    observations: _observations,
                  );
                  provider.saveEquipment(newEq);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Salvar equipamento',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String initialValue,
    Function(String) onSaved,
    bool isRequired, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            readOnly: readOnly,
            style: TextStyle(color: readOnly ? Colors.black54 : Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onSaved: (val) => onSaved(val ?? ''),
            validator: (val) => (isRequired && (val == null || val.isEmpty))
                ? 'Obrigatório'
                : null,
          ),
        ],
      ),
    );
  }
}
