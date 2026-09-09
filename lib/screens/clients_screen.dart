import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/client.dart';
import 'package:uuid/uuid.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.clients.isEmpty) {
            return const Center(child: Text('Nenhum cliente cadastrado.'));
          }
          return ListView.builder(
            itemCount: provider.clients.length,
            itemBuilder: (context, index) {
              final client = provider.clients[index];
              return ListTile(
                title: Text(client.name),
                subtitle: Text(client.document),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteClient(client.id),
                ),
                onTap: () => _showForm(context, client),
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

  void _showForm(BuildContext context, Client? client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ClientForm(client: client),
    );
  }
}

class ClientForm extends StatefulWidget {
  final Client? client;
  const ClientForm({super.key, this.client});

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _document;
  late String _phone;
  late String _email;
  late String _address;

  @override
  void initState() {
    super.initState();
    _name = widget.client?.name ?? '';
    _document = widget.client?.document ?? '';
    _phone = widget.client?.phone ?? '';
    _email = widget.client?.email ?? '';
    _address = widget.client?.address ?? '';
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
            Text(widget.client == null ? 'Novo Cliente' : 'Editar Cliente', style: const TextStyle(fontSize: 20)),
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              onSaved: (val) => _name = val ?? '',
              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
            ),
            TextFormField(
              initialValue: _document,
              decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
              onSaved: (val) => _document = val ?? '',
            ),
            TextFormField(
              initialValue: _phone,
              decoration: const InputDecoration(labelText: 'Telefone'),
              onSaved: (val) => _phone = val ?? '',
            ),
            TextFormField(
              initialValue: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              onSaved: (val) => _email = val ?? '',
            ),
            TextFormField(
              initialValue: _address,
              decoration: const InputDecoration(labelText: 'Endereço'),
              onSaved: (val) => _address = val ?? '',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newClient = Client(
                    id: widget.client?.id ?? const Uuid().v4(),
                    name: _name,
                    document: _document,
                    phone: _phone,
                    email: _email,
                    address: _address,
                  );
                  Provider.of<AppProvider>(context, listen: false).saveClient(newClient);
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
