
import 'package:bakery_app/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  AddEditProductScreen({this.product});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  int? _categoriaId;
  double _precio = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nombre = widget.product!['nombre'];
      _categoriaId = widget.product!['categoria_id'];
      _precio = widget.product!['precio'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Agregar Producto' : 'Editar Producto')),
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
              DropdownButtonFormField<int>(
                value: _categoriaId,
                decoration: InputDecoration(labelText: 'Categoría'),
                items: productsProvider.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaId = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              TextFormField(
                initialValue: _precio.toString(),
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                onSaved: (value) => _precio = double.parse(value!),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final product = {
                      'nombre': _nombre,
                      'categoria_id': _categoriaId,
                      'precio': _precio,
                    };
                    if (widget.product == null) {
                      productsProvider.addProduct(product);
                    } else {
                      product['id'] = widget.product!['id'];
                      productsProvider.updateProduct(product);
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