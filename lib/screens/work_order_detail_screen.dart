import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'work_order_form_screen.dart';
import '../widgets/status_pill.dart';

class WorkOrderDetailScreen extends StatelessWidget {
  final WorkOrder workOrder;
  const WorkOrderDetailScreen({super.key, required this.workOrder});

  void _attemptDelete(
    BuildContext context,
    WorkOrder os,
    AppProvider provider,
  ) {
    if (os.status != 'Aberta' && os.status != 'Cancelada') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas OS abertas ou canceladas podem ser excluídas.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Ordem de Serviço'),
        content: const Text(
          'Tem certeza que deseja excluir esta ordem de serviço? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWorkOrder(os.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final os = provider.workOrders.firstWhere(
          (o) => o.id == workOrder.id,
          orElse: () => workOrder,
        );
        final client = provider.clients.firstWhere(
          (c) => c.id == os.clientId,
          orElse: () => throw Exception(),
        );
        final eq = provider.equipments.firstWhere(
          (e) => e.id == os.equipmentId,
          orElse: () => throw Exception(),
        );
        final tech = os.technicianId != null
            ? provider.technicians.firstWhere(
                (t) => t.id == os.technicianId,
                orElse: () => throw Exception(),
              )
            : null;

        List<String> photosList = [];
        if (os.photos.isNotEmpty) {
          photosList = os.photos.split(',').where((p) => p.isNotEmpty).toList();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black87),
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              os.code,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 22,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CABEÇALHO DA OS
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
                      Text(
                        os.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Responsável: ${tech?.name ?? 'Não atribuído'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // INFORMAÇÕES COMPLETAS
                const Text(
                  'Informações completas',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildInfoCard('Cliente', client.name),
                _buildInfoCard(
                  'Equipamento',
                  '${eq.type} ${eq.brand} ${eq.model}',
                ),
                if (os.deadline != null && os.deadline!.isNotEmpty)
                  _buildInfoCard('Prazo', os.deadline!),
                if (os.diagnosis != null && os.diagnosis!.isNotEmpty)
                  _buildInfoCard('Diagnóstico', os.diagnosis!),
                if (os.solution != null && os.solution!.isNotEmpty)
                  _buildInfoCard('Solução', os.solution!),

                if (photosList.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fotos e evidências',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: photosList
                                .map(
                                  (p) => Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(File(p)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                // FINANCEIRO
                _buildFinancialSummary(os),

                const SizedBox(height: 12),

                // HISTÓRICO
                _buildHistory(os),

                const SizedBox(height: 32),
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
                        builder: (_) => WorkOrderFormScreen(os: os),
                      ),
                    ),
                    child: const Text(
                      'Editar ordem de serviço',
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
                    onPressed: () => _attemptDelete(context, os, provider),
                    child: const Text(
                      'Excluir ordem de serviço',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(WorkOrder os) {
    final formatCurrency = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo financeiro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Serviços',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                formatCurrency.format(os.laborCost),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Peças',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                formatCurrency.format(os.partsCost),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desconto',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                '- ${formatCurrency.format(os.discount)}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatCurrency.format(os.totalCost),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(WorkOrder os) {
    Map<String, dynamic> history = {};
    if (os.statusHistory.isNotEmpty) {
      try {
        history = jsonDecode(os.statusHistory);
      } catch (_) {}
    }

    final formatDate = DateFormat("dd/MM/yy HH:mm");

    List<String> flow = [];
    bool isCanceled = os.status == 'Cancelada';

    if (isCanceled) {
      flow.add('Aberta');
      if (history.containsKey('Atribuída')) flow.add('Atribuída');
      if (history.containsKey('Em atendimento')) flow.add('Em atendimento');
      if (history.containsKey('Aguardando peça')) flow.add('Aguardando peça');
      if (history.containsKey('Concluída')) flow.add('Concluída');
      flow.add('Cancelada');
    } else {
      flow.add('Aberta');
      flow.add('Atribuída');
      flow.add('Em atendimento');
      if (history.containsKey('Aguardando peça') ||
          os.status == 'Aguardando peça') {
        flow.add('Aguardando peça');
      }
      flow.add('Concluída');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico da OS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: flow.map((statusStep) {
              bool isReached =
                  history.containsKey(statusStep) || statusStep == 'Aberta';
              bool isCurrent = os.status == statusStep;
              bool isCancelStep = statusStep == 'Cancelada';

              String dateStr = '';
              if (history.containsKey(statusStep)) {
                try {
                  dateStr = formatDate.format(
                    DateTime.parse(history[statusStep]),
                  );
                } catch (_) {}
              } else if (statusStep == 'Aberta') {
                try {
                  dateStr = formatDate.format(DateTime.parse(os.openDate));
                } catch (_) {}
              } else if (isCurrent && os.statusHistory.isEmpty) {
                // Fallback para mock/legacy
                try {
                  dateStr = formatDate.format(DateTime.parse(os.openDate));
                } catch (_) {}
              }

              IconData icon;
              Color iconColor;
              Color bgColor;

              if (isCurrent && !isCancelStep) {
                isReached = true;
                if (statusStep == 'Concluída') {
                  icon = Icons.check;
                  iconColor = Colors.white;
                  bgColor = Colors.green.shade600;
                } else {
                  icon = Icons.arrow_forward;
                  iconColor = Colors.white;
                  bgColor = Colors.blue.shade600;
                }
              } else if (isCancelStep && isReached) {
                icon = Icons.close;
                iconColor = Colors.white;
                bgColor = Colors.grey.shade600;
              } else if (isReached) {
                icon = Icons.check;
                iconColor = Colors.white;
                bgColor = Colors.green.shade600;
              } else {
                icon = Icons.circle;
                iconColor = Colors.grey.shade300;
                bgColor = Colors.transparent;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: !isReached && !isCurrent
                            ? Border.all(color: Colors.grey.shade300, width: 2)
                            : null,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusStep,
                          style: TextStyle(
                            fontSize: 14,
                            color: (isReached || isCurrent)
                                ? Colors.black87
                                : Colors.black54,
                          ),
                        ),
                        if (isReached && dateStr.isNotEmpty)
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
