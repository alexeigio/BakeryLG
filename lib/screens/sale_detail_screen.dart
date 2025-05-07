import 'package:bakery_app/sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SaleDetailScreen extends StatefulWidget {
  final Sale sale;

  SaleDetailScreen({required this.sale});

  @override
  _SaleDetailScreenState createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.sale.estado;
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Detalles del Pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${widget.sale.clienteNombre}', style: TextStyle(fontSize: 18)),
            Text('Fecha de entrega: ${widget.sale.fechaEntrega}', style: TextStyle(fontSize: 16)),
            Text('Estado:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  await salesProvider.updateSaleStatus(widget.sale.id, value);
                }
              },
              items: ['Pendiente', 'Completado', 'Cancelado'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text('Productos:', style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.sale.detalles.length,
                itemBuilder: (context, index) {
                  final detalle = widget.sale.detalles[index];
                  return ListTile(
                    title: Text(detalle['nombre'] ?? 'Producto'),
                    subtitle: Text('Cantidad: ${detalle['cantidad']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}