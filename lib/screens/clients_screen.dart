import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/client.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'client_detail_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Clientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
            Consumer<AppProvider>(
              builder: (context, provider, _) => Text(
                '${provider.clients.length} clientes cadastrados',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
          var filtered = provider.clients.where((c) {
            return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                   c.document.contains(_searchQuery) ||
                   c.phone.contains(_searchQuery);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, documento ou telefone',
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
                    label: const Text('Cadastrar cliente'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientFormScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final client = filtered[index];
                      final osCount = provider.workOrders.where((o) => o.clientId == client.id).length;
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client))),
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
                                child: Text(client.name.substring(0, 2).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(client.document.replaceAll(RegExp(r'[^0-9]'), '').length > 11 ? 'Pessoa Jurídica' : 'Pessoa Física', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('$osCount OS', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                              )
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

class ClientFormScreen extends StatefulWidget {
  final Client? client;
  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _document, _phone, _email, _address, _city, _uf, _cep;
  late String _clientType;
  
  final phoneMask = MaskTextInputFormatter(mask: '(##) #####-####', filter: { "#": RegExp(r'[0-9]') });
  final cepMask = MaskTextInputFormatter(mask: '#####-###', filter: { "#": RegExp(r'[0-9]') });
  late MaskTextInputFormatter docMask;

  @override
  void initState() {
    super.initState();
    _name = widget.client?.name ?? '';
    _document = widget.client?.document ?? '';
    _phone = widget.client?.phone ?? '';
    _email = widget.client?.email ?? '';
    _address = widget.client?.address ?? '';
    _city = '';
    _uf = '';
    _cep = '';

    _clientType = widget.client != null ? (widget.client!.document.replaceAll(RegExp(r'[^0-9]'), '').length > 11 ? 'Pessoa jurídica' : 'Pessoa física') : 'Pessoa jurídica';
    
    docMask = MaskTextInputFormatter(
      mask: _clientType == 'Pessoa jurídica' ? '##.###.###/####-##' : '###.###.###-##', 
      filter: { "#": RegExp(r'[0-9]') },
      initialText: _document,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.client == null ? 'Cadastrar cliente' : 'Editar cliente', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 22)),
            const Text('Dados de contato e endereço', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
              const Text('Identificação', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              const Text('Tipo', style: TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _clientType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                items: ['Pessoa jurídica', 'Pessoa física'].map<DropdownMenuItem<String>>((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _clientType = val;
                      docMask.updateMask(mask: _clientType == 'Pessoa jurídica' ? '##.###.###/####-##' : '###.###.###-##');
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildField('Nome / Razão social', _name, (val) => _name = val, true),
              _buildField('CPF / CNPJ', _document, (val) => _document = val, true,
                  inputFormatters: [docMask], keyboardType: TextInputType.number),
              
              const SizedBox(height: 16),
              const Text('Contato', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildField('Telefone', _phone, (val) => _phone = val, true,
                  inputFormatters: [phoneMask], keyboardType: TextInputType.phone),
              _buildField('E-mail', _email, (val) => _email = val, true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Obrigatório';
                    if (!val.contains('@')) return 'E-mail inválido';
                    return null;
                  }),
              
              const SizedBox(height: 16),
              const Text('Endereço', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildField('CEP', _cep, (val) => _cep = val, true,
                  inputFormatters: [cepMask], keyboardType: TextInputType.number),
              _buildField('Rua e número', _address, (val) => _address = val, true),
              Row(
                children: [
                  Expanded(flex: 3, child: _buildField('Cidade', _city, (val) => _city = val, true)),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _buildField('UF', _uf, (val) => _uf = val, true)),
                ],
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
                  final provider = Provider.of<AppProvider>(context, listen: false);
                  
                  bool isDuplicate = provider.clients.any((c) => c.document == _document && c.id != widget.client?.id);
                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Já existe um cliente cadastrado com este CPF/CNPJ.'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  String finalAddress = _address;
                  if (_city.isNotEmpty || _uf.isNotEmpty) {
                    finalAddress += ' - $_city/$_uf';
                  }

                  final newClient = Client(
                    id: widget.client?.id ?? const Uuid().v4(),
                    name: _name,
                    document: _document,
                    phone: _phone,
                    email: _email,
                    address: finalAddress,
                    createdAt: widget.client?.createdAt ?? DateTime.now().toIso8601String(),
                  );
                  provider.saveClient(newClient);
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar cliente', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String initialValue, Function(String) onSaved, bool isRequired, {List<TextInputFormatter>? inputFormatters, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 8),
          ],
          TextFormField(
            initialValue: initialValue,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
            onSaved: (val) => onSaved(val ?? ''),
            validator: validator ?? (val) => (isRequired && (val == null || val.isEmpty)) ? 'Obrigatório' : null,
          ),
        ],
      ),
    );
  }
}
