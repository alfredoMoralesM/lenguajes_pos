class Producto {
  final int id;
  final String nombre;
  final double precio;
  final int stock;
  final String categoria; // FIX: faltaba este campo

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id:        json['id'],
      nombre:    json['nombre'],
      precio:    (json['precio'] as num).toDouble(), // FIX: cast seguro
      stock:     json['stock'],
      categoria: json['categoria'] ?? '',            // FIX: faltaba categoria
    );
  }

  // Útil para pasar el producto a la pantalla de edición
  Map<String, dynamic> toJson() => {
    'id':        id,
    'nombre':    nombre,
    'precio':    precio,
    'stock':     stock,
    'categoria': categoria,
  };
}