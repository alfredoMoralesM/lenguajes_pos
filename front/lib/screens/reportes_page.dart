import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/venta.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});
  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  // FIX DEFINITIVO: inicializar directamente sin setState en initState
  Future<List<Venta>> _futureVentas = Future.value([]);

  @override
  void initState() {
    super.initState();
    // Asignación directa — sin setState, sin async
    _futureVentas = ApiService.obtenerHistorial();
  }

  void _cargar() {
    setState(() {
      _futureVentas = ApiService.obtenerHistorial();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text("Historial de Ventas",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
                  onPressed: _cargar),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<Venta>>(
            future: _futureVentas,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text("Error: ${snap.error}"));
              }
              final ventas = snap.data ?? [];
              if (ventas.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 56, color: cs.onSurface.withOpacity(.3)),
                    const SizedBox(height: 12),
                    Text("Sin ventas registradas",
                        style:
                            TextStyle(color: cs.onSurface.withOpacity(.4))),
                  ]),
                );
              }

              final totalGeneral =
                  ventas.fold(0.0, (s, v) => s + v.total);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      _ResumenCard(
                          label: "Total ventas",
                          valor: "${ventas.length}",
                          icono: Icons.receipt_outlined,
                          color: cs.primary),
                      const SizedBox(width: 12),
                      _ResumenCard(
                          label: "Ingresos totales",
                          valor: "\$${totalGeneral.toStringAsFixed(2)}",
                          icono: Icons.attach_money,
                          color: Colors.green),
                    ]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: ventas.length,
                      itemBuilder: (ctx, i) {
                        final v = ventas[i];
                        final fecha =
                            "${v.fecha.day}/${v.fecha.month}/${v.fecha.year}  "
                            "${v.fecha.hour.toString().padLeft(2, '0')}:"
                            "${v.fecha.minute.toString().padLeft(2, '0')}";
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Text("#${v.id}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                                "\$${v.total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(fecha),
                            trailing: Chip(
                              label: Text("${v.items.length} art."),
                              visualDensity: VisualDensity.compact,
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                          color: cs.surfaceVariant
                                              .withOpacity(.5)),
                                      children: const [
                                        Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Text("Producto",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12))),
                                        Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Text("Cant.",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12))),
                                        Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Text("Subtotal",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12))),
                                      ],
                                    ),
                                    ...v.items.map((item) => TableRow(
                                          children: [
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Text(item.nombre,
                                                    style: const TextStyle(
                                                        fontSize: 12))),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Text(
                                                    "${item.cantidad}",
                                                    style: const TextStyle(
                                                        fontSize: 12))),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                child: Text(
                                                    "\$${item.subtotal.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                        fontSize: 12))),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
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
        child: Row(children: [
          Icon(icono, color: color, size: 32),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: color.withOpacity(.8))),
            Text(valor,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ]),
        ]),
      ),
    );
  }
}