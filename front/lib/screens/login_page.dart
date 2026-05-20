import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey       = GlobalKey<FormState>();
  final _userCtrl      = TextEditingController();
  final _passCtrl      = TextEditingController();
  bool  _obscure       = true;
  bool  _cargando      = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _error = null; });
    try {
      await ApiService.login(_userCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      setState(() => _error = "Usuario o contraseña incorrectos");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / ícono
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.point_of_sale, color: cs.onPrimary, size: 42),
                ),
                const SizedBox(height: 24),
                Text("POS System",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(height: 6),
                Text("Acceso de administrador",
                    style: TextStyle(color: cs.onSurface.withOpacity(.5))),
                const SizedBox(height: 40),
                // Formulario
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(
                        labelText: "Usuario",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
                      onFieldSubmitted: (_) => _login(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _cargando
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text("Ingresar",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}