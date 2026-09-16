import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/technician.dart';
import 'package:uuid/uuid.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Técnicos', style: TextStyle(fontWeight: FontWeight.bold)),
            Consumer<AppProvider>(
              builder: (context, provider, _) => Text(
                '${provider.technicians.length} técnicos cadastrados',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.technicians.where((t) {
            return t.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                   t.matricula.contains(_searchQuery);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou matrícula',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar técnico'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianFormScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tech = filtered[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TechnicianFormScreen(technician: tech))),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                child: Text(tech.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${tech.specialty} • ${tech.isActive == 1 ? 'Ativo' : 'Inativo'}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TechnicianFormScreen extends StatefulWidget {
  final Technician? technician;
  const TechnicianFormScreen({super.key, this.technician});

  @override
  State<TechnicianFormScreen> createState() => _TechnicianFormScreenState();
}

class _TechnicianFormScreenState extends State<TechnicianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _contact, _specialty, _matricula, _senha;
  late int _isActive;

  @override
  void initState() {
    super.initState();
    _name = widget.technician?.name ?? '';
    _contact = widget.technician?.contact ?? '';
    _specialty = widget.technician?.specialty ?? '';
    _matricula = widget.technician?.matricula ?? '';
    _senha = widget.technician?.senha ?? '';
    _isActive = widget.technician?.isActive ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.technician == null ? 'Cadastrar técnico' : 'Editar técnico', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Dados do profissional', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Identificação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Nome', _name, (val) => _name = val, true),
              _buildField('Especialidade', _specialty, (val) => _specialty = val, true),
              _buildField('Contato', _contact, (val) => _contact = val, false),
              
              const SizedBox(height: 24),
              const Text('Acesso ao sistema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Matrícula', _matricula, (val) => _matricula = val, true),
              _buildField('Senha', _senha, (val) => _senha = val, true),

              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  title: const Text('Status (Ativo)'),
                  value: _isActive == 1,
                  activeColor: Colors.red.shade700,
                  onChanged: (val) => setState(() => _isActive = val ? 1 : 0),
                ),
              ),
            ],
          ),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newTech = Technician(
                    id: widget.technician?.id ?? const Uuid().v4(),
                    name: _name,
                    contact: _contact,
                    specialty: _specialty,
                    matricula: _matricula,
                    senha: _senha,
                    isActive: _isActive,
                  );
                  provider.saveTechnician(newTech);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar técnico', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String initialValue, Function(String) onSaved, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            onSaved: (val) => onSaved(val ?? ''),
            validator: (val) => (isRequired && (val == null || val.isEmpty)) ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }
}
