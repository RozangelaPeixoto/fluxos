import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/work_order.dart';
import '../providers/app_provider.dart';
import '../screens/work_order_detail_screen.dart';
import 'status_pill.dart';

import 'package:provider/provider.dart';

class WorkOrderCard extends StatelessWidget {
  final WorkOrder workOrder;
  final bool showCriticalTag;

  const WorkOrderCard({
    super.key,
    required this.workOrder,
    this.showCriticalTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    final client = provider.clients.firstWhere(
      (c) => c.id == workOrder.clientId,
      orElse: () => throw Exception(),
    );
    final eq = provider.equipments.firstWhere(
      (e) => e.id == workOrder.equipmentId,
      orElse: () => throw Exception(),
    );
    final techName = workOrder.technicianId != null
        ? provider.technicians
              .firstWhere((t) => t.id == workOrder.technicianId)
              .name
        : 'Não atribuído';

    String deadlineStr = 'Sem prazo';
    bool isOverdue = false;

    if (workOrder.deadline != null && workOrder.deadline!.isNotEmpty) {
      try {
        final dl = DateTime.parse(workOrder.deadline!);
        deadlineStr = DateFormat("dd/MM/yy 'às' HH:mm").format(dl);
        if (dl.isBefore(DateTime.now()) && workOrder.status != 'Concluída' && workOrder.status != 'Cancelada') {
          isOverdue = true;
        }
      } catch (_) {
        deadlineStr = workOrder.deadline!;
      }
    }

    String criticalTag = '';
    if (showCriticalTag && isOverdue) {
      criticalTag = 'Atrasada';
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkOrderDetailScreen(workOrder: workOrder),
        ),
      ),
      child: Container(
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
                  workOrder.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (criticalTag.isNotEmpty) ...[
                      StatusPill(status: criticalTag),
                      const SizedBox(width: 8),
                    ],
                    StatusPill(status: workOrder.priority, isPriority: true),
                    const SizedBox(width: 8),
                    StatusPill(status: workOrder.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              client.name,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              eq.type,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Técnico: $techName',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Prazo: $deadlineStr',
                  style: TextStyle(
                    color: isOverdue ? Colors.red.shade700 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
