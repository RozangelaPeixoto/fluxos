import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/client.dart';
import 'clients_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final Client client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final c = provider.clients.firstWhere((x) => x.id == client.id, orElse: () => client);
        final clientOs = provider.workOrders.where((o) => o.clientId == c.id).toList();
        final clientEq = provider.equipments.where((e) => e.clientId == c.id).toList();
        final totalServices = clientOs.fold(0.0, (sum, o) => sum + o.totalCost);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF3F4F6),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
                const Text('Cliente desde janeiro de 2024', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PESSOA JURÍDICA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(c.document, style: const TextStyle(fontSize: 18, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Text('${c.phone} • ${c.email}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(c.address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatSquare(clientOs.length.toString(), 'Ordens')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatSquare(clientEq.length.toString(), 'Equipamentos')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatSquare('R\$ ${totalServices.toStringAsFixed(0)}', 'Serviços')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Equipamentos', style: TextStyle(fontSize: 18, color: Colors.black87)),
                    Text('Ver todos', style: TextStyle(fontSize: 14, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ...clientEq.take(2).map((eq) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${eq.type} ${eq.brand} ${eq.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Patrimônio ${eq.patrimony} • Ativo', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                const Text('Ordens recentes', style: TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 12),
                ...clientOs.take(2).map((os) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(os.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(os.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 12),
                      _buildStatusPill(os.status),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientFormScreen(client: c))),
                    child: const Text('Editar cliente', style: TextStyle(fontSize: 16)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color = Colors.blue.shade700;
    Color bgColor = Colors.blue.shade50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
