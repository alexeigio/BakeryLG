import 'package:bakery_app/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Sale {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final String fechaPedido;
  final String fechaEntrega;
  final String estado;
  final String fechaRecordatorio;
  final List<Map<String, dynamic>> detalles;

  Sale({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.fechaPedido,
    required this.fechaEntrega,
    required this.estado,
    required this.fechaRecordatorio,
    required this.detalles,
  });

  factory Sale.fromMap(Map<String, dynamic> map, List<Map<String, dynamic>> detalles) {
    return Sale(
      id: map['id'],
      clienteId: map['cliente_id'],
      clienteNombre: map['cliente_nombre'],
      fechaPedido: map['fecha_pedido'],
      fechaEntrega: map['fecha_entrega'],
      estado: map['estado'],
      fechaRecordatorio: map['fecha_recordatorio'],
      detalles: detalles,
    );
  }
}

class SalesProvider with ChangeNotifier {
  List<Sale> _sales = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Sale> get sales => _sales;

  Future<void> fetchSales() async {
    final db = await _dbHelper.database;
    final salesMaps = await db.rawQuery('''
      SELECT p.*, c.nombre as cliente_nombre 
      FROM pedidos p 
      JOIN clientes c ON p.cliente_id = c.id
    ''');
    final detallesMaps = await db.query('detalle_pedidos');

    _sales = salesMaps.map((saleMap) {
      final detalles = detallesMaps
          .where((detalle) => detalle['pedido_id'] == saleMap['id'])
          .toList();
      return Sale.fromMap(saleMap, detalles);
    }).toList();

    notifyListeners();
  }

  Future<void> addSale(Map<String, dynamic> sale, List<Map<String, dynamic>> detalles) async {
    final db = await _dbHelper.database;
    final saleId = await db.insert('pedidos', sale);
    for (var detalle in detalles) {
      await db.insert('detalle_pedidos', {
        'pedido_id': saleId,
        'producto_id': detalle['producto_id'],
        'cantidad': detalle['cantidad'],
      });
    }
    // TODO: Programar notificación local para fecha_recordatorio
    await fetchSales();
  }

  Future<void> updateSaleStatus(int saleId, String newStatus) async {
    final db = await _dbHelper.database;
    await db.update(
      'pedidos',
      {'estado': newStatus},
      where: 'id = ?',
      whereArgs: [saleId],
    );
    await fetchSales();
  }

  List<Sale> getSalesForDay(DateTime day) {
    final formattedDay = DateFormat('yyyy-MM-dd').format(day);
    return _sales.where((sale) => sale.fechaEntrega == formattedDay).toList();
  }
}