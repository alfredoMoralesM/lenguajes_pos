import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto.dart';

class _ItemCarrito {
  final Producto producto;
  int cantidad;
  _ItemCarrito(this.producto, this.cantidad);
  double get subtotal => producto.precio * cantidad;
}

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});
  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  // FIX DEFINITIVO: inicializar directamente sin setState en initState
  Future<List<Producto>> _futureProductos = Future.value([]);
  final List<_ItemCarrito> _carrito = [];
  bool _procesando = false;
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initState NO es async — asignación directa sin setState
    _futureProductos = ApiService.obtenerProductos();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _cargar() {
    // Asignar el Future directamente dentro de setState es seguro
    // porque Future.value() es síncrono — no hay async en el callback
    setState(() {
      _futureProductos = ApiService.obtenerProductos();
    });
  }

  double get _total => _carrito.fold(0, (s, i) => s + i.subtotal);

  void _agregar(Producto p) {
    final idx = _carrito.indexWhere((i) => i.producto.id == p.id);
    if (idx >= 0) {
      if (_carrito[idx].cantidad < p.stock) {
        setState(() => _carrito[idx].cantidad++);
      }
    } else {
      if (p.stock > 0) {
        setState(() => _carrito.add(_ItemCarrito(p, 1)));
      }
    }
  }

  void _quitar(int idx) => setState(() => _carrito.removeAt(idx));

  void _cambiarCantidad(int idx, int delta) {
    final nueva = _carrito[idx].cantidad + delta;
    if (nueva <= 0) {
      setState(() => _carrito.removeAt(idx));
    } else {
      setState(() => _carrito[idx].cantidad = nueva);
    }
  }

  Future<void> _confirmar() async {
    if (_carrito.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar venta"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._carrito.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${i.producto.nombre} x${i.cantidad}"),
                      Text("\$${i.subtotal.toStringAsFixed(2)}"),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("\$${_total.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancelar")),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Cobrar")),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _procesando = true);

    try {
      final items = _carrito
          .map((i) => {'id': i.producto.id, 'cantidad': i.cantidad})
          .toList();

      await ApiService.confirmarVenta(items);

      if (!mounted) return;

      _carrito.clear();
      setState(() {
        _procesando = false;
        _futureProductos = ApiService.obtenerProductos();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Venta registrada"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // ── Catálogo ───────────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text("Productos",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: "Buscar producto...",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _busqueda.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _busqueda = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (v) =>
                            setState(() => _busqueda = v.toLowerCase()),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Producto>>(
                  future: _futureProductos,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text("Error: ${snap.error}"));
                    }
                    final lista = snap.data ?? [];
                    if (lista.isEmpty) {
                      return const Center(child: Text("Sin productos registrados"));
                    }
                    // Filtrar por búsqueda (nombre o categoría)
                    final listaFiltrada = _busqueda.isEmpty
                        ? lista
                        : lista
                            .where((p) =>
                                p.nombre.toLowerCase().contains(_busqueda) ||
                                p.categoria.toLowerCase().contains(_busqueda))
                            .toList();
                    if (listaFiltrada.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(.3)),
                            const SizedBox(height: 8),
                            Text(
                              "Sin resultados para \"$_busqueda\"",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(.5)),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: listaFiltrada.length,
                      itemBuilder: (ctx, i) {
                        final p = listaFiltrada[i];
                        final sinStock = p.stock == 0;
                        return GestureDetector(
                          onTap: sinStock ? null : () => _agregar(p),
                          child: AnimatedOpacity(
                            opacity: sinStock ? 0.45 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.inventory_2_outlined,
                                          color: cs.primary),
                                    ),
                                    const Spacer(),
                                    Text(p.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(p.categoria,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface.withOpacity(.5))),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("\$${p.precio.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                color: cs.primary,
                                                fontWeight: FontWeight.bold)),
                                        Text("Stock: ${p.stock}",
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: p.stock > 5
                                                    ? Colors.green
                                                    : p.stock > 0
                                                        ? Colors.orange
                                                        : Colors.red)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

        // ── Carrito ────────────────────────────────────────────────────
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.4),
            border: Border(left: BorderSide(color: cs.outlineVariant)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Text("Carrito",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_carrito.isNotEmpty)
                      TextButton(
                          onPressed: () => setState(() => _carrito.clear()),
                          child: const Text("Limpiar")),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _carrito.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_shopping_cart_outlined,
                                size: 48,
                                color: cs.onSurface.withOpacity(.3)),
                            const SizedBox(height: 8),
                            Text("Carrito vacío",
                                style: TextStyle(
                                    color: cs.onSurface.withOpacity(.4))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _carrito.length,
                        itemBuilder: (ctx, i) {
                          final item = _carrito[i];
                          return ListTile(
                            dense: true,
                            title: Text(item.producto.nombre,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(
                                "\$${item.subtotal.toStringAsFixed(2)}",
                                style: TextStyle(color: cs.primary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  iconSize: 18,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _cambiarCantidad(i, -1),
                                ),
                                Text("${item.cantidad}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  iconSize: 18,
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _cambiarCantidad(i, 1),
                                ),
                                IconButton(
                                  iconSize: 18,
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () => _quitar(i),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${_total.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: cs.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: (_carrito.isEmpty || _procesando)
                            ? null
                            : _confirmar,
                        icon: _procesando
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_circle_outline),
                        label: const Text("Confirmar venta"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}