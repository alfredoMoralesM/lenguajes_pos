import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/venta.dart';

class ApiService {
  // Emulador Android → "http://10.0.2.2:8000/api/v1"
  // iOS Simulator / Web → "http://localhost:8000/api/v1"
  static const String baseUrl = "http://localhost:8000/api/v1";

  static String _token = "";
  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
        if (_token.isNotEmpty) "Authorization": "Bearer $_token",
      };

  //Auth
  static Future<void> login(String usuario, String password) async {
    final r = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"usuario": usuario, "password": password}),
    );
    if (r.statusCode == 200) {
      _token = jsonDecode(r.body)['token'];
    } else {
      throw Exception("Credenciales incorrectas");
    }
  }

  static void logout() => _token = "";
  static bool get isLoggedIn => _token.isNotEmpty;

  //Productos
  static Future<List<Producto>> obtenerProductos() async {
    final r = await http.get(Uri.parse("$baseUrl/productos"), headers: _headers);
    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as List).map((p) => Producto.fromJson(p)).toList();
    }
    throw Exception("Error al cargar productos");
  }

  static Future<void> crearProducto({
    required String nombre,
    required double precio,
    required int stock,
    required String categoria,
  }) async {
    final r = await http.post(
      Uri.parse("$baseUrl/productos"),
      headers: _headers,
      body: jsonEncode({"nombre": nombre, "precio": precio, "stock": stock, "categoria": categoria}),
    );
    if (r.statusCode != 201) throw Exception("Error al crear producto");
  }

  static Future<void> actualizarProducto({
    required int id,
    required String nombre,
    required double precio,
    required int stock,
    required String categoria,
  }) async {
    final r = await http.put(
      Uri.parse("$baseUrl/productos/$id"),
      headers: _headers,
      body: jsonEncode({"nombre": nombre, "precio": precio, "stock": stock, "categoria": categoria}),
    );
    if (r.statusCode != 200) throw Exception("Error al actualizar producto");
  }

  static Future<void> eliminarProducto(int id) async {
    final r = await http.delete(Uri.parse("$baseUrl/productos/$id"), headers: _headers);
    if (r.statusCode != 200) throw Exception("Error al eliminar producto");
  }

  //Ventas
  static Future<Map<String, dynamic>> confirmarVenta(
      List<Map<String, int>> items) async {
    final r = await http.post(
      Uri.parse("$baseUrl/ventas"),
      headers: _headers,
      body: jsonEncode({
        "items": items
            .map((i) => {"producto_id": i['id'], "cantidad": i['cantidad']})
            .toList()
      }),
    );
    if (r.statusCode == 201) return jsonDecode(r.body);
    final err = jsonDecode(r.body);
    throw Exception(err['detail'] ?? "Error al procesar venta");
  }

  static Future<List<Venta>> obtenerHistorial() async {
    final r = await http.get(Uri.parse("$baseUrl/ventas"), headers: _headers);
    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as List).map((v) => Venta.fromJson(v)).toList();
    }
    throw Exception("Error al cargar historial");
  }

  static String getExportUrl() => "$baseUrl/ventas/exportar";
}