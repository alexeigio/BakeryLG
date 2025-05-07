import 'package:bakery_app/sales_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final pendingSales = salesProvider.sales.where((sale) => sale.estado == 'Pendiente').length;
    final upcomingSales = salesProvider.sales.where((sale) {
      final deliveryDate = DateTime.parse(sale.fechaEntrega);
      return deliveryDate.isAfter(DateTime.now()) && deliveryDate.isBefore(DateTime.now().add(Duration(days: 7)));
    }).length;

    return Scaffold(
      appBar: AppBar(title: Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: ListTile(
                title: Text('Pedidos pendientes'),
                subtitle: Text('$pendingSales'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Pedidos en los próximos 7 días'),
                subtitle: Text('$upcomingSales'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}