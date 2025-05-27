import 'package:bakery_app/clients_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditClientScreen extends StatefulWidget {
  final Map<String, dynamic>? client;

  AddEditClientScreen({this.client});

  @override
  _AddEditClientScreenState createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _contactoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nombreController.text = widget.client!['nombre'];
      _contactoController.text = widget.client!['contacto'] ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Agregar Cliente' : 'Editar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _contactoController,
                decoration: InputDecoration(labelText: 'Contacto (opcional)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nombre = _nombreController.text.trim();
                    final contacto = _contactoController.text.trim();

                    final clientMap = {
                      'nombre': nombre,
                      'contacto': contacto.isEmpty ? null : contacto,
                    };

                    if (widget.client != null && widget.client!['id'] != null) {
                      // Es edición
                      clientMap['id'] = widget.client!['id'];
                      await Provider.of<ClientsProvider>(context, listen: false)
                          .updateClient(clientMap);
                    } else {
                      // Es alta nueva
                      await Provider.of<ClientsProvider>(context, listen: false)
                          .addClient(clientMap);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text('Guardar'),
              ),
              if (widget.client != null && widget.client!['id'] != null) ...[
                SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  icon: Icon(Icons.delete),
                  label: Text('Eliminar'),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Eliminar cliente'),
                        content: Text('¿Estás seguro de eliminar este cliente?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await Provider.of<ClientsProvider>(context, listen: false)
                          .deleteClient(widget.client!['id']);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}