import 'package:bakery_app/clients_provider.dart';
import 'package:bakery_app/products_provider.dart';
import 'package:bakery_app/sales_provider.dart';
import 'package:bakery_app/screens/add_edit_client_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as custom_badge;

class NewSaleScreen extends StatefulWidget {
  @override
  _NewSaleScreenState createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  int? _selectedClientId;
  int? _selectedCategoryId;
  DateTime? _deliveryDate;
  final List<Map<String, dynamic>> _selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientsProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final salesProvider = Provider.of<SalesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Nuevo Pedido',
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: custom_badge.Badge(
              badgeContent: Text(
                _selectedProducts.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.shopping_cart, color: Colors.black87),
            ),
          ),
        ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedClientId,
                    hint: Text('Seleccionar cliente'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: clientsProvider.clients.map((client) {
                      return DropdownMenuItem<int>(
                        value: client.id,
                        child: Text(client.nombre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEditClientScreen()),
                      ),
                      child: Text('Agregar nuevo cliente'),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text('Productos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    hint: Text('Seleccionar categoría'),
                    decoration: InputDecoration(
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
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  if (_selectedCategoryId != null)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: productsProvider.getProductsByCategory(_selectedCategoryId!).length,
                      itemBuilder: (context, index) {
                        final product = productsProvider.getProductsByCategory(_selectedCategoryId!)[index];
                        return Card(
                          color: Colors.grey[50],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(product.nombre),
                            subtitle: Text('\$${product.precio}'),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  final existing = _selectedProducts.indexWhere((p) => p['producto_id'] == product.id);
                                  if (existing != -1) {
                                    _selectedProducts[existing]['cantidad']++;
                                  } else {
                                    _selectedProducts.add({
                                      'producto_id': product.id,
                                      'nombre': product.nombre,
                                      'precio': product.precio,
                                      'cantidad': 1,
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 18),
                  Text('Productos seleccionados', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _selectedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _selectedProducts[index];
                      return Card(
                        color: Colors.grey[50],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(product['nombre']),
                          subtitle: Text('Cantidad: ${product['cantidad']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (product['cantidad'] > 1) {
                                      product['cantidad']--;
                                    } else {
                                      _selectedProducts.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    product['cantidad']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 18),
                  Text('Fecha de entrega', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _deliveryDate = picked;
                        });
                      }
                    },
                    child: Text(_deliveryDate == null
                        ? 'Seleccionar fecha'
                        : DateFormat('yyyy-MM-dd').format(_deliveryDate!)),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: _selectedClientId != null &&
                              _selectedProducts.isNotEmpty &&
                              _deliveryDate != null
                          ? () {
                              final sale = {
                                'cliente_id': _selectedClientId,
                                'fecha_pedido': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                'fecha_entrega': DateFormat('yyyy-MM-dd').format(_deliveryDate!),
                                'estado': 'Pendiente',
                                'fecha_recordatorio': DateFormat('yyyy-MM-dd').format(
                                    _deliveryDate!.subtract(Duration(days: 2))),
                              };
                              salesProvider.addSale(sale, _selectedProducts);
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text('Guardar pedido'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}