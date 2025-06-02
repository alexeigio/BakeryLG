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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Clientes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Title', // Usa tu fuente personalizada aquí
            fontSize: 35, // Más grande
            letterSpacing: 1.2,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar cliente',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredClients.isEmpty
                ? Center(
                    child: Text(
                      'No hay clientes',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredClients.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            client.nombre,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: client.contacto != null && client.contacto!.isNotEmpty
                              ? Text(client.contacto!, style: TextStyle(color: Colors.grey[700]))
                              : Text('Sin contacto', style: TextStyle(color: Colors.grey[400])),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
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
                            Provider.of<ClientsProvider>(context, listen: false).fetchClients();
                          },
                        ),
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
        backgroundColor: Colors.black87,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar cliente',
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}