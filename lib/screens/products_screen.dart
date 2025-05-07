import 'package:bakery_app/products_provider.dart';
import 'package:bakery_app/screens/add_edit_product_screen.dart';
import 'package:bakery_app/screens/add_edit_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.fetchCategories();
      productsProvider.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final filteredProducts = productsProvider.products.where((product) {
      final nameLower = product.nombre.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
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
              decoration: InputDecoration(labelText: 'Buscar producto'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product.nombre),
                  subtitle: Text('Categoría: ${product.categoriaNombre}'),
                  trailing: Text('\$${product.precio}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditProductScreen(product: {
                          'id': product.id,
                          'nombre': product.nombre,
                          'categoria_id': product.categoriaId,
                          'categoria_nombre': product.categoriaNombre,
                          'precio': product.precio,
                        }),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addProduct',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditProductScreen()),
            ),
            child: Icon(Icons.add),
            tooltip: 'Agregar Producto',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'manageCategories',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditCategoryScreen()),
            ),
            child: Icon(Icons.category),
            tooltip: 'Gestionar Categorías',
          ),
        ],
      ),
    );
  }
}