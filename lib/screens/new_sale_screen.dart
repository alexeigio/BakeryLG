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
        title: Text('Nuevo Pedido'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: custom_badge.Badge(
              badgeContent: Text(
                _selectedProducts.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<int>(
              value: _selectedClientId,
              hint: Text('Seleccionar cliente'),
              isExpanded: true,
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
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditClientScreen()),
              ),
              child: Text('Agregar nuevo cliente'),
            ),
            SizedBox(height: 16),
            Text('Productos', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<int>(
              value: _selectedCategoryId,
              hint: Text('Seleccionar categoría'),
              isExpanded: true,
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
                itemCount: productsProvider
                    .getProductsByCategory(_selectedCategoryId!)
                    .length,
                itemBuilder: (context, index) {
                  final product = productsProvider
                      .getProductsByCategory(_selectedCategoryId!)[index];
                  return ListTile(
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
                  );
                },
              ),
            SizedBox(height: 16),
            Text('Productos seleccionados',
                style: Theme.of(context).textTheme.titleMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _selectedProducts.length,
              itemBuilder: (context, index) {
                final product = _selectedProducts[index];
                return ListTile(
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
                );
              },
            ),
            SizedBox(height: 16),
            Text('Fecha de entrega', style: Theme.of(context).textTheme.titleMedium),
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
            SizedBox(height: 16),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}