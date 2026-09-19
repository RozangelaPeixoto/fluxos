import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import '../widgets/work_order_card.dart';
import 'work_order_form_screen.dart';
import 'work_order_detail_screen.dart';
import '../models/equipment.dart';
import '../widgets/status_pill.dart';
import '../widgets/work_order_card.dart';
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
      appBar: AppBar(
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
                      return WorkOrderCard(workOrder: filtered[index]);
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

// Moved to work_order_form_screen.dart
