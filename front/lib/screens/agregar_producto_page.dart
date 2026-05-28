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

  //Variables para validacion de productos y categorias
  final TextEditingController _nuevaCategoriaController = TextEditingController();
  List<Producto> _productosExistentes = [];
  List<String> _categorias = [];
  String? _categoriaSeleccionada;
  bool _esNuevaCategoria = false;

  bool cargando = false;
  bool get esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    // Pre-llenar campos si estamos editando
    nombreController    = TextEditingController(text: widget.producto?.nombre    ?? '');
    precioController    = TextEditingController(text: widget.producto?.precio.toString() ?? '');
    stockController     = TextEditingController(text: widget.producto?.stock.toString()  ?? '');
    _cargarDatosPrevios();
  }

  Future<void> _cargarDatosPrevios() async {
    try {
      final productos = await ApiService.obtenerProductos();
      if (!mounted) return;
      
      setState(() {
        _productosExistentes = productos;
        // Extraemos categorias únicas y evitamos vacias
        _categorias = productos
            .map((p) => p.categoria)
            .where((c) => c.trim().isNotEmpty)
            .toSet()
            .toList();

        // Configurar la categoria inicial seleccionada
        if (esEdicion) {
          if (_categorias.contains(widget.producto!.categoria)) {
            _categoriaSeleccionada = widget.producto!.categoria;
          } else {
            _categorias.add(widget.producto!.categoria);
            _categoriaSeleccionada = widget.producto!.categoria;
          }
        } else if (_categorias.isNotEmpty) {
          _categoriaSeleccionada = _categorias.first;
        }
      });
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }
  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    stockController.dispose();
    _nuevaCategoriaController.dispose();
    super.dispose();
  }

  Future<void> guardarProducto() async {
    // FIX: validar antes de enviar
    if (!_formKey.currentState!.validate()) return;

    final nombreIngresado = nombreController.text.trim();

    //Valida que el nombre del producto no exista ya
    if (!esEdicion) {
      final existeProducto = _productosExistentes.any(
          (p) => p.nombre.toLowerCase() == nombreIngresado.toLowerCase());

      if (existeProducto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede agregar un producto ya existente'),
            backgroundColor: Colors.red,
          ),
        );
        return; 
      }
    }

    //Determinar la categoria final y validar si la nueva ya existia
    String categoriaFinal;
    if (_esNuevaCategoria) {
      categoriaFinal = _nuevaCategoriaController.text.trim();
      
      final existeCategoria = _categorias.any(
          (c) => c.toLowerCase() == categoriaFinal.toLowerCase());

      if (existeCategoria) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria ya existente. Seleccionela del menu.'),
            backgroundColor: Colors.orange,
          ),
        );
        return; 
      }
    } else {
      categoriaFinal = _categoriaSeleccionada ?? 'General';
    }

    setState(() => cargando = true);

    try {
      if (esEdicion) {
        await ApiService.actualizarProducto(
          id:        widget.producto!.id,
          nombre:    nombreController.text.trim(),
          precio:    double.parse(precioController.text),
          stock:     int.parse(stockController.text),
          categoria: categoriaFinal,
        );
      } else {
        await ApiService.crearProducto(
          nombre:    nombreController.text.trim(),
          precio:    double.parse(precioController.text),
          stock:     int.parse(stockController.text),
          categoria: categoriaFinal,
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
              //Menu Categorias
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    value: _categoriaSeleccionada,
                    items: [
                      ..._categorias.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          )),
                      const DropdownMenuItem(
                        value: 'NUEVA',
                        child: Text('+ Crear nueva categoria', 
                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue == 'NUEVA') {
                          _esNuevaCategoria = true;
                          _categoriaSeleccionada = null;
                        } else {
                          _esNuevaCategoria = false;
                          _categoriaSeleccionada = newValue;
                        }
                      });
                    },
                    validator: (v) => (!_esNuevaCategoria && v == null) 
                        ? 'Selecciona una categoria' : null,
                  ),
                ),
                
                if (_esNuevaCategoria)
                  _campo(
                    controller: _nuevaCategoriaController,
                    label: "Escribe la nueva categoria",
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "El nombre de la categoria es obligatorio" : null,
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