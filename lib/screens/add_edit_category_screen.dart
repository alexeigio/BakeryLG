import 'package:bakery_app/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  AddEditCategoryScreen({this.category});

  @override
  _AddEditCategoryScreenState createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nombre = widget.category!['nombre'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category == null ? 'Agregar Categoría' : 'Editar Categoría')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _nombre,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                onSaved: (value) => _nombre = value!,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final category = {'nombre': _nombre};
                    if (widget.category == null) {
                      productsProvider.addCategory(category);
                    } else {
                      category['id'] = widget.category!['id'];
                      productsProvider.updateCategory(category);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}