import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'work_orders_screen.dart';

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

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(os.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Criada em ${os.openDate.split('T')[0]}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusPill(os.status),
                          _buildPriorityPill(os.priority),
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
                const Text('Informações completas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildInfoCard('Cliente', client.name),
                _buildInfoCard('Equipamento', '${eq.type} ${eq.brand} ${eq.model}'),
                if (os.deadline != null) _buildInfoCard('Prazo', os.deadline!),
                if (os.diagnosis != null && os.diagnosis!.isNotEmpty) _buildInfoCard('Diagnóstico', os.diagnosis!),
                if (os.solution != null && os.solution!.isNotEmpty) _buildInfoCard('Solução', os.solution!),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Financeiro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('Peças R\$ ${os.partsCost.toStringAsFixed(2)}'),
                      Text('Mão de obra R\$ ${os.laborCost.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text('R\$ ${os.totalCost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
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

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriorityPill(String priority) {
    Color color;
    switch (priority) {
      case 'Urgente': color = Colors.red; break;
      case 'Alta': color = Colors.deepOrange; break;
      case 'Média': color = Colors.orange; break;
      case 'Baixa': color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Text('$priority prioridade', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
