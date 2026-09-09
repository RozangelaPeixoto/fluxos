import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/equipment.dart';
import 'package:uuid/uuid.dart';

class EquipmentsScreen extends StatelessWidget {
  const EquipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipamentos')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.equipments.isEmpty) {
            return const Center(child: Text('Nenhum equipamento cadastrado.'));
          }
          return ListView.builder(
            itemCount: provider.equipments.length,
            itemBuilder: (context, index) {
              final eq = provider.equipments[index];
              final client = provider.clients.firstWhere((c) => c.id == eq.clientId, orElse: () => throw Exception('Client not found'));
              return ListTile(
                title: Text('${eq.type} - ${eq.brand}'),
                subtitle: Text('Cliente: ${client.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteEquipment(eq.id),
                ),
                onTap: () => _showForm(context, eq),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, Equipment? eq) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EquipmentForm(equipment: eq),
    );
  }
}

class EquipmentForm extends StatefulWidget {
  final Equipment? equipment;
  const EquipmentForm({super.key, this.equipment});

  @override
  State<EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  late String _type;
  late String _brand;
  late String _model;
  late String _serial;
  late String _patrimony;
  late String _observations;

  @override
  void initState() {
    super.initState();
    _clientId = widget.equipment?.clientId;
    _type = widget.equipment?.type ?? '';
    _brand = widget.equipment?.brand ?? '';
    _model = widget.equipment?.model ?? '';
    _serial = widget.equipment?.serialNumber ?? '';
    _patrimony = widget.equipment?.patrimony ?? '';
    _observations = widget.equipment?.observations ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.equipment == null ? 'Novo Equipamento' : 'Editar Equipamento', style: const TextStyle(fontSize: 20)),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: provider.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _clientId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              TextFormField(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                onSaved: (val) => _type = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              ),
              TextFormField(
                initialValue: _brand,
                decoration: const InputDecoration(labelText: 'Marca'),
                onSaved: (val) => _brand = val ?? '',
              ),
              TextFormField(
                initialValue: _model,
                decoration: const InputDecoration(labelText: 'Modelo'),
                onSaved: (val) => _model = val ?? '',
              ),
              TextFormField(
                initialValue: _serial,
                decoration: const InputDecoration(labelText: 'Número de Série'),
                onSaved: (val) => _serial = val ?? '',
              ),
              TextFormField(
                initialValue: _patrimony,
                decoration: const InputDecoration(labelText: 'Patrimônio'),
                onSaved: (val) => _patrimony = val ?? '',
              ),
              TextFormField(
                initialValue: _observations,
                decoration: const InputDecoration(labelText: 'Observações'),
                onSaved: (val) => _observations = val ?? '',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
