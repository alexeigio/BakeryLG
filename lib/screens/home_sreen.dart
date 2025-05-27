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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Inicio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Color(0xFFF7F7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeStatCard(
              icon: Icons.pending_actions,
              iconColor: Colors.orange[700]!,
              title: 'Pedidos pendientes',
              value: pendingSales,
              color: Colors.orange[50]!,
            ),
            SizedBox(height: 28),
            _HomeStatCard(
              icon: Icons.calendar_today,
              iconColor: Colors.blue[700]!,
              title: 'Próximos 7 días',
              value: upcomingSales,
              color: Colors.blue[50]!,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final Color color;

  const _HomeStatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconColor.withOpacity(0.13),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 6),
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}