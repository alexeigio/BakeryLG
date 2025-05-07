import 'package:bakery_app/products_provider.dart';
import 'package:bakery_app/screens/add_edit_category_screen.dart';
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCategoryScreen(category: {
                    'id': category.id,
                    'nombre': category.nombre,
                  }),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await productsProvider.deleteCategory(category.id);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddEditCategoryScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}