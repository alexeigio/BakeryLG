import 'package:bakery_app/products_provider.dart';
import 'package:bakery_app/screens/add_edit_product_screen.dart';
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
      appBar: AppBar(
        title: Text('Productos', style: TextStyle(fontWeight: FontWeight.w600)),
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
                hintText: 'Buscar producto',
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
            child: filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'No hay productos',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            product.nombre,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Categoría: ${product.categoriaNombre}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${product.precio.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Icon(Icons.chevron_right, color: Colors.grey[400]),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
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
                            Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProduct',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEditProductScreen()),
        ),
        backgroundColor: Colors.black87,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar Producto',
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}