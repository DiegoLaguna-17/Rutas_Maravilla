import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/mapa/mapa_screen.dart';
import 'package:routas_lapaz/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rutas La Paz',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/mapa': (context) => const MapaScreen(),
      },
    );
  }
}
