import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../providers/app_provider.dart';
import '../models/work_order.dart';
import '../models/equipment.dart';
import '../models/technician.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    double value = double.parse(newValue.text.replaceAll(RegExp('[^0-9]'), ''));
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    String newText = formatter.format(value / 100);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class WorkOrderFormScreen extends StatefulWidget {
  final WorkOrder? os;
  const WorkOrderFormScreen({super.key, this.os});

  @override
  State<WorkOrderFormScreen> createState() => _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends State<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  String? _equipmentId;
  late String _description;
  String _priority = 'Média';
  String? _technicianId;
  String _status = 'Aberta';

  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();

  final TextEditingController _laborCostCtrl = TextEditingController();
  final TextEditingController _partsCostCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();

  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _clientId = widget.os?.clientId;
    _equipmentId = widget.os?.equipmentId;
    _description = widget.os?.description ?? '';

    _priority = widget.os?.priority ?? 'Média';
    if (!['Baixa', 'Média', 'Alta', 'Urgente'].contains(_priority)) {
      _priority = 'Média';
    }

    _technicianId = widget.os?.technicianId;

    _status = widget.os?.status ?? 'Aberta';
    if (![
      'Aberta',
      'Atribuída',
      'Em atendimento',
      'Aguardando peça',
      'Concluída',
      'Cancelada',
    ].contains(_status)) {
      _status = 'Aberta';
    }

    _deadlineController.text = widget.os?.deadline ?? '';
    _diagnosisController.text = widget.os?.diagnosis ?? '';
    _solutionController.text = widget.os?.solution ?? '';

    final nFmt = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    _laborCostCtrl.text = nFmt.format(widget.os?.laborCost ?? 0.0);
    _partsCostCtrl.text = nFmt.format(widget.os?.partsCost ?? 0.0);
    _discountCtrl.text = nFmt.format(widget.os?.discount ?? 0.0);

    if (widget.os != null && widget.os!.photos.isNotEmpty) {
      _photos = widget.os!.photos
          .split(',')
          .where((p) => p.isNotEmpty)
          .toList();
    }

    _laborCostCtrl.addListener(_updateTotal);
    _partsCostCtrl.addListener(_updateTotal);
    _discountCtrl.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _laborCostCtrl.dispose();
    _partsCostCtrl.dispose();
    _discountCtrl.dispose();
    _deadlineController.dispose();
    _diagnosisController.dispose();
    _solutionController.dispose();
    super.dispose();
  }

  double _parseCurrency(String val) {
    if (val.isEmpty) return 0.0;
    String clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return 0.0;
    return double.parse(clean) / 100;
  }

  void _updateTotal() {
    setState(() {}); // Trigger rebuild to update total UI
  }

  double get _totalCost {
    double labor = _parseCurrency(_laborCostCtrl.text);
    double parts = _parseCurrency(_partsCostCtrl.text);
    double discount = _parseCurrency(_discountCtrl.text);
    return labor + parts - discount;
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _deadlineController.text = DateFormat('dd/MM/yyyy HH:mm')
              .format(finalDateTime);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Create folder if it doesn't exist
      final directory = Directory('fotos');
      if (!await directory.exists()) {
        await directory.create();
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final savedImage = await File(image.path)
          .copy('${directory.path}/$fileName');

      setState(() {
        _photos.add(savedImage.path);
      });
    }
  }

  bool _validateStatusTransition() {
    if (_status == 'Atribuída' && _technicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para o status "Atribuída", um técnico responsável é obrigatório.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_status == 'Em atendimento' && _technicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para o status "Em atendimento", um técnico responsável é obrigatório.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_status == 'Aguardando peça' &&
        _diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para o status "Aguardando peça", um diagnóstico é obrigatório.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    if (_status == 'Concluída' && _solutionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para o status "Concluída", uma solução proposta é obrigatória.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (!_validateStatusTransition()) return;

      _formKey.currentState!.save();
      final provider = Provider.of<AppProvider>(context, listen: false);

      Map<String, dynamic> historyMap = {};
      if (widget.os != null && widget.os!.statusHistory.isNotEmpty) {
        try {
          historyMap = jsonDecode(widget.os!.statusHistory);
        } catch (_) {}
      }

      if (widget.os == null) {
        // Nova OS: sempre foi 'Aberta'
        final now = DateTime.now().toIso8601String();
        historyMap['Aberta'] = now;
        if (_status != 'Aberta') {
          historyMap[_status] = now;
        }
      } else if (widget.os!.status != _status) {
        historyMap[_status] = DateTime.now().toIso8601String();
      }

      final newOs = WorkOrder(
        id: widget.os?.id ?? const Uuid().v4(),
        code:
            widget.os?.code ??
            'OS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        clientId: _clientId!,
        equipmentId: _equipmentId!,
        description: _description,
        priority: _priority,
        technicianId: _technicianId,
        openDate: widget.os?.openDate ?? DateTime.now().toIso8601String(),
        deadline: _deadlineController.text.isEmpty
            ? null
            : _deadlineController.text,
        status: _status,
        diagnosis: _diagnosisController.text,
        solution: _solutionController.text,
        laborCost: _parseCurrency(_laborCostCtrl.text),
        partsCost: _parseCurrency(_partsCostCtrl.text),
        discount: _parseCurrency(_discountCtrl.text),
        totalCost: _totalCost,
        photos: _photos.join(','),
        statusHistory: jsonEncode(historyMap),
      );
      provider.saveWorkOrder(newOs);
      Navigator.pop(context);
    }
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    List<Equipment> equipmentsForClient = _clientId == null
        ? []
        : provider.equipments.where((e) => e.clientId == _clientId).toList();
    List<Technician> activeTechs = provider.technicians
        .where((t) => t.isActive == 1)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.os == null
                  ? 'Nova ordem de serviço'
                  : 'Editar ordem de serviço',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 22,
              ),
            ),
            const Text(
              'Preencha os dados do atendimento',
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
              _buildSectionTitle('Cliente e equipamento'),
              const Text('Cliente', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: _fieldDeco(),
                items: provider.clients
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _clientId = val;
                    _equipmentId = null;
                  });
                },
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Equipamento',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _equipmentId,
                decoration: _fieldDeco(),
                items: equipmentsForClient
                    .map<DropdownMenuItem<String>>(
                      (e) => DropdownMenuItem<String>(
                        value: e.id,
                        child: Text('${e.type} - ${e.brand}'),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _equipmentId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Problema e prioridade'),
              const Text(
                'Problema relatado',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: _fieldDeco(),
                onSaved: (val) => _description = val ?? '',
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              const Text('Prioridade', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Baixa', 'Média', 'Alta', 'Urgente'].map((p) {
                  final isSelected = _priority == p;
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _priority = p);
                    },
                    selectedColor: p == 'Baixa'
                        ? Colors.green.shade100
                        : p == 'Média'
                        ? Colors.blue.shade100
                        : p == 'Alta'
                        ? Colors.orange.shade100
                        : Colors.red.shade100,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (p == 'Baixa'
                                ? Colors.green.shade800
                                : p == 'Média'
                                ? Colors.blue.shade800
                                : p == 'Alta'
                                ? Colors.orange.shade800
                                : Colors.red.shade800)
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
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Atendimento'),
              const Text('Status', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      'Aberta',
                      'Atribuída',
                      'Em atendimento',
                      'Aguardando peça',
                      'Concluída',
                      'Cancelada',
                    ].map((s) {
                      final isSelected = _status == s;

                      Color? selColor;
                      Color? selLabelColor;
                      if (isSelected) {
                        switch (s) {
                          case 'Aberta':
                            selColor = Colors.teal.shade50;
                            selLabelColor = Colors.teal.shade600;
                            break;
                          case 'Atribuída':
                            selColor = Colors.purple.shade50;
                            selLabelColor = Colors.purple.shade600;
                            break;
                          case 'Em atendimento':
                            selColor = Colors.blue.shade50;
                            selLabelColor = Colors.blue.shade700;
                            break;
                          case 'Aguardando peça':
                            selColor = Colors.orange.shade50;
                            selLabelColor = Colors.orange.shade700;
                            break;
                          case 'Concluída':
                            selColor = Colors.green.shade50;
                            selLabelColor = Colors.green.shade700;
                            break;
                          case 'Cancelada':
                            selColor = Colors.red.shade50;
                            selLabelColor = Colors.red.shade700;
                            break;
                        }
                      }

                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _status = s);
                        },
                        selectedColor: selColor,
                        labelStyle: TextStyle(
                          color: isSelected ? selLabelColor : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Técnico responsável',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _technicianId,
                decoration: _fieldDeco(),
                items: activeTechs
                    .map<DropdownMenuItem<String>>(
                      (t) => DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(t.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _technicianId = val),
              ),
              const SizedBox(height: 16),
              const Text('Prazo', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDateTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _deadlineController,
                    decoration: _fieldDeco().copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Diagnóstico e solução'),
              const Text(
                'Diagnóstico',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisController,
                maxLines: 3,
                decoration: _fieldDeco(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Solução proposta',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _solutionController,
                maxLines: 3,
                decoration: _fieldDeco(),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Fotos e evidências'),
              if (_photos.isEmpty)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        style: BorderStyle.solid,
                      ), // Ideally dashed, but solid works as fallback
                    ),
                    // Dash decoration trick: using a package for dashed borders or custom painter. We'll stick to solid for simplicity in pure Flutter unless using flutter_dash.
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.red.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicionar fotos',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._photos.map(
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
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.grey,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              _buildSectionTitle('Financeiro'),
              _buildCurrencyField('Mão de obra', _laborCostCtrl),
              const SizedBox(height: 16),
              _buildCurrencyField('Peças e materiais', _partsCostCtrl),
              const SizedBox(height: 16),
              _buildCurrencyField('Desconto', _discountCtrl),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F), // Dark blue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2).format(_totalCost)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Salvar ordem de serviço',
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
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyField(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        SizedBox(
          width: 150,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            decoration: _fieldDeco(),
          ),
        ),
      ],
    );
  }
}
