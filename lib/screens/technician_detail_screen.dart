import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/technician.dart';
import 'technicians_screen.dart';
import '../widgets/status_pill.dart';
import '../widgets/work_order_card.dart';

class TechnicianDetailScreen extends StatelessWidget {
  final Technician technician;
  
  const TechnicianDetailScreen({super.key, required this.technician});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tech = provider.technicians.firstWhere((x) => x.id == technician.id, orElse: () => technician);
        final techOs = provider.workOrders.where((o) => o.technicianId == tech.id).toList();

        // format date
        String registeredDate = '';
        try {
          final dt = DateTime.parse(tech.createdAt);
          registeredDate = DateFormat('dd/MM/yyyy').format(dt);
        } catch (e) {
          registeredDate = 'Data desconhecida';
        }

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
                Text(tech.specialty, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  radius: 20,
                  child: Text(tech.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tech.name.substring(0, 2).toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue.shade700),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text(tech.contact, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.badge, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text('MAT. ${tech.matricula}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text('Cadastrado em $registeredDate', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tech.isActive == 1 ? Colors.green.shade50 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tech.isActive == 1 ? 'ATIVO' : 'INATIVO',
                          style: TextStyle(
                            color: tech.isActive == 1 ? Colors.green.shade700 : Colors.grey.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatSquare('32', 'CONCLUÍDAS')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatSquare('R\$ 8.587', 'FATURAMENTO')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatSquare('3h20', 'MÉDIA / OS')),
                  ],
                ),
                
                if (techOs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ordens recentes', style: TextStyle(fontSize: 18, color: Colors.black87)),
                      Text('Ver tudo', style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...techOs.take(3).map((os) => WorkOrderCard(workOrder: os)),
                ],
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TechnicianFormScreen(technician: tech))),
                    child: const Text('Editar técnico', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (techOs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Não é possível excluir o técnico. Existem ordens de serviço vinculadas.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir técnico'),
                          content: const Text('Tem certeza que deseja excluir este técnico? Essa ação não pode ser desfeita.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                provider.deleteTechnician(tech.id);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              }, 
                              child: const Text('Excluir', style: TextStyle(color: Colors.red))
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Excluir técnico', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatSquare(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red.shade700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
