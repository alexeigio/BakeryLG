import 'package:bakery_app/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class Category {
  final int id;
  final String nombre;

  Category({
    required this.id,
    required this.nombre,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}

class Product {
  final int id;
  final String nombre;
  final int categoriaId;
  final String categoriaNombre;
  final double precio;

  Product({
    required this.id,
    required this.nombre,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.precio,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nombre: map['nombre'],
      categoriaId: map['categoria_id'],
      categoriaNombre: map['categoria_nombre'],
      precio: map['precio'],
    );
  }
}

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Product> get products => _products;
  List<Category> get categories => _categories;

  Future<void> fetchProducts() async {
    final db = await _dbHelper.database;
    final productsMaps = await db.rawQuery('''
      SELECT p.*, c.nombre as categoria_nombre 
      FROM productos p 
      JOIN categorias c ON p.categoria_id = c.id
    ''');
    _products = productsMaps.map((map) => Product.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final db = await _dbHelper.database;
    final categoriesMaps = await db.query('categorias');
    _categories = categoriesMaps.map((map) => Category.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    await db.insert('productos', product);
    await fetchProducts();
  }

  Future<void> updateProduct(Map<String, dynamic> product) async {
    final db = await _dbHelper.database;
    await db.update(
      'productos',
      product,
      where: 'id = ?',
      whereArgs: [product['id']],
    );
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchProducts();
  }

  Future<void> addCategory(Map<String, dynamic> category) async {
    final db = await _dbHelper.database;
    await db.insert('categorias', category);
    await fetchCategories();
  }

  Future<void> updateCategory(Map<String, dynamic> category) async {
    final db = await _dbHelper.database;
    await db.update(
      'categorias',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
    await fetchCategories();
  }

  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    final productsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM productos WHERE categoria_id = ?',
      [id],
    ));
    if (productsCount == 0) {
      await db.delete(
        'categorias',
        where: 'id = ?',
        whereArgs: [id],
      );
      await fetchCategories();
    } else {
      throw Exception('No se puede eliminar una categoría con productos asociados');
    }
  }

  List<Product> getProductsByCategory(int categoryId) {
    return _products.where((product) => product.categoriaId == categoryId).toList();
  }
}