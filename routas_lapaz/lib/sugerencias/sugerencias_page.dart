import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/sugerencias/sugerencias_notifier.dart';
import '../mapa/mapa_screen.dart';
import '../mis_rutas/mis_rutas_screen.dart';
import '../ayuda.dart';
import '../conoce.dart';

class SugerenciasPage extends ConsumerWidget {
  const SugerenciasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sugerencias = ref.watch(sugerenciasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugerencias en La Paz RIver'),
        backgroundColor: const Color(0xFF3D8B7D),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF9DFE0), Color(0xFF8FBC91)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: sugerencias.map((sug) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildSuggestionButton(context,
                      imagePath: sug.imagePath, text: sug.titulo, page: sug.page),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionButton(BuildContext context,
      {required String imagePath,
      required String text,
      required Widget page}) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D8B7D).withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3D8B7D)),
            child: Text(
              'Opciones de Rutas',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_walk,
            title: 'Recorrido a pie',
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/mapa',
                arguments: {'medio': 'foot'},
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_car,
            title: 'Recorrido en auto',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapaScreen(),
                  settings: const RouteSettings(arguments: {'medio': 'car'}),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.alt_route,
            title: 'Mis Rutas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MisRutasScreen()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            title: 'Lugares',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SugerenciasPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info,
            title: 'Conoce más',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConocePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.help,
            title: 'Ayuda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AyudaPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Salir',
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFECBDBF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(icon,
                  color: isHovered
                      ? const Color(0xFF17584C)
                      : const Color(0xFF3D8B7D)),
              title: Text(
                title,
                style: TextStyle(
                  color: isHovered ? const Color(0xFF17584C) : Colors.black87,
                  fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: onTap,
              hoverColor: Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}
