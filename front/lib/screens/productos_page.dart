import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto.dart';
import 'agregar_producto_page.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});
  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  // FIX DEFINITIVO: inicializar directamente sin setState en initState
  Future<List<Producto>> _futureProductos = Future.value([]);
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    // Asignación directa — sin setState, sin async
    _futureProductos = ApiService.obtenerProductos();
  }

  void _cargar() {
    setState(() {
      _futureProductos = ApiService.obtenerProductos();
    });
  }

  Future<void> _irFormulario({Producto? producto}) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AgregarProductoPage(producto: producto)),
    );
    if (ok == true) _cargar();
  }

  Future<void> _eliminar(Producto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text("¿Eliminar \"${p.nombre}\"?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Eliminar",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ApiService.eliminarProducto(p.id);
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar producto...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (v) => setState(() => _busqueda = v.toLowerCase()),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: () => _irFormulario(),
              icon: const Icon(Icons.add),
              label: const Text("Nuevo"),
            ),
          ]),
        ),
        Expanded(
          child: FutureBuilder<List<Producto>>(
            future: _futureProductos,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text("${snap.error}"),
                    TextButton(
                        onPressed: _cargar,
                        child: const Text("Reintentar")),
                  ]),
                );
              }
              var lista = snap.data ?? [];
              if (_busqueda.isNotEmpty) {
                lista = lista
                    .where((p) =>
                        p.nombre.toLowerCase().contains(_busqueda) ||
                        p.categoria.toLowerCase().contains(_busqueda))
                    .toList();
              }
              if (lista.isEmpty) {
                return const Center(child: Text("Sin resultados"));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final p = lista[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Text(p.nombre[0].toUpperCase(),
                            style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                      title: Text(p.nombre,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          "${p.categoria}  ·  \$${p.precio.toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text("${p.stock}"),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: p.stock > 5
                                ? Colors.green.shade100
                                : p.stock > 0
                                    ? Colors.orange.shade100
                                    : Colors.red.shade100,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: "Editar",
                            onPressed: () => _irFormulario(producto: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: "Eliminar",
                            onPressed: () => _eliminar(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}