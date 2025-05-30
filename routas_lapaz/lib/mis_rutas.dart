import 'package:flutter/material.dart';
import 'package:routas_lapaz/mapa.dart';
import 'package:routas_lapaz/conoce.dart';
import 'package:routas_lapaz/ayuda.dart';
import 'package:routas_lapaz/home.dart';
import 'package:routas_lapaz/sugerencias.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MisRutas extends StatefulWidget {
  const MisRutas({super.key});

  @override
  State<MisRutas> createState() => _MisRutasState();
}

class _MisRutasState extends State<MisRutas> {
  List<Map<String, dynamic>> _rutasGuardadas = [];
  
  @override
  void initState() {
    super.initState();
    _cargarRutasGuardadas();
  }

  Future<void> _cargarRutasGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final rutasJson = prefs.getStringList('rutas_guardadas') ?? [];

    setState(() {
      _rutasGuardadas = rutasJson
          .map((r) => jsonDecode(r) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _eliminarRuta(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rutasGuardadas = prefs.getStringList('rutas_guardadas') ?? [];
    
    if (index >= 0 && index < rutasGuardadas.length) {
      rutasGuardadas.removeAt(index);
      await prefs.setStringList('rutas_guardadas', rutasGuardadas);
      _cargarRutasGuardadas(); // Recargar la lista
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ruta eliminada correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutas Guardadas'),
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
        child: _rutasGuardadas.isEmpty
          ? const Center(
              child: Text(
                'No hay rutas guardadas',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF17584C),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _rutasGuardadas.length,
              itemBuilder: (context, index) {
                final ruta = _rutasGuardadas[index];
                return _buildRutaCard(context, ruta, index);
              },
            ),
      ),
    );
  }

  Widget _buildRutaCard(BuildContext context, Map<String, dynamic> ruta, int index) {
    final fecha = ruta['fecha'] != null 
        ? DateTime.parse(ruta['fecha']).toLocal()
        : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ruta['nombre'] ?? 'Ruta sin nombre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17584C),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Color(0xFFECBDBF)),
                    onPressed: () => _mostrarDialogoEliminar(index),
                  ),
                ],
              ),
              if (fecha != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Creada: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    ruta['medio'] == 'foot' ? Icons.directions_walk : Icons.directions_car,
                    color: const Color(0xFF3D8B7D),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ruta['medio'] == 'foot' ? 'A pie' : 'En auto',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3D8B7D)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _abrirRutaEnMapa(ruta),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDBC557),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Ver en mapa',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ruta'),
        content: const Text('¿Estás seguro de que quieres eliminar esta ruta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarRuta(index);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirRutaEnMapa(Map<String, dynamic> ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapaLaPaz(
          medio: ruta['medio'],
          rutaGuardada: ruta,
        ),
      ),
    );
  }

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
            isActive: true,
            onTap: () => Navigator.pop(context),
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
            isActive: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AyudaPage()),
              );
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