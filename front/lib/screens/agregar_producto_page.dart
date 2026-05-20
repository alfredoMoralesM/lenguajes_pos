import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/producto.dart';

/// Sirve tanto para AGREGAR como para EDITAR un producto.
/// Si se pasa [producto], la pantalla entra en modo edición.
class AgregarProductoPage extends StatefulWidget {
  final Producto? producto; // FIX: soporte para edición

  const AgregarProductoPage({super.key, this.producto});

  @override
  State<AgregarProductoPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AgregarProductoPage> {
  final _formKey = GlobalKey<FormState>(); // FIX: validación con Form

  late final TextEditingController nombreController;
  late final TextEditingController precioController;
  late final TextEditingController stockController;
  late final TextEditingController categoriaController;

  bool cargando = false;
  bool get esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    // Pre-llenar campos si estamos editando
    nombreController    = TextEditingController(text: widget.producto?.nombre    ?? '');
    precioController    = TextEditingController(text: widget.producto?.precio.toString() ?? '');
    stockController     = TextEditingController(text: widget.producto?.stock.toString()  ?? '');
    categoriaController = TextEditingController(text: widget.producto?.categoria ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    stockController.dispose();
    categoriaController.dispose();
    super.dispose();
  }

  Future<void> guardarProducto() async {
    // FIX: validar antes de enviar
    if (!_formKey.currentState!.validate()) return;

    setState(() => cargando = true);

    try {
      if (esEdicion) {
        await ApiService.actualizarProducto(
          id:        widget.producto!.id,
          nombre:    nombreController.text.trim(),
          precio:    double.parse(precioController.text),
          stock:     int.parse(stockController.text),
          categoria: categoriaController.text.trim(),
        );
      } else {
        await ApiService.crearProducto(
          nombre:    nombreController.text.trim(),
          precio:    double.parse(precioController.text),
          stock:     int.parse(stockController.text),
          categoria: categoriaController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esEdicion ? "Producto actualizado" : "Producto agregado")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // Widget auxiliar para no repetir código en cada TextField
  Widget _campo({
    required TextEditingController controller,
    required String label,
    TextInputType tipo = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Producto" : "Agregar Producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo(
                controller: nombreController,
                label: "Nombre",
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "El nombre es obligatorio" : null,
              ),
              _campo(
                controller: precioController,
                label: "Precio",
                tipo: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return "Ingresa un precio válido mayor a 0";
                  return null;
                },
              ),
              _campo(
                controller: stockController,
                label: "Stock",
                tipo: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return "Ingresa un stock válido (0 o más)";
                  return null;
                },
              ),
              _campo(
                controller: categoriaController,
                label: "Categoría",
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "La categoría es obligatoria" : null,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cargando ? null : guardarProducto,
                  child: cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(esEdicion ? "Actualizar" : "Guardar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}