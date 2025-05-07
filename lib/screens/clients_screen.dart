import 'package:bakery_app/clients_provider.dart';
import 'package:bakery_app/screens/add_edit_client_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientsScreen extends StatefulWidget {
  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar clientes al iniciar la pantalla
    Future.microtask(() =>
      Provider.of<ClientsProvider>(context, listen: false).fetchClients()
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientsProvider>(context);
    final filteredClients = clientsProvider.clients.where((client) {
      final nameLower = client.nombre.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Clientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(labelText: 'Buscar cliente'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                return ListTile(
                  title: Text(client.nombre),
                  subtitle: Text(client.contacto ?? 'Sin contacto'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditClientScreen(
                          client: {
                            'id': client.id,
                            'nombre': client.nombre,
                            'contacto': client.contacto,
                          },
                        ),
                      ),
                    );
                    // Recarga la lista después de editar
                    Provider.of<ClientsProvider>(context, listen: false).fetchClients();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEditClientScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}