import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'package:uuid/uuid.dart';
import 'work_order_detail_screen.dart';

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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold)),
            Consumer<AppProvider>(
              builder: (context, provider, _) => Text(
                '${provider.workOrders.length} ordens cadastradas',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar OS, cliente...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.black54),
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar OS'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkOrderFormScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final os = filtered[index];
                      final client = provider.clients.firstWhere((c) => c.id == os.clientId, orElse: () => throw Exception());
                      final eq = provider.equipments.firstWhere((e) => e.id == os.equipmentId, orElse: () => throw Exception());
                      
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkOrderDetailScreen(workOrder: os))),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(os.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  _buildStatusPill(os.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${client.name} • ${eq.type}', style: const TextStyle(color: Colors.black87, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(os.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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

  Widget _buildStatusPill(String status) {
    Color color;
    switch (status) {
      case 'Aberta': color = Colors.blue; break;
      case 'Em atendimento': color = Colors.blueAccent; break;
      case 'Aguardando peça': color = Colors.orange; break;
      case 'Concluída': color = Colors.green; break;
      case 'Cancelada': color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
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
}

class WorkOrderFormScreen extends StatefulWidget {
  final WorkOrder? os;
  const WorkOrderFormScreen({super.key, this.os});

  @override
  State<WorkOrderFormScreen> createState() => _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends State<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  String? _equipmentId;
  late String _description;
  String _priority = 'Média';
  String? _technicianId;
  String _status = 'Aberta';
  late String _diagnosis;
  late String _solution;
  late String _deadline;

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
    _deadline = widget.os?.deadline ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    var equipmentsForClient = _clientId == null ? [] : provider.equipments.where((e) => e.clientId == _clientId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.os == null ? 'Cadastrar OS' : 'Editar OS', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Dados do atendimento', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
              const Text('Vinculação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              const Text('Cliente', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: _fieldDeco(),
                items: provider.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) {
                  setState(() {
                    _clientId = val;
                    _equipmentId = null;
                  });
                },
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Text('Equipamento', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _equipmentId,
                decoration: _fieldDeco(),
                items: equipmentsForClient.map((e) => DropdownMenuItem(value: e.id, child: Text('${e.type} - ${e.brand}'))).toList(),
                onChanged: (val) => setState(() => _equipmentId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),

              const SizedBox(height: 24),
              const Text('Problema e Prioridade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Descrição do Problema', _description, (val) => _description = val, true),
              
              const Text('Prioridade', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: _fieldDeco(),
                items: ['Baixa', 'Média', 'Alta', 'Urgente'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              const SizedBox(height: 16),
              _buildField('Prazo (YYYY-MM-DD)', _deadline, (val) => _deadline = val, false),

              const SizedBox(height: 24),
              const Text('Atendimento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Técnico Responsável', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _technicianId,
                decoration: _fieldDeco(),
                items: provider.technicians.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _technicianId = val),
              ),
              const SizedBox(height: 16),
              const Text('Status', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _fieldDeco(),
                items: ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              _buildField('Diagnóstico', _diagnosis, (val) => _diagnosis = val, false),
              _buildField('Solução', _solution, (val) => _solution = val, false),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
                    deadline: _deadline.isEmpty ? null : _deadline,
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
              child: const Text('Salvar OS', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildField(String label, String initialValue, Function(String) onSaved, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            decoration: _fieldDeco(),
            onSaved: (val) => onSaved(val ?? ''),
            validator: (val) => (isRequired && (val == null || val.isEmpty)) ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }
}
