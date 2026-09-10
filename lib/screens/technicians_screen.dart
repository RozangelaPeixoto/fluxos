import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/technician.dart';
import 'package:uuid/uuid.dart';

class TechniciansScreen extends StatelessWidget {
  const TechniciansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Técnicos')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.technicians.isEmpty) {
            return const Center(child: Text('Nenhum técnico cadastrado.'));
          }
          return ListView.builder(
            itemCount: provider.technicians.length,
            itemBuilder: (context, index) {
              final tech = provider.technicians[index];
              return ListTile(
                title: Text(tech.name),
                subtitle: Text('${tech.specialty} - ${tech.isActive == 1 ? 'Ativo' : 'Inativo'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteTechnician(tech.id),
                ),
                onTap: () => _showForm(context, tech),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, Technician? tech) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TechnicianForm(technician: tech),
    );
  }
}

class TechnicianForm extends StatefulWidget {
  final Technician? technician;
  const TechnicianForm({super.key, this.technician});

  @override
  State<TechnicianForm> createState() => _TechnicianFormState();
}

class _TechnicianFormState extends State<TechnicianForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _contact;
  late String _specialty;
  late int _isActive;

  @override
  void initState() {
    super.initState();
    _name = widget.technician?.name ?? '';
    _contact = widget.technician?.contact ?? '';
    _specialty = widget.technician?.specialty ?? '';
    _isActive = widget.technician?.isActive ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.technician == null ? 'Novo Técnico' : 'Editar Técnico', style: const TextStyle(fontSize: 20)),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              onSaved: (val) => _name = val ?? '',
              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
            ),
            TextFormField(
              initialValue: _contact,
              decoration: const InputDecoration(labelText: 'Contato'),
              onSaved: (val) => _contact = val ?? '',
            ),
            TextFormField(
              initialValue: _specialty,
              decoration: const InputDecoration(labelText: 'Especialidade'),
              onSaved: (val) => _specialty = val ?? '',
            ),
            SwitchListTile(
              title: const Text('Ativo'),
              value: _isActive == 1,
              onChanged: (val) => setState(() => _isActive = val ? 1 : 0),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newTech = Technician(
                    id: widget.technician?.id ?? const Uuid().v4(),
                    name: _name,
                    contact: _contact,
                    specialty: _specialty,
                    isActive: _isActive,
                  );
                  Provider.of<AppProvider>(context, listen: false).saveTechnician(newTech);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
