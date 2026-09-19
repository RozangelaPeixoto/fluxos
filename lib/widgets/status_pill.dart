import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final bool isPriority;

  const StatusPill({super.key, required this.status, this.isPriority = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;

    if (isPriority) {
      switch (status) {
        case 'Urgente':
          color = Colors.red.shade700;
          bgColor = Colors.red.shade50;
          break;
        case 'Alta':
          color = Colors.orange.shade700;
          bgColor = Colors.orange.shade50;
          break;
        case 'Média':
          color = Colors.blue.shade700;
          bgColor = Colors.blue.shade50;
          break;
        case 'Baixa':
          color = Colors.green;
          bgColor = Colors.green.shade50;
          break;
        default:
          color = Colors.grey;
          bgColor = Colors.grey.shade100;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    switch (status) {
      case 'Aberta':
        color = Colors.teal.shade600;
        bgColor = Colors.teal.shade50;
        break;
      case 'Atribuída':
        color = Colors.purple.shade600;
        bgColor = Colors.purple.shade50;
        break;
      case 'Em atendimento':
        color = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        break;
      case 'Aguardando peça':
        color = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        break;
      case 'Concluída':
        color = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        break;
      case 'Cancelada':
        color = Colors.grey.shade700;
        bgColor = Colors.grey.shade200;
        break;
      case 'Atrasada':
        color = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        break;
      case 'Urgente':
        color = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        break;
      default:
        color = Colors.grey;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
