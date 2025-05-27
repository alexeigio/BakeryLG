import 'package:bakery_app/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Categorías')),
      body: ListView.builder(
        itemCount: productsProvider.categories.length,
        itemBuilder: (context, index) {
          final category = productsProvider.categories[index];
          return ListTile(
            title: Text(category.nombre),
          );
        },
      ),
    );
  }
}