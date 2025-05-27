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
      appBar: AppBar(
        title: Text(widget.client == null ? 'Agregar Cliente' : 'Editar Cliente'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                    ),
                    SizedBox(height: 18),
                    TextFormField(
                      controller: _contactoController,
                      decoration: InputDecoration(
                        labelText: 'Contacto (opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final nombre = _nombreController.text.trim();
                            final contacto = _contactoController.text.trim();

                            final clientMap = {
                              'nombre': nombre,
                              'contacto': contacto.isEmpty ? null : contacto,
                            };

                            if (widget.client != null && widget.client!['id'] != null) {
                              clientMap['id'] = widget.client!['id'];
                              await Provider.of<ClientsProvider>(context, listen: false)
                                  .updateClient(clientMap);
                            } else {
                              await Provider.of<ClientsProvider>(context, listen: false)
                                  .addClient(clientMap);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Guardar'),
                      ),
                    ),
                    if (widget.client != null && widget.client!['id'] != null) ...[
                      SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}