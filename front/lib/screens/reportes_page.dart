import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/venta.dart';
import '../models/producto.dart';
import 'package:url_launcher/url_launcher.dart';

enum _PeriodoReporte { all, ultimos7, ultimos30 }

class _ReportesData {
  final List<Venta> ventas;
  final List<Producto> productos;

  _ReportesData({required this.ventas, required this.productos});
}

class _ProductoBajaRotacion {
  final String nombre;
  final String categoria;
  final int stock;
  final int vendido;

  _ProductoBajaRotacion({
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.vendido,
  });
}

class _CategoriaReporte {
  final String categoria;
  final double total;
  final int cantidad;

  _CategoriaReporte({
    required this.categoria,
    required this.total,
    required this.cantidad,
  });
}

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});
  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  late Future<_ReportesData> _futureReportes;
  _PeriodoReporte _periodoSeleccionado = _PeriodoReporte.all;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureReportes =
          Future.wait([
            ApiService.obtenerHistorial(),
            ApiService.obtenerProductos(),
          ]).then(
            (listas) => _ReportesData(
              ventas: listas[0] as List<Venta>,
              productos: listas[1] as List<Producto>,
            ),
          );
    });
  }

  Future<void> _exportar() async {
    final url = Uri.parse(ApiService.getExportUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir la descarga")),
        );
      }
    }
  }

  List<Venta> _filtrarPorPeriodo(List<Venta> ventas, _PeriodoReporte periodo) {
    if (periodo == _PeriodoReporte.all) return ventas;
    final ahora = DateTime.now();
    final desde = ahora.subtract(
      Duration(days: periodo == _PeriodoReporte.ultimos7 ? 7 : 30),
    );
    return ventas.where((v) => v.fecha.isAfter(desde)).toList();
  }

  String _textoPeriodo(_PeriodoReporte periodo) {
    switch (periodo) {
      case _PeriodoReporte.ultimos7:
        return 'Últimos 7 días';
      case _PeriodoReporte.ultimos30:
        return 'Últimos 30 días';
      default:
        return 'Todo el período';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                "Analítica de Reportes",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _exportar,
                icon: const Icon(Icons.download_outlined),
                label: const Text("Exportar CSV"),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: "Recargar",
                icon: const Icon(Icons.refresh),
                onPressed: _cargar,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<_ReportesData>(
            future: _futureReportes,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text("Error: ${snap.error}"));
              }
              final data = snap.data!;
              final ventas = data.ventas;
              final productos = data.productos;
              final ventasPeriod = _filtrarPorPeriodo(
                ventas,
                _periodoSeleccionado,
              );
              final totalGeneral = ventas.fold(0.0, (s, v) => s + v.total);
              final topProductos = _calcularTopProductos(ventas);
              final categorias = _calcularCategorias(ventas, productos);
              final bajaRotacion = _calcularProductosBajaRotacion(
                ventas,
                productos,
              );

              if (ventas.isEmpty && productos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 56,
                        color: cs.onSurface.withOpacity(.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Aún no hay datos de ventas ni productos",
                        style: TextStyle(color: cs.onSurface.withOpacity(.4)),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  Row(
                    children: [
                      _ResumenCard(
                        label: "Ventas registradas",
                        valor: "${ventas.length}",
                        icono: Icons.receipt_long,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 12),
                      _ResumenCard(
                        label: "Ingresos totales",
                        valor: "\$${totalGeneral.toStringAsFixed(2)}",
                        icono: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Ventas por período"),
                  _buildPeriodoChips(),
                  const SizedBox(height: 12),
                  _buildVentasPorPeriodo(ventasPeriod),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Productos más vendidos"),
                  _buildTopProductos(topProductos),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Ventas por categoría"),
                  _buildVentasPorCategoria(categorias),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Productos de baja rotación"),
                  _buildProductosBajaRotacion(bajaRotacion),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPeriodoChips() {
    return Wrap(
      spacing: 8,
      children: _PeriodoReporte.values.map((periodo) {
        return ChoiceChip(
          label: Text(_textoPeriodo(periodo)),
          selected: _periodoSeleccionado == periodo,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _periodoSeleccionado = periodo;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildVentasPorPeriodo(List<Venta> ventasPeriod) {
    final ingresosPorDia = <String, double>{};
    final cantidadesPorDia = <String, int>{};

    for (final venta in ventasPeriod) {
      final fecha = venta.fecha;
      final etiqueta = '${fecha.day}/${fecha.month}';
      ingresosPorDia[etiqueta] = (ingresosPorDia[etiqueta] ?? 0) + venta.total;
      cantidadesPorDia[etiqueta] = (cantidadesPorDia[etiqueta] ?? 0) + 1;
    }

    if (ventasPeriod.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('No hay ventas en este período.'),
      );
    }

    final dias = ingresosPorDia.keys.toList();
    final totalIngresosDia = ingresosPorDia.values.fold(0.0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Mostrando ${ventasPeriod.length} ventas para ${_textoPeriodo(_periodoSeleccionado)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
        ...dias.map((dia) {
          final ingresos = ingresosPorDia[dia]!;
          final cantidad = cantidadesPorDia[dia]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dia · ${cantidad} ventas · \$${ingresos.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: totalIngresosDia > 0 ? ingresos / totalIngresosDia : 0,
                  minHeight: 6,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopProductos(List<MapEntry<String, int>> topProductos) {
    if (topProductos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('No hay productos vendidos aún.'),
      );
    }

    return Column(
      children: topProductos.take(5).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text('${entry.value}', textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVentasPorCategoria(List<_CategoriaReporte> categorias) {
    if (categorias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('No se encontraron categorías con ventas.'),
      );
    }

    return Column(
      children: categorias.map((categoria) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${categoria.categoria} · ${categoria.cantidad} unidades · \$${categoria.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: categorias.first.total > 0
                    ? categoria.total / categorias.first.total
                    : 0,
                minHeight: 6,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductosBajaRotacion(List<_ProductoBajaRotacion> bajaRotacion) {
    if (bajaRotacion.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('No hay productos para analizar rotación.'),
      );
    }

    return Column(
      children: bajaRotacion.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${item.categoria} · Stock: ${item.stock}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text('${item.vendido}', textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<MapEntry<String, int>> _calcularTopProductos(List<Venta> ventas) {
    final acumulados = <String, int>{};

    for (final venta in ventas) {
      for (final item in venta.items) {
        acumulados[item.nombre] =
            (acumulados[item.nombre] ?? 0) + item.cantidad;
      }
    }

    final lista = acumulados.entries.toList();
    lista.sort((a, b) => b.value.compareTo(a.value));
    return lista;
  }

  List<_CategoriaReporte> _calcularCategorias(
    List<Venta> ventas,
    List<Producto> productos,
  ) {
    final productoPorNombre = {for (final p in productos) p.nombre: p};
    final totales = <String, double>{};
    final cantidades = <String, int>{};

    for (final venta in ventas) {
      for (final item in venta.items) {
        final categoria =
            productoPorNombre[item.nombre]?.categoria ?? 'Sin categoría';
        totales[categoria] = (totales[categoria] ?? 0) + item.subtotal;
        cantidades[categoria] = (cantidades[categoria] ?? 0) + item.cantidad;
      }
    }

    final lista = totales.entries.map((entry) {
      return _CategoriaReporte(
        categoria: entry.key,
        total: entry.value,
        cantidad: cantidades[entry.key] ?? 0,
      );
    }).toList();

    lista.sort((a, b) => b.total.compareTo(a.total));
    return lista;
  }

  List<_ProductoBajaRotacion> _calcularProductosBajaRotacion(
    List<Venta> ventas,
    List<Producto> productos,
  ) {
    final vendidos = <String, int>{};
    for (final venta in ventas) {
      for (final item in venta.items) {
        vendidos[item.nombre] = (vendidos[item.nombre] ?? 0) + item.cantidad;
      }
    }

    final lista = productos.map((producto) {
      return _ProductoBajaRotacion(
        nombre: producto.nombre,
        categoria: producto.categoria,
        stock: producto.stock,
        vendido: vendidos[producto.nombre] ?? 0,
      );
    }).toList();

    lista.sort((a, b) => a.vendido.compareTo(b.vendido));
    return lista.take(5).toList();
  }
}

class _ResumenCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _ResumenCard({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.2)),
        ),
        child: Row(
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color.withOpacity(.8)),
                ),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
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
