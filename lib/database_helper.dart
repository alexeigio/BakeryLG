import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pasteleria.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        contacto TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Inserta categorías predefinidas
    await db.insert('categorias', {'nombre': 'Pasteles'});
    await db.insert('categorias', {'nombre': 'Galletas'});
    await db.insert('categorias', {'nombre': 'Pan'});
    await db.insert('categorias', {'nombre': 'Postres'});
    await db.insert('categorias', {'nombre': 'Postres veganos'});
    // ...puedes agregar más si lo deseas...

    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        categoria_id INTEGER,
        precio REAL NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER,
        fecha_pedido TEXT NOT NULL,
        fecha_entrega TEXT NOT NULL,
        estado TEXT NOT NULL,
        fecha_recordatorio TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE detalle_pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedido_id INTEGER,
        producto_id INTEGER,
        cantidad INTEGER NOT NULL,
        FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
        FOREIGN KEY (producto_id) REFERENCES productos(id)
      )
    ''');
  }

  // Métodos CRUD para clientes
  Future<int> insertCliente(Map<String, dynamic> cliente) async {
    Database db = await database;
    return await db.insert('clientes', cliente);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    Database db = await database;
    return await db.query('clientes');
  }

  Future<int> updateCliente(Map<String, dynamic> cliente) async {
    Database db = await database;
    return await db.update(
      'clientes',
      cliente,
      where: 'id = ?',
      whereArgs: [cliente['id']],
    );
  }

  Future<int> deleteCliente(int id) async {
    Database db = await database;
    return await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para categorías
  Future<int> insertCategoria(Map<String, dynamic> categoria) async {
    Database db = await database;
    return await db.insert('categorias', categoria);
  }

  Future<List<Map<String, dynamic>>> getCategorias() async {
    Database db = await database;
    return await db.query('categorias');
  }

  Future<int> updateCategoria(Map<String, dynamic> categoria) async {
    Database db = await database;
    return await db.update(
      'categorias',
      categoria,
      where: 'id = ?',
      whereArgs: [categoria['id']],
    );
  }

  Future<int> deleteCategoria(int id) async {
    Database db = await database;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para productos
  Future<int> insertProducto(Map<String, dynamic> producto) async {
    Database db = await database;
    return await db.insert('productos', producto);
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    Database db = await database;
    return await db.query('productos');
  }

  Future<int> updateProducto(Map<String, dynamic> producto) async {
    Database db = await database;
    return await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  Future<int> deleteProducto(int id) async {
    Database db = await database;
    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para pedidos
  Future<int> insertPedido(Map<String, dynamic> pedido) async {
    Database db = await database;
    return await db.insert('pedidos', pedido);
  }

  Future<List<Map<String, dynamic>>> getPedidos() async {
    Database db = await database;
    return await db.query('pedidos');
  }

  Future<int> updatePedido(Map<String, dynamic> pedido) async {
    Database db = await database;
    return await db.update(
      'pedidos',
      pedido,
      where: 'id = ?',
      whereArgs: [pedido['id']],
    );
  }

  Future<int> deletePedido(int id) async {
    Database db = await database;
    return await db.delete(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para detalle_pedidos
  Future<int> insertDetallePedido(Map<String, dynamic> detalle) async {
    Database db = await database;
    return await db.insert('detalle_pedidos', detalle);
  }

  Future<List<Map<String, dynamic>>> getDetallesPedido(int pedidoId) async {
    Database db = await database;
    return await db.query(
      'detalle_pedidos',
      where: 'pedido_id = ?',
      whereArgs: [pedidoId],
    );
  }

  Future<int> updateDetallePedido(Map<String, dynamic> detalle) async {
    Database db = await database;
    return await db.update(
      'detalle_pedidos',
      detalle,
      where: 'id = ?',
      whereArgs: [detalle['id']],
    );
  }

  Future<int> deleteDetallePedido(int id) async {
    Database db = await database;
    return await db.delete(
      'detalle_pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}