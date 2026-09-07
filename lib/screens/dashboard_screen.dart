import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'clients_screen.dart';
import 'equipments_screen.dart';
import 'technicians_screen.dart';
import 'work_orders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardContent(),
      const WorkOrdersScreen(),
      const ClientsScreen(),
      const EquipmentsScreen(),
      const TechniciansScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Ordens'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.print), label: 'Equipamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: 'Técnicos'),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FluxOS - Painel'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalOS = provider.workOrders.length;
          int open = provider.workOrders.where((o) => o.status == 'Aberta').length;
          int inProgress = provider.workOrders.where((o) => o.status == 'Em atendimento').length;
          int waiting = provider.workOrders.where((o) => o.status == 'Aguardando peça').length;
          int completed = provider.workOrders.where((o) => o.status == 'Concluída').length;
          
          int urgent = provider.workOrders.where((o) => o.priority == 'Urgente' && o.status != 'Concluída' && o.status != 'Cancelada').length;
          
          int overdue = 0;
          final now = DateTime.now();
          for (var o in provider.workOrders) {
            if (o.status != 'Concluída' && o.status != 'Cancelada' && o.deadline != null) {
              try {
                final dl = DateTime.parse(o.deadline!);
                if (dl.isBefore(now)) overdue++;
              } catch (e) {
                // ignore
              }
            }
          }

          double totalValue = provider.workOrders.fold(0.0, (sum, o) => sum + o.totalCost);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (urgent > 0 || overdue > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Atenção: $urgent OS urgentes e $overdue atrasadas.',
                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Total de OS', totalOS.toString(), Colors.black87),
                    _buildStatCard('Abertas', open.toString(), Colors.blue),
                    _buildStatCard('Em atendimento', inProgress.toString(), Colors.blueAccent),
                    _buildStatCard('Aguardando peça', waiting.toString(), Colors.orange),
                    _buildStatCard('Concluídas', completed.toString(), Colors.green),
                    _buildStatCard('Valor total', 'R\$ ${totalValue.toStringAsFixed(2)}', Colors.green.shade700),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
