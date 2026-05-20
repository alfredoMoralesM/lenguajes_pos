class VentaItem {
  final String nombre;
  final int cantidad;
  final double precio;
  final double subtotal;

  VentaItem({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
  });

  factory VentaItem.fromJson(Map<String, dynamic> j) => VentaItem(
        nombre:   j['nombre'],
        cantidad: j['cantidad'],
        precio:   (j['precio'] as num).toDouble(),
        subtotal: (j['subtotal'] as num).toDouble(),
      );
}

class Venta {
  final int id;
  final double total;
  final DateTime fecha;
  final List<VentaItem> items;

  Venta({
    required this.id,
    required this.total,
    required this.fecha,
    required this.items,
  });

  factory Venta.fromJson(Map<String, dynamic> j) => Venta(
        id:    j['id'],
        total: (j['total'] as num).toDouble(),
        fecha: DateTime.parse(j['fecha']),
        items: (j['items'] as List).map((i) => VentaItem.fromJson(i)).toList(),
      );
}