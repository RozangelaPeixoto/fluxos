import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'package:uuid/uuid.dart';
import 'work_order_detail_screen.dart';
import '../models/equipment.dart';
import '../widgets/status_pill.dart';
import 'package:intl/intl.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
            Consumer<AppProvider>(
              builder: (context, provider, _) {
                final activeCount = provider.workOrders.where((os) => os.status != 'Concluída' && os.status != 'Cancelada').length;
                return Text(
                  '$activeCount ordens ativas',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              radius: 20,
              child: const Text('MP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.workOrders.where((os) {
            bool matchesSearch = _searchQuery.isEmpty || 
                os.code.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                (provider.clients.any((c) => c.id == os.clientId && c.name.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.equipments.any((e) => e.id == os.equipmentId && e.type.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.technicians.any((t) => t.id == os.technicianId && t.name.toLowerCase().contains(_searchQuery.toLowerCase())));
                
            bool matchesStatus = _selectedStatus == null || os.status == _selectedStatus;
            bool matchesPriority = _selectedPriority == null || os.priority == _selectedPriority;
            
            return matchesSearch && matchesStatus && matchesPriority;
          }).toList();

          filtered.sort((a, b) {
            const priorities = {'Urgente': 0, 'Alta': 1, 'Média': 2, 'Baixa': 3};
            int pA = priorities[a.priority] ?? 4;
            int pB = priorities[b.priority] ?? 4;
            return pA.compareTo(pB);
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nº, cliente, equipamento ou técnico',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdownFilter('Status', ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada'], _selectedStatus, (val) => setState(() => _selectedStatus = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdownFilter('Prioridade', ['Baixa', 'Média', 'Alta', 'Urgente'], _selectedPriority, (val) => setState(() => _selectedPriority = val))),
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
                    label: const Text('Nova ordem de serviço', style: TextStyle(fontSize: 16)),
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
                      final techName = os.technicianId != null ? provider.technicians.firstWhere((t) => t.id == os.technicianId).name : 'Não atribuído';
                      
                      String deadlineStr = 'Sem prazo';
                      if (os.deadline != null && os.deadline!.isNotEmpty) {
                        try {
                          final dl = DateTime.parse(os.deadline!);
                          deadlineStr = DateFormat("dd/MM/yy 'às' HH:mm").format(dl);
                        } catch (_) {
                          deadlineStr = os.deadline!;
                        }
                      }

                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkOrderDetailScreen(workOrder: os))),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(os.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Row(
                                    children: [
                                      StatusPill(status: os.priority, isPriority: true),
                                      const SizedBox(width: 8),
                                      StatusPill(status: os.status),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(client.name, style: const TextStyle(color: Colors.black87, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(eq.type, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Técnico: $techName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text('Prazo: $deadlineStr', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
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

  Widget _buildDropdownFilter(String hint, List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: [
            DropdownMenuItem<String>(value: null, child: Text('$hint: Todos', style: const TextStyle(fontSize: 14))),
            ...items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))),
          ],
          onChanged: onChanged,
        ),
      ),
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
    if (!['Baixa', 'Média', 'Alta', 'Urgente'].contains(_priority)) {
      _priority = 'Média';
    }
    _technicianId = widget.os?.technicianId;
    _status = widget.os?.status ?? 'Aberta';
    if (!['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada'].contains(_status)) {
      _status = 'Aberta';
    }
    _diagnosis = widget.os?.diagnosis ?? '';
    _solution = widget.os?.solution ?? '';
    _deadline = widget.os?.deadline ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    List<Equipment> equipmentsForClient = _clientId == null ? [] : provider.equipments.where((e) => e.clientId == _clientId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.os == null ? 'Nova ordem de serviço' : 'Editar OS', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
            const Text('Preencha os dados abaixo', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
              const Text('Cliente', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: _fieldDeco(),
                items: provider.clients.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))).toList(),
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
                items: equipmentsForClient.map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(value: e.id, child: Text('${e.type} - ${e.brand}'))).toList(),
                onChanged: (val) => setState(() => _equipmentId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildField('Problema relatado', _description, (val) => _description = val, true),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prioridade', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: _fieldDeco(),
                          items: ['Baixa', 'Média', 'Alta', 'Urgente'].map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(value: p, child: Text(p))).toList(),
                          onChanged: (val) => setState(() => _priority = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prazo', style: TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: _deadline,
                          decoration: _fieldDeco(),
                          onSaved: (val) => _deadline = val ?? '',
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('Status da OS', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _fieldDeco(),
                items: ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada']
                    .map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 16),
              const Text('Responsável', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _technicianId,
                decoration: _fieldDeco(),
                items: provider.technicians.map<DropdownMenuItem<String>>((t) => DropdownMenuItem<String>(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _technicianId = val),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

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
              child: const Text('Salvar ordem de serviço', style: TextStyle(fontSize: 16)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }

  Widget _buildField(String label, String initialValue, Function(String) onSaved, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: label == 'Problema relatado' ? 3 : 1,
          decoration: _fieldDeco(),
          onSaved: (val) => onSaved(val ?? ''),
          validator: (val) => (isRequired && (val == null || val.isEmpty)) ? 'Obrigatório' : null,
        ),
      ],
    );
  }
}
