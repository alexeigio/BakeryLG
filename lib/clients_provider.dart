import 'package:bakery_app/database_helper.dart';
import 'package:flutter/foundation.dart';


class Client {
  final int id;
  final String nombre;
  final String? contacto;

  Client({
    required this.id,
    required this.nombre,
    this.contacto,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nombre: map['nombre'],
      contacto: map['contacto'],
    );
  }
}

class ClientsProvider with ChangeNotifier {
  List<Client> _clients = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Client> get clients => _clients;

  Future<void> fetchClients() async {
    final db = await _dbHelper.database;
    final clientsMaps = await db.query('clientes');
    _clients = clientsMaps.map((map) => Client.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addClient(Map<String, dynamic> client) async {
    await _dbHelper.insertCliente(client);
    await fetchClients();
  }

  Future<void> updateClient(Map<String, dynamic> client) async {
    final db = await _dbHelper.database;
    await db.update(
      'clientes',
      client,
      where: 'id = ?',
      whereArgs: [client['id']],
    );
    await fetchClients();
  }

  Future<void> deleteClient(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchClients();
  }
}