import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ventas_page.dart';
import 'productos_page.dart';
import 'reportes_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _seccion = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.shopping_cart_outlined,
             iconSelected: Icons.shopping_cart, label: "Ventas"),
    _NavItem(icon: Icons.inventory_2_outlined,
             iconSelected: Icons.inventory_2,   label: "Productos"),
    _NavItem(icon: Icons.bar_chart_outlined,
             iconSelected: Icons.bar_chart,      label: "Reportes"),
  ];

  final List<Widget> _pages = const [
    VentasPage(),
    ProductosPage(),
    ReportesPage(),
  ];

  void _cerrarSesion() {
    ApiService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    // Layout horizontal en pantallas anchas (tablet/desktop),
    // BottomNavigationBar en móvil
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: cs.surfaceVariant,
              selectedIndex: _seccion,
              onDestinationSelected: (i) => setState(() => _seccion = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Icon(Icons.point_of_sale, color: cs.primary, size: 32),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      tooltip: "Cerrar sesión",
                      icon: const Icon(Icons.logout),
                      onPressed: _cerrarSesion,
                    ),
                  ),
                ),
              ),
              destinations: _items
                  .map((e) => NavigationRailDestination(
                        icon: Icon(e.icon),
                        selectedIcon: Icon(e.iconSelected),
                        label: Text(e.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _pages[_seccion]),
          ],
        ),
      );
    }

    // Móvil
    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_seccion].label),
        centerTitle: true,
        actions: [
          IconButton(
              tooltip: "Cerrar sesión",
              icon: const Icon(Icons.logout),
              onPressed: _cerrarSesion),
        ],
      ),
      body: _pages[_seccion],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seccion,
        onDestinationSelected: (i) => setState(() => _seccion = i),
        destinations: _items
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.iconSelected),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconSelected;
  final String label;
  const _NavItem({required this.icon, required this.iconSelected, required this.label});
}