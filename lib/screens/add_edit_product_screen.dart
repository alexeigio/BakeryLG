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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.product == null ? 'Agregar Producto' : 'Editar Producto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Title', // Usa tu fuente personalizada aquí
            fontSize: 35, // Más grande
            letterSpacing: 1.2,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: _nombre,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
                      onSaved: (value) => _nombre = value!,
                    ),
                    SizedBox(height: 18),
                    DropdownButtonFormField<int>(
                      value: _categoriaId,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
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
                    SizedBox(height: 18),
                    TextFormField(
                      initialValue: _precio == 0.0 ? '' : _precio.toString(),
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Ingrese un precio' : null,
                      onSaved: (value) => _precio = double.parse(value!),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final product = {
                              'nombre': _nombre,
                              'categoria_id': _categoriaId,
                              'precio': _precio,
                            };
                            if (widget.product == null) {
                              await productsProvider.addProduct(product);
                            } else {
                              product['id'] = widget.product!['id'];
                              await productsProvider.updateProduct(product);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Guardar'),
                      ),
                    ),
                    if (widget.product != null && widget.product!['id'] != null) ...[
                      SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          label: Text('Eliminar'),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar producto'),
                                content: Text('¿Estás seguro de eliminar este producto?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await productsProvider.deleteProduct(widget.product!['id']);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}