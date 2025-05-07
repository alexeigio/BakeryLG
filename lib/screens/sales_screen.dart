import 'package:bakery_app/sales_provider.dart';
import 'package:bakery_app/screens/new_sale_screen.dart';
import 'package:bakery_app/screens/sale_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _filter = 'Todos';

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
        title: Text('Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Listado'),
            Tab(text: 'Calendario'),
          ],
        ),
      ),
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
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final sales = provider.sales.where((sale) {
          if (_filter == 'Todos') return true;
          return sale.estado == _filter;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _filter,
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
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sale.estado == 'Pendiente'
                          ? Colors.green
                          : sale.estado == 'Cancelado'
                              ? Colors.red
                              : Colors.grey,
                    ),
                    title: Text(sale.clienteNombre),
                    subtitle: Text('Entrega: ${sale.fechaEntrega}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaleDetailScreen(sale: sale),
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
                    if (sale.estado == 'Pendiente') color = Colors.green;
                    if (sale.estado == 'Cancelado') color = Colors.red;
                    if (sale.estado == 'Completado') color = Colors.grey;
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
                          title: Text('Pedidos del ${selectedDay.toString().split(' ')[0]}'),
                          leading: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              final sale = sales[index];
                              return ListTile(
                                title: Text(sale.clienteNombre),
                                subtitle: Text('Estado: ${sale.estado}'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SaleDetailScreen(sale: sale),
                                    ),
                                  );
                                },
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