import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/client.dart';
import 'clients_screen.dart';
import 'equipments_screen.dart';
import 'equipment_detail_screen.dart';
import '../widgets/work_order_card.dart';
import '../widgets/status_pill.dart';
import 'work_order_detail_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final c = provider.clients.firstWhere(
          (x) => x.id == client.id,
          orElse: () => client,
        );
        final clientOs = provider.workOrders
            .where((o) => o.clientId == c.id)
            .toList();
        final clientEq = provider.equipments
            .where((e) => e.clientId == c.id)
            .toList();
        final totalServices = clientOs.fold(0.0, (sum, o) => sum + o.totalCost);

        String joinedDate = '';
        try {
          final dt = DateTime.parse(c.createdAt);
          final months = [
            'janeiro',
            'fevereiro',
            'março',
            'abril',
            'maio',
            'junho',
            'julho',
            'agosto',
            'setembro',
            'outubro',
            'novembro',
            'dezembro',
          ];
          joinedDate = 'Cliente desde ${months[dt.month - 1]} de ${dt.year}';
        } catch (_) {}

        final isPj = c.document.replaceAll(RegExp(r'[^0-9]'), '').length > 11;

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
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 22,
                  ),
                ),
                if (joinedDate.isNotEmpty)
                  Text(
                    joinedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
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
                        children: [
                          Icon(
                            isPj ? Icons.business : Icons.person,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPj ? 'PESSOA JURÍDICA' : 'PESSOA FÍSICA',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            c.document,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            c.phone,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            c.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatSquare(
                        clientOs.length.toString(),
                        'Ordens',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatSquare(
                        clientEq.length.toString(),
                        'Equipamentos',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatSquare(
                        'R\$ ${totalServices.toStringAsFixed(0)}',
                        'Serviços',
                      ),
                    ),
                  ],
                ),
                if (clientEq.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Equipamentos',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EquipmentFormScreen(),
                          ),
                        ),
                        child: Text(
                          'Adicionar',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...clientEq.map(
                    (eq) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EquipmentDetailScreen(equipment: eq),
                        ),
                      ),
                      child: Container(
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
                            Text(
                              '${eq.type} ${eq.brand} ${eq.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Patrimônio ${eq.patrimony}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                if (clientOs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Ordens recentes',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ...clientOs.take(3).map((os) {
                    final eq = provider.equipments
                        .where((e) => e.id == os.equipmentId)
                        .firstOrNull;
                    final eqName = eq != null
                        ? '${eq.type} ${eq.brand} ${eq.model}'
                        : 'Equipamento desconhecido';

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkOrderDetailScreen(workOrder: os),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
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
                                Text(
                                  os.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    StatusPill(
                                      status: os.priority,
                                      isPriority: true,
                                    ),
                                    const SizedBox(width: 8),
                                    StatusPill(status: os.status),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              eqName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              os.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientFormScreen(client: c),
                      ),
                    ),
                    child: const Text(
                      'Editar cliente',
                      style: TextStyle(fontSize: 16),
                    ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (clientEq.isNotEmpty || clientOs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Não é possível excluir o cliente. Existem equipamentos ou ordens de serviço vinculados.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Excluir cliente'),
                          content: const Text(
                            'Tem certeza que deseja excluir este cliente? Essa ação não pode ser desfeita.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteClient(c.id);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Excluir cliente',
                      style: TextStyle(fontSize: 16),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
