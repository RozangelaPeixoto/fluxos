import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../providers/app_provider.dart';
import 'clients_screen.dart';
import 'equipments_screen.dart';
import 'technicians_screen.dart';
import 'work_orders_screen.dart';
import 'work_order_detail_screen.dart';
import '../models/work_order.dart';
import '../widgets/status_pill.dart';
import '../widgets/work_order_card.dart';

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
    initializeDateFormatting('pt_BR', null);
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
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Ordens'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'Equipamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.engineering_outlined), activeIcon: Icon(Icons.engineering), label: 'Técnicos'),
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
        title: Consumer<AppProvider>(
          builder: (context, provider, _) {
            String name = provider.loggedUser?.name ?? 'Usuário';
            String date = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(DateTime.now());
            date = date[0].toUpperCase() + date.substring(1);
            
            return Row(
              children: [
                Image.asset('assets/logo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olá, $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
                    Text(date, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            );
          },
        ),
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
          
          int urgent = 0;
          int overdue = 0;
          final now = DateTime.now();
          List<WorkOrder> criticalOs = [];
          for (var o in provider.workOrders) {
            if (o.status != 'Concluída' && o.status != 'Cancelada') {
              bool isOverdue = false;
              if (o.deadline != null && o.deadline!.isNotEmpty) {
                try {
                  final dl = DateTime.parse(o.deadline!);
                  if (dl.isBefore(now)) {
                    isOverdue = true;
                  }
                } catch (_) {}
              }
              
              bool isUrgent = (o.priority == 'Urgente');

              if (isOverdue) overdue++;
              if (isUrgent) urgent++;

              if (isOverdue || isUrgent) {
                criticalOs.add(o);
              }
            }
          }

          double totalValue = provider.workOrders.fold(0.0, (sum, o) => sum + o.totalCost);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.0,
                  children: [
                    _buildStatCard('Total de OS', totalOS.toString(), Colors.black87),
                    _buildStatCard('Abertas', open.toString(), Colors.blue.shade700),
                    _buildStatCard('Em atendimento', inProgress.toString(), Colors.blue.shade700),
                    _buildStatCard('Aguardando peça', waiting.toString(), Colors.orange.shade700),
                    _buildStatCard('Concluídas', completed.toString(), Colors.green.shade700),
                    _buildStatCard('Urgentes', urgent.toString(), Colors.red.shade700),
                    _buildStatCard('Atrasadas', overdue.toString(), Colors.red.shade700),
                    _buildStatCard('Valor total', 'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(totalValue)}', Colors.green.shade700),
                  ],
                ),
                
                if (criticalOs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text('Requer atenção', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                            const Spacer(),
                            Text('${criticalOs.length} OS', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$urgent urgentes e $overdue atrasadas precisam de ação imediata.',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Ordens críticas', ''),
                const SizedBox(height: 12),
                ...criticalOs.map((os) => _buildOsCard(context, os, provider, showCriticalTag: true)),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Ordens recentes', 'Ver todas'),
                const SizedBox(height: 12),
                ...provider.workOrders
                    .where((o) => o.status != 'Concluída' && o.status != 'Cancelada')
                    .toList()
                    .reversed
                    .take(3)
                    .map((os) => _buildOsCard(context, os, provider, showCriticalTag: false)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: () {
              final state = context.findAncestorStateOfType<_DashboardScreenState>();
              state?._onItemTapped(1);
            },
            child: Text(action, style: TextStyle(fontSize: 14, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildOsCard(BuildContext context, WorkOrder os, AppProvider provider, {bool showCriticalTag = false}) {
    return WorkOrderCard(workOrder: os, showCriticalTag: showCriticalTag);
  }
}
