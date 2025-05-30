import 'package:flutter/material.dart';
import 'package:routas_lapaz/conoce.dart';
import 'package:routas_lapaz/mapa.dart';
import 'package:routas_lapaz/sugerencias.dart';
import 'package:routas_lapaz/mis_rutas.dart';

class AyudaPage extends StatelessWidget {
  const AyudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de Usuario'),
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
              _buildMainTitle(),
              const SizedBox(height: 30),
              _buildSectionWithImage(
                title: 'Navegación',
                content: 'Descubre cada una de nuestras opciones de menú desplegable en la esquina superior izquierda. '
                    'Desde aquí podrás acceder a todas las funcionalidades de la app.',
                image: Icons.menu_book,
              ),
              const SizedBox(height: 25),
              _buildSectionWithImage(
                title: 'A Pie',
                content: 'Si deseas ingresar a recorridos tranquilos disfrutando cada parte de la ciudad, elige esta opción. '
                    'Perfecto para turistas que quieren explorar a su propio ritmo.',
                image: Icons.directions_walk,
              ),
              const SizedBox(height: 25),
              _buildSectionWithImage(
                title: 'En Auto',
                content: 'En caso de estar en un vehículo y querer conocer las mejores rutas para ir de un lugar a otro, '
                    'esta es tu opción ideal. Calcula rutas optimizadas para movilidad.',
                image: Icons.directions_car,
              ),
              const SizedBox(height: 25),
              _buildSectionWithImage(
                title: 'Mis Rutas',
                content: 'Revisa todas aquellas rutas que te encantaron en este apartado. '
                    'Guarda tus recorridos favoritos para acceder rápidamente a ellos.',
                image: Icons.alt_route,
              ),
              const SizedBox(height: 25),
              _buildSectionWithImage(
                title: 'Conoce Más',
                content: 'Si deseas conocer aspectos impresionantes acerca del proyecto, '
                    'dirígete a esta página. Descubre el propósito y beneficios de la app.',
                image: Icons.info,
              ),
              const SizedBox(height: 25),
              _buildSectionWithImage(
                title: 'Ayuda',
                content: 'Descubre cada uno de los funcionamientos de nuestra app y sácale el jugo! '
                    'Esta sección contiene toda la información que necesitas.',
                image: Icons.help,
              ),
              const SizedBox(height: 30),
              _buildCreateRouteSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return const Text(
      'Cómo usar Rutas La Paz',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF17584C),
        shadows: [
          Shadow(
            blurRadius: 2,
            color: Colors.white,
            offset: Offset(1, 1),
          )
        ],
      ),
    );
  }

  Widget _buildSectionWithImage({required String title, required String content, required IconData image}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D8B7D),
                  ),
                ),
                const SizedBox(height: 8),
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
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDBC557).withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: const Color(0xFFDBC557), width: 2),
            ),
            child: Icon(image, size: 30, color: const Color(0xFF17584C)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateRouteSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D8B7D).withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF3D8B7D), width: 1),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crea tu Ruta',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF17584C),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Elije una de nuestras 2 opciones "A pie" o "En auto"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildStepItem('a) Presiona sobre el mapa para definir tu punto de partida', Icons.location_on),
          _buildStepItem('b) Presiona sobre el mapa en otra dirección para establecer el punto de llegada', Icons.flag),
          _buildStepItem('c) Puedes ingresar más de una parada en todo tu recorrido para descubrir más lugares', Icons.add_location_alt),
          _buildStepItem('d) Haz click sobre el botón "Ruta más rápida" para conocer el camino más rápido', Icons.alt_route),
          _buildStepItem('e) Limpia el lienzo y vuelve a poner otra ruta con el botón de eliminar', Icons.delete),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFDBC557)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF17584C),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Los métodos _buildDrawer y _buildMenuItem se mantienen igual que en tu código original)
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
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapaLaPaz(medio: 'foot'),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_car,
            title: 'Recorrido en auto',
            isActive: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapaLaPaz(medio: 'car'),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.alt_route,
            title: 'Mis Rutas',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MisRutas()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.accessibility_new,
            title: 'lugares',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SugerenciasPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info,
            title: 'Conoce más',
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConocePage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.help,
            title: 'Ayuda',
            isActive: true,
            onTap: () => Navigator.pop(context),
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
            decoration: BoxDecoration(
              color: isActive
                ? const Color(0xFFDBC557)
                : isHovered
                    ? const Color(0xFFECBDBF)
                    : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(
                icon,
                color: isActive
                  ? const Color(0xFF17584C)
                  : isHovered
                      ? const Color(0xFF17584C)
                      : const Color(0xFF3D8B7D),
              ),
              title: Text(
                title,
                style: TextStyle(
                  color: isActive
                    ? const Color(0xFF17584C)
                    : isHovered
                        ? const Color(0xFF17584C)
                        : Colors.black87,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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