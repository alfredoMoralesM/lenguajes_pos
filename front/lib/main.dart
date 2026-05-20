import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() => runApp(const PosApp());

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(letterSpacing: -0.5),
          titleLarge:     TextStyle(letterSpacing: -0.3),
        ),
      ),
      home: const LoginPage(),
    );
  }
}