import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'work_orders_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/status_pill.dart';

class WorkOrderDetailScreen extends StatelessWidget {
  final WorkOrder workOrder;
  const WorkOrderDetailScreen({super.key, required this.workOrder});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final os = provider.workOrders.firstWhere((o) => o.id == workOrder.id, orElse: () => workOrder);
        final client = provider.clients.firstWhere((c) => c.id == os.clientId, orElse: () => throw Exception());
        final eq = provider.equipments.firstWhere((e) => e.id == os.equipmentId, orElse: () => throw Exception());
        final tech = os.technicianId != null ? provider.technicians.firstWhere((t) => t.id == os.technicianId, orElse: () => throw Exception()) : null;

        String openDateStr = '';
        try {
           final openDate = DateTime.parse(os.openDate);
           openDateStr = DateFormat("dd 'de' MMMM", 'pt_BR').format(openDate);
        } catch (_) {}

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(os.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
                Text('Criada em $openDateStr', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                          StatusPill(status: os.status),
                          StatusPill(status: os.priority, isPriority: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(os.description, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Responsável: ${tech?.name ?? 'Não atribuído'}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Informações completas', style: TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildInfoCard('Cliente', client.name),
                _buildInfoCard('Equipamento', '${eq.type} ${eq.brand} ${eq.model}'),
                if (os.deadline != null) _buildInfoCard('Prazo', _formatDate(os.deadline!)),
                if (os.diagnosis != null && os.diagnosis!.isNotEmpty) _buildInfoCard('Diagnóstico', os.diagnosis!),
                if (os.solution != null && os.solution!.isNotEmpty) _buildInfoCard('Solução', os.solution!),
                
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Financeiro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 12),
                      Text('Peças R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(os.partsCost)}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Mão de obra R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(os.laborCost)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text('R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(os.totalCost)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Fotos e evidências', style: TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Histórico da OS', style: TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildHistoryItem(Icons.check_circle, Colors.green, 'Aberta', _formatDate(os.openDate)),
                if (os.technicianId != null) _buildHistoryItem(Icons.check_circle, Colors.green, 'Atribuída', _formatDate(os.openDate)),
                _buildHistoryItem(Icons.arrow_circle_right, Colors.blue, 'Status Atual', os.status, isLast: true, isVeryLast: true),
                const SizedBox(height: 24),
              ],
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkOrderFormScreen(os: os))),
                  child: const Text('Atualizar OS', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sem data';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat("dd/MM/yy 'às' HH:mm").format(d);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(IconData icon, Color color, String title, String subtitle, {bool isLast = false, bool isPending = false, bool isVeryLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: color, size: 24),
            if (!isVeryLast) Container(
              width: 2,
              height: 40,
              color: isPending ? Colors.transparent : Colors.grey.shade300,
            )
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPending ? Colors.grey : Colors.black87)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }
}
