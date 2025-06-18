import 'package:flutter/material.dart';

import 'package:routas_lapaz/ayuda.dart';
import 'package:routas_lapaz/sugerencias.dart';
import 'package:routas_lapaz/mis_rutas/mis_rutas_screen.dart';

class ConocePage extends StatelessWidget {
  const ConocePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conoce más'),
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
            colors: [
              Color(0xFFF9DFE0),
              Color(0xFF8FBC91),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Explora La Paz como nunca antes'),
              const SizedBox(height: 20),
              _buildInfoCard(
                context,
                title: 'Introducción',
                content:
                    'Esta aplicación revoluciona la forma de explorar La Paz, generando recorridos turísticos optimizados en función del tiempo que toma desplazarse entre distintos puntos. '
                    'Utiliza algoritmos avanzados como Kruskal para construir rutas eficientes conectando los destinos seleccionados con el menor tiempo total posible. '
                    'Solo marca los lugares que deseas visitar, y el sistema se encarga del resto. Se integra además con datos actualizados para brindar una experiencia personalizada tanto para peatones como para vehículos.',
                color: const Color(0xFFECBDBF),
              ),
              const SizedBox(height: 25),
              _buildInfoCard(
                context,
                title: 'Importancia',
                content:
                    'En una ciudad con una topografía única como La Paz, planificar rutas eficientes es clave. Nuestra solución:\n\n'
                    '• Ahorra tiempo en desplazamientos.\n'
                    '• Reduce el estrés de navegar por zonas desconocidas.\n'
                    '• Ofrece rutas adaptadas a peatones y automóviles.\n'
                    '• Promueve el turismo local mostrando lo mejor de la ciudad.',
                color: const Color(0xFFDBC557),
              ),
              const SizedBox(height: 25),
              _buildInfoCard(
                context,
                title: 'Objetivo',
                content:
                    'Transformar la experiencia de movilidad en La Paz mediante tecnología intuitiva que conecta a las personas con los lugares más fascinantes, optimizando cada recorrido para disfrutar sin complicaciones.',
                color: const Color(0xFF8FBC91),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Título principal estilizado
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF17584C),
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.white,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }

  /// Tarjetas de contenido informativo
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF17584C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Menú lateral de navegación
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF3D8B7D),
            ),
            child: Text(
              'Opciones de Rutas',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_walk,
            title: 'Recorrido a pie',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(
              context,
              '/mapa',
              arguments: {'medio': 'foot'},
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_car,
            title: 'Recorrido en auto',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(
              context,
              '/mapa',
              arguments: {'medio': 'car'},
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.alt_route,
            title: 'Mis Rutas',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MisRutasScreen()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            title: 'Lugares',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SugerenciasPage()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info,
            title: 'Conoce más',
            isActive: true,
            onTap: () => Navigator.pop(context),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help,
            title: 'Ayuda',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AyudaPage()));
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.exit_to_app,
            title: 'Salir',
            isActive: false,
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  /// Elemento individual del menú lateral
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
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
              color: isActive
                  ? const Color(0xFFDBC557)
                  : isHovered
                      ? const Color(0xFFECBDBF)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                icon,
                color: isActive || isHovered
                    ? const Color(0xFF17584C)
                    : const Color(0xFF3D8B7D),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isActive || isHovered
                      ? const Color(0xFF17584C)
                      : Colors.black87,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
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
