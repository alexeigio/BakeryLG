import 'package:bakery_app/sales_provider.dart';
import 'package:bakery_app/screens/new_sale_screen.dart';
import 'package:bakery_app/screens/sale_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _filter = 'Todos';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Provider.of<SalesProvider>(context, listen: false).fetchSales();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      centerTitle: true, // Centra el título
      title: Text(
        'Pedidos',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Title', // Usa tu fuente personalizada aquí
          fontSize: 35, // Más grande
          letterSpacing: 1.2,
          color: Colors.black87,
    ),
  ),
  elevation: 0,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black87,
  bottom: TabBar(
    controller: _tabController,
    tabs: [
      Tab(text: 'Listado'),
      Tab(text: 'Calendario'),
    ],
  ),
),
      backgroundColor: Color(0xFFF7F7F7),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListView(context),
          _buildCalendarView(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewSaleScreen()),
        ),
        backgroundColor: Colors.black87,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar pedido',
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final sales = provider.sales.where((sale) {
          if (_filter != 'Todos' && sale.estado != _filter) return false;
          if (_searchQuery.isNotEmpty &&
              !sale.clienteNombre.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar por cliente',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: _filter,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filter = value!;
                  });
                },
                items: ['Todos', 'Pendiente', 'Completado', 'Cancelado']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: sales.isEmpty
                  ? Center(
                      child: Text(
                        'No hay pedidos',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: sales.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final sale = sales[index];
                        Color estadoColor;
                        if (sale.estado == 'Pendiente') {
                          estadoColor = Colors.orange[700]!;
                        } else if (sale.estado == 'Completado') {
                          estadoColor = Colors.green;
                        } else if (sale.estado == 'Cancelado') {
                          estadoColor = Colors.red;
                        } else {
                          estadoColor = Colors.grey;
                        }
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            title: Text(
                              sale.clienteNombre,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2),
                                Text(
                                  'Entrega: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(sale.fechaEntrega))}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Estado: ${sale.estado}',
                                  style: TextStyle(
                                    color: estadoColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (sale.detalles.isNotEmpty) ...[
                                  SizedBox(height: 6),
                                  Text(
                                    'Productos:',
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                  ),
                                  ...sale.detalles.map((detalle) => Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 2),
                                    child: Text(
                                      '- ${detalle['nombre_producto'] ?? detalle['producto_id']} x${detalle['cantidad']}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                                    ),
                                  )),
                                ],
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SaleDetailScreen(sale: sale),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          eventLoader: (day) {
            return provider.getSalesForDay(day) ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map<Widget>((event) {
                    final sale = event as Sale;
                    Color color = Colors.black;
                    if (sale.estado == 'Pendiente') color = Colors.orange[700]!;
                    if (sale.estado == 'Cancelado') color = Colors.red;
                    if (sale.estado == 'Completado') color = Colors.green;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      width: 7.0,
                      height: 7.0,
                    );
                  }).toList(),
                );
              }
              return null;
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            showDialog(
              context: context,
              builder: (context) {
                final sales = provider.getSalesForDay(selectedDay) ?? [];
                return Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      children: [
                        AppBar(
                          title: Text('Pedidos del ${DateFormat('dd/MM/yyyy').format(selectedDay)}'),
                          leading: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: sales.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay pedidos para este día',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  itemCount: sales.length,
                                  separatorBuilder: (_, __) => SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final sale = sales[index];
                                    Color estadoColor;
                                    if (sale.estado == 'Pendiente') {
                                      estadoColor = Colors.orange[700]!;
                                    } else if (sale.estado == 'Completado') {
                                      estadoColor = Colors.green;
                                    } else if (sale.estado == 'Cancelado') {
                                      estadoColor = Colors.red;
                                    } else {
                                      estadoColor = Colors.grey;
                                    }
                                    return Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        title: Text(
                                          sale.clienteNombre,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 2),
                                            Text(
                                              'Estado: ${sale.estado}',
                                              style: TextStyle(
                                                color: estadoColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (sale.detalles.isNotEmpty) ...[
                                              SizedBox(height: 6),
                                              Text(
                                                'Productos:',
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                              ),
                                              ...sale.detalles.map((detalle) => Padding(
                                                padding: const EdgeInsets.only(left: 8.0, top: 2),
                                                child: Text(
                                                  '- ${detalle['nombre_producto'] ?? detalle['producto_id']} x${detalle['cantidad']}',
                                                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                                                ),
                                              )),
                                            ],
                                          ],
                                        ),
                                        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SaleDetailScreen(sale: sale),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}