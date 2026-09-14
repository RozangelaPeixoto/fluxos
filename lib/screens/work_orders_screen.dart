import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'package:uuid/uuid.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  String _searchQuery = '';
  String? _statusFilter;
  String? _priorityFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.workOrders.where((os) {
            bool matchesSearch = _searchQuery.isEmpty || 
                os.code.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                (provider.clients.any((c) => c.id == os.clientId && c.name.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.equipments.any((e) => e.id == os.equipmentId && e.type.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.technicians.any((t) => t.id == os.technicianId && t.name.toLowerCase().contains(_searchQuery.toLowerCase())));
            bool matchesStatus = _statusFilter == null || os.status == _statusFilter;
            bool matchesPriority = _priorityFilter == null || os.priority == _priorityFilter;
            return matchesSearch && matchesStatus && matchesPriority;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(hintText: 'Buscar OS, cliente, equipamento...'),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final os = filtered[index];
                    final client = provider.clients.firstWhere((c) => c.id == os.clientId, orElse: () => throw Exception());
                    final eq = provider.equipments.firstWhere((e) => e.id == os.equipmentId, orElse: () => throw Exception());
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text('${os.code} - ${client.name}'),
                        subtitle: Text('${eq.type} | Status: ${os.status} | Prioridade: ${os.priority}'),
                        trailing: Text('R\$ ${os.totalCost.toStringAsFixed(2)}'),
                        onTap: () => _showForm(context, os),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtros'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                value: _statusFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (val) => setState(() => _statusFilter = val),
              ),
              DropdownButtonFormField<String?>(
                value: _priorityFilter,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...['Baixa', 'Média', 'Alta', 'Urgente']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                ],
                onChanged: (val) => setState(() => _priorityFilter = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        );
      },
    );
  }

  void _showForm(BuildContext context, WorkOrder? os) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WorkOrderForm(os: os),
    );
  }
}

class WorkOrderForm extends StatefulWidget {
  final WorkOrder? os;
  const WorkOrderForm({super.key, this.os});

  @override
  State<WorkOrderForm> createState() => _WorkOrderFormState();
}

class _WorkOrderFormState extends State<WorkOrderForm> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  String? _equipmentId;
  late String _description;
  String _priority = 'Média';
  String? _technicianId;
  String _status = 'Aberta';
  late String _diagnosis;
  late String _solution;

  @override
  void initState() {
    super.initState();
    _clientId = widget.os?.clientId;
    _equipmentId = widget.os?.equipmentId;
    _description = widget.os?.description ?? '';
    _priority = widget.os?.priority ?? 'Média';
    _technicianId = widget.os?.technicianId;
    _status = widget.os?.status ?? 'Aberta';
    _diagnosis = widget.os?.diagnosis ?? '';
    _solution = widget.os?.solution ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    var equipmentsForClient = _clientId == null ? [] : provider.equipments.where((e) => e.clientId == _clientId).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.os == null ? 'Nova OS' : 'Editar OS', style: const TextStyle(fontSize: 20)),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: provider.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) {
                  setState(() {
                    _clientId = val;
                    _equipmentId = null;
                  });
                },
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _equipmentId,
                decoration: const InputDecoration(labelText: 'Equipamento'),
                items: equipmentsForClient.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.type} - ${e.brand}'))).toList(),
                onChanged: (val) => setState(() => _equipmentId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _technicianId,
                decoration: const InputDecoration(labelText: 'Técnico'),
                items: provider.technicians.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _technicianId = val),
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descrição do Problema'),
                onSaved: (val) => _description = val ?? '',
                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: ['Baixa', 'Média', 'Alta', 'Urgente'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              TextFormField(
                initialValue: _diagnosis,
                decoration: const InputDecoration(labelText: 'Diagnóstico'),
                onSaved: (val) => _diagnosis = val ?? '',
              ),
              TextFormField(
                initialValue: _solution,
                decoration: const InputDecoration(labelText: 'Solução'),
                onSaved: (val) => _solution = val ?? '',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    if (_status == 'Concluída' && _diagnosis.isEmpty && _solution.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Para concluir, informe diagnóstico ou solução')));
                      return;
                    }

                    final newOs = WorkOrder(
                      id: widget.os?.id ?? const Uuid().v4(),
                      code: widget.os?.code ?? 'OS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      clientId: _clientId!,
                      equipmentId: _equipmentId!,
                      description: _description,
                      priority: _priority,
                      technicianId: _technicianId,
                      openDate: widget.os?.openDate ?? DateTime.now().toIso8601String(),
                      deadline: widget.os?.deadline,
                      status: _status,
                      diagnosis: _diagnosis,
                      solution: _solution,
                      laborCost: widget.os?.laborCost ?? 0.0,
                      partsCost: widget.os?.partsCost ?? 0.0,
                      totalCost: widget.os?.totalCost ?? 0.0,
                    );
                    provider.saveWorkOrder(newOs);
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

// implementacao de filtros finalizada

// implementacao de filtros finalizada
