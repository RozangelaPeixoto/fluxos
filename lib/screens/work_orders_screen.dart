import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/work_order.dart';
import 'package:uuid/uuid.dart';
import 'work_order_detail_screen.dart';
import '../models/equipment.dart';
import '../models/technician.dart';
import '../widgets/status_pill.dart';
import '../widgets/work_order_card.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ordens de Serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
            Consumer<AppProvider>(
              builder: (context, provider, _) {
                final activeCount = provider.workOrders.where((os) => os.status != 'Concluída' && os.status != 'Cancelada').length;
                return Text(
                  '$activeCount ordens ativas',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                );
              },
            ),
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
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          var filtered = provider.workOrders.where((os) {
            bool matchesSearch = _searchQuery.isEmpty || 
                os.code.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                (provider.clients.any((c) => c.id == os.clientId && c.name.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.equipments.any((e) => e.id == os.equipmentId && e.type.toLowerCase().contains(_searchQuery.toLowerCase()))) ||
                (provider.technicians.any((t) => t.id == os.technicianId && t.name.toLowerCase().contains(_searchQuery.toLowerCase())));
                
            bool matchesStatus = _selectedStatus == null || os.status == _selectedStatus;
            bool matchesPriority = _selectedPriority == null || os.priority == _selectedPriority;
            
            return matchesSearch && matchesStatus && matchesPriority;
          }).toList();

          filtered.sort((a, b) {
            const priorities = {'Urgente': 0, 'Alta': 1, 'Média': 2, 'Baixa': 3};
            int pA = priorities[a.priority] ?? 4;
            int pB = priorities[b.priority] ?? 4;
            return pA.compareTo(pB);
          });

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nº, cliente, equipamento ou técnico',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdownFilter('Status', ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada'], _selectedStatus, (val) => setState(() => _selectedStatus = val))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdownFilter('Prioridade', ['Baixa', 'Média', 'Alta', 'Urgente'], _selectedPriority, (val) => setState(() => _selectedPriority = val))),
                  ],
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
                    label: const Text('Nova ordem de serviço', style: TextStyle(fontSize: 16)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkOrderFormScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return WorkOrderCard(workOrder: filtered[index]);
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

  Widget _buildDropdownFilter(String hint, List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: [
            DropdownMenuItem<String>(value: null, child: Text('$hint: Todos', style: const TextStyle(fontSize: 14))),
            ...items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))),
          ],
          onChanged: onChanged,
        ),
      ),
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
  late TextEditingController _descriptionCtrl;
  String _priority = 'Média';
  String? _technicianId;
  String _status = 'Aberta';
  late TextEditingController _diagnosisCtrl;
  late TextEditingController _solutionCtrl;
  late TextEditingController _deadlineCtrl;
  late TextEditingController _laborCostCtrl;
  late TextEditingController _partsCostCtrl;
  late TextEditingController _discountCtrl;
  
  double _total = 0.0;
  List<String> _newPhotos = []; 
  List<WorkOrderImage> _existingPhotos = [];

  @override
  void initState() {
    super.initState();
    _clientId = widget.os?.clientId;
    _equipmentId = widget.os?.equipmentId;
    _descriptionCtrl = TextEditingController(text: widget.os?.description ?? '');
    
    _priority = widget.os?.priority ?? 'Média';
    if (!['Baixa', 'Média', 'Alta', 'Urgente'].contains(_priority)) {
      _priority = 'Média';
    }
    _technicianId = widget.os?.technicianId;
    _status = widget.os?.status ?? 'Aberta';
    if (!['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada'].contains(_status)) {
      _status = 'Aberta';
    }
    
    _diagnosisCtrl = TextEditingController(text: widget.os?.diagnosis ?? '');
    _solutionCtrl = TextEditingController(text: widget.os?.solution ?? '');
    _deadlineCtrl = TextEditingController(text: widget.os?.deadline ?? '');
    
    _laborCostCtrl = TextEditingController(text: widget.os?.laborCost.toStringAsFixed(2) ?? '0.00');
    _partsCostCtrl = TextEditingController(text: widget.os?.partsCost.toStringAsFixed(2) ?? '0.00');
    _discountCtrl = TextEditingController(text: '0.00'); // Desconto nÃ£o estÃ¡ no DB nativamente
    
    _laborCostCtrl.addListener(_calcTotal);
    _partsCostCtrl.addListener(_calcTotal);
    _discountCtrl.addListener(_calcTotal);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calcTotal();
      _loadExistingPhotos();
    });
  }
  
  void _loadExistingPhotos() {
    if (widget.os != null) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      setState(() {
        _existingPhotos = provider.workOrderImages.where((i) => i.workOrderId == widget.os!.id).toList();
      });
    }
  }

  void _calcTotal() {
    double labor = double.tryParse(_laborCostCtrl.text.replaceAll(',', '.')) ?? 0;
    double parts = double.tryParse(_partsCostCtrl.text.replaceAll(',', '.')) ?? 0;
    double discount = double.tryParse(_discountCtrl.text.replaceAll(',', '.')) ?? 0;
    setState(() {
      _total = (labor + parts) - discount;
      if (_total < 0) _total = 0;
    });
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _diagnosisCtrl.dispose();
    _solutionCtrl.dispose();
    _deadlineCtrl.dispose();
    _laborCostCtrl.dispose();
    _partsCostCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now().subtract(const Duration(days: 365)), 
      lastDate: DateTime.now().add(const Duration(days: 365 * 5))
    );
    if (date != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setState(() {
          _deadlineCtrl.text = DateFormat('dd/MM/yyyy HH:mm').format(dt);
        });
      }
    }
  }

  Future<void> _pickFiles() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      final uploadDir = Directory('${appDir.path}/FluxOS_Uploads');
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }
      
      for (var file in images) {
        final ext = file.path.split('.').last;
        final newPath = '${uploadDir.path}/${const Uuid().v4()}.$ext';
        final savedFile = await File(file.path).copy(newPath);
        setState(() {
          _newPhotos.add(savedFile.path);
        });
      }
    }
  }
  
  bool _validateStatusTransition() {
    if (_status == 'Cancelada') return true;
    
    if (_status == 'Em atendimento' && _technicianId == null) {
      _showError('O status \'Em atendimento\' exige um técnico responsável.');
      return false;
    }
    if (_status == 'Aguardando peça' && _diagnosisCtrl.text.trim().isEmpty) {
      _showError('O status \'Aguardando peça\' exige um diagnóstico preenchido.');
      return false;
    }
    if (_status == 'Concluída' && _solutionCtrl.text.trim().isEmpty) {
      _showError('O status \'Concluída\' exige uma solução proposta.');
      return false;
    }
    return true;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _saveOs() async {
    if (_formKey.currentState!.validate()) {
      if (!_validateStatusTransition()) return;
      
      final provider = Provider.of<AppProvider>(context, listen: false);
      final osId = widget.os?.id ?? const Uuid().v4();
      
      double labor = double.tryParse(_laborCostCtrl.text.replaceAll(',', '.')) ?? 0;
      double parts = double.tryParse(_partsCostCtrl.text.replaceAll(',', '.')) ?? 0;

      final newOs = WorkOrder(
        id: osId,
        code: widget.os?.code ?? 'OS-',
        clientId: _clientId!,
        equipmentId: _equipmentId!,
        description: _descriptionCtrl.text.trim(),
        priority: _priority,
        technicianId: _technicianId,
        openDate: widget.os?.openDate ?? DateTime.now().toIso8601String(),
        deadline: _deadlineCtrl.text.trim(),
        status: _status,
        diagnosis: _diagnosisCtrl.text.trim(),
        solution: _solutionCtrl.text.trim(),
        laborCost: labor,
        partsCost: parts,
        totalCost: _total,
      );
      
      provider.saveWorkOrder(newOs);
      
      for (String path in _newPhotos) {
        final img = WorkOrderImage(
          id: const Uuid().v4(),
          workOrderId: osId,
          imagePath: path,
        );
        await provider.saveWorkOrderImage(img);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    List<Equipment> equipmentsForClient = _clientId == null ? [] : provider.equipments.where((e) => e.clientId == _clientId).toList();
    List<Technician> activeTechs = provider.technicians.where((t) => t.isActive == 1).toList();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.os == null ? 'Nova ordem de serviço' : 'Editar ordem de serviço', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
            const Text('Preencha os dados do atendimento', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cliente e equipamento', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildLabel('Cliente'),
              DropdownButtonFormField<String>(
                value: _clientId,
                decoration: _fieldDeco(),
                items: provider.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() { _clientId = val; _equipmentId = null; }),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              _buildLabel('Equipamento'),
              DropdownButtonFormField<String>(
                value: _equipmentId,
                decoration: _fieldDeco(),
                items: equipmentsForClient.map((e) => DropdownMenuItem(value: e.id, child: Text(' - '))).toList(),
                onChanged: (val) => setState(() => _equipmentId = val),
                validator: (val) => val == null ? 'Obrigatório' : null,
              ),
              
              const SizedBox(height: 24),
              const Text('Problema e prioridade', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildLabel('Problema relatado'),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: _fieldDeco(),
                validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              _buildLabel('Prioridade'),
              Wrap(
                spacing: 8,
                children: ['Baixa', 'Média', 'Alta', 'Urgente'].map((p) {
                  final isSelected = _priority == p;
                  Color chipColor;
                  switch (p) {
                    case 'Baixa': chipColor = Colors.green; break;
                    case 'Alta': chipColor = Colors.orange; break;
                    case 'Urgente': chipColor = Colors.red; break;
                    default: chipColor = Colors.blue; break;
                  }
                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    onSelected: (val) { if(val) setState(() => _priority = p); },
                    selectedColor: isSelected ? chipColor : Colors.grey.shade200,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              const Text('Atendimento', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildLabel('Técnico responsável'),
              DropdownButtonFormField<String>(
                value: _technicianId,
                decoration: _fieldDeco(),
                items: activeTechs.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _technicianId = val),
              ),
              const SizedBox(height: 12),
              _buildLabel('Prazo'),
              TextFormField(
                controller: _deadlineCtrl,
                readOnly: true,
                onTap: _pickDateTime,
                decoration: _fieldDeco().copyWith(
                  suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              _buildLabel('Status'),
              Wrap(
                spacing: 8,
                children: ['Aberta', 'Atribuída', 'Em atendimento', 'Aguardando peça', 'Concluída', 'Cancelada'].map((s) {
                  final isSelected = _status == s;
                  Color chipColor;
                  if (s == 'Concluída') chipColor = Colors.green;
                  else if (s == 'Cancelada') chipColor = Colors.red.shade100;
                  else if (s == 'Aberta' || s == 'Atribuída') chipColor = Colors.blue.shade100;
                  else if (s == 'Em atendimento') chipColor = Colors.red;
                  else chipColor = Colors.orange.shade100;
                  
                  return ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (val) { if(val) setState(() => _status = s); },
                    selectedColor: chipColor,
                    labelStyle: TextStyle(
                      color: isSelected && s == 'Em atendimento' ? Colors.white : (isSelected ? Colors.black87 : Colors.black87)
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              const Text('Diagnóstico e solução', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildLabel('Diagnóstico'),
              TextFormField(
                controller: _diagnosisCtrl,
                maxLines: 3,
                decoration: _fieldDeco(),
              ),
              const SizedBox(height: 12),
              _buildLabel('Solução proposta'),
              TextFormField(
                controller: _solutionCtrl,
                maxLines: 3,
                decoration: _fieldDeco(),
              ),

              const SizedBox(height: 24),
              const Text('Fotos e evidências', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.red.shade400, size: 32),
                      const SizedBox(height: 8),
                      Text('Adicionar fotos', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_existingPhotos.isNotEmpty || _newPhotos.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._existingPhotos.map((i) => _buildPhotoThumb(i.imagePath, () {
                        provider.deleteWorkOrderImage(i.id, i.workOrderId);
                        setState(() { _existingPhotos.remove(i); });
                      })),
                      ..._newPhotos.map((p) => _buildPhotoThumb(p, () {
                        setState(() { _newPhotos.remove(p); });
                      })),
                    ],
                  ),
                ),

              const SizedBox(height: 24),
              const Text('Financeiro', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mão de obra', style: TextStyle(color: Colors.black54)),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _laborCostCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: _fieldDeco(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Peças e materiais', style: TextStyle(color: Colors.black54)),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _partsCostCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: _fieldDeco(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Desconto', style: TextStyle(color: Colors.black54)),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _discountCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: _fieldDeco(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('R\$ ', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveOs,
                  child: const Text('Salvar ordem de serviço', style: TextStyle(fontSize: 16)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
    );
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
  
  Widget _buildPhotoThumb(String path, VoidCallback onRemove) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
