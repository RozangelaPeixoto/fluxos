import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../models/technician.dart';

import 'package:uuid/uuid.dart';

import 'technician_detail_screen.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Ativos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Técnicos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            Consumer<AppProvider>(
              builder: (context, provider, _) {
                final ativos = provider.technicians
                    .where((t) => t.isActive == 1)
                    .length;
                return Text(
                  '$ativos técnicos ativos',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.technicians.where((t) {
            final matchesSearch =
                t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.matricula.contains(_searchQuery);
            bool matchesFilter = true;
            if (_filterStatus == 'Ativos') matchesFilter = t.isActive == 1;
            if (_filterStatus == 'Inativos') matchesFilter = t.isActive == 0;

            return matchesSearch && matchesFilter;
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Ativos', 'Inativos', 'Todos'].map((status) {
                      final isSelected = _filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected)
                              setState(() => _filterStatus = status);
                          },
                          selectedColor: Colors.red.shade100,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.red.shade900
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.red.shade300
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar técnico'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TechnicianFormScreen(),
                      ),
                    ),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TechnicianDetailScreen(technician: tech),
                          ),
                        ),
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
                                child: Text(
                                  tech.name.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tech.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tech.specialty,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tech.isActive == 1
                                      ? Colors.green.shade50
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tech.isActive == 1 ? 'Ativo' : 'Inativo',
                                  style: TextStyle(
                                    color: tech.isActive == 1
                                        ? Colors.green.shade700
                                        : Colors.grey.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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

    if (widget.technician != null && widget.technician!.matricula.isNotEmpty) {
      _matricula = widget.technician!.matricula;
    } else {
      _matricula = Random().nextInt(999999).toString().padLeft(6, '0');
    }

    _senha = widget.technician?.senha ?? '';
    _isActive = widget.technician?.isActive ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.technician == null
                  ? 'Cadastrar técnico'
                  : 'Editar técnico',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 22,
              ),
            ),
            const Text(
              'Dados do profissional',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
              const Text(
                'Identificação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildField('Nome', _name, (val) => _name = val, true),
              _buildField(
                'Especialidade',
                _specialty,
                (val) => _specialty = val,
                true,
              ),
              _buildField(
                'Contato',
                _contact,
                (val) => _contact = val,
                true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  MaskTextInputFormatter(
                    mask: '(##) #####-####',
                    filter: {"#": RegExp(r'[0-9]')},
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Acesso ao sistema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildField(
                'Matrícula',
                _matricula,
                (val) => _matricula = val,
                true,
                readOnly: true,
              ),
              _buildField('Senha', _senha, (val) => _senha = val, true),

              const SizedBox(height: 24),
              const Text(
                'Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Ativo')),
                    ButtonSegment(value: 0, label: Text('Inativo')),
                  ],
                  selected: {_isActive},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _isActive = newSelection.first;
                    });
                  },
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    createdAt:
                        widget.technician?.createdAt ??
                        DateTime.now().toIso8601String(),
                  );
                  provider.saveTechnician(newTech);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Salvar técnico',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String initialValue,
    Function(String) onSaved,
    bool isRequired, {
    bool readOnly = false,
    dynamic inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(color: readOnly ? Colors.black54 : Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onSaved: (val) => onSaved(val ?? ''),
            validator: (val) => (isRequired && (val == null || val.isEmpty))
                ? 'Obrigatório'
                : null,
          ),
        ],
      ),
    );
  }
}
