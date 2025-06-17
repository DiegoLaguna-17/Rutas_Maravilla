import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:routas_lapaz/formas.dart';
import 'mapa_notifier.dart';
import 'mapa_state.dart';
import 'package:routas_lapaz/mis_rutas.dart';
import 'package:routas_lapaz/conoce.dart';
import 'package:routas_lapaz/ayuda.dart';

// Provider principal del mapa
final mapaProvider = StateNotifierProvider<MapaNotifier, MapaState>((ref) {
  return MapaNotifier(medio: 'foot'); // Valor por defecto, se actualizará después
});

class MapaScreen extends ConsumerWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final medio = routeArgs?['medio'] ?? 'foot';
    
    final state = ref.watch(mapaProvider);
    final notifier = ref.read(mapaProvider.notifier);

    // Cargar ruta guardada y actualizar medio después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (routeArgs?['rutaGuardada'] != null) {
        notifier.cargarRutaGuardada(routeArgs?['rutaGuardada']);
      }
      if (state.medio != medio) {
        notifier.actualizarMedio(medio);
      }
    });

    // Manejo de errores
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
          ),
        );
        notifier.limpiarError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa con rutas: ${medio == 'foot' ? 'A pie' : 'En auto'}'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      drawer: _buildDrawer(context, ref, notifier, medio),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: state.ubicacionActual ?? const LatLng(-16.5, -68.11),
              zoom: 12.7,
              onTap: (_, point) => notifier.agregarNodo(point),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              PolylineLayer(polylines: _buildPolylines(state)),
              MarkerLayer(markers: _buildEdgeMarkers(state, context, notifier)),
              MarkerLayer(markers: _buildNodeMarkers(state, context, notifier, medio)),
              if (state.mostrarUbicacion && state.ubicacionActual != null)
                MarkerLayer(markers: [_buildCurrentLocationMarker(state.ubicacionActual!)]),
            ],
          ),
          if (state.error != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: _buildErrorBanner(state.error!, notifier),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(context, notifier, state),
    );
  }

  List<Polyline> _buildPolylines(MapaState state) {
    final edges = state.mostrandoMST ? state.mstEdges : state.edges;
    return edges.map((e) => Polyline(
      points: e.ruta,
      color: state.mostrandoMST ? Colors.green : e.color,
      strokeWidth: state.mostrandoMST ? 6 : 4,
    )).toList();
  }

  List<Marker> _buildEdgeMarkers(MapaState state, BuildContext context, MapaNotifier notifier) {
    final edges = state.mostrandoMST ? state.mstEdges : state.edges;
    return edges.map((edge) {
      return Marker(
        point: edge.labelPoint,
        width: 120,
        height: 40,
        child: GestureDetector(
          onTap: () => _showEdgeDescription(context, edge),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.mostrandoMST && edge.descripcionApi != null)
                const Icon(Icons.info, color: Colors.red, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  edge.labelText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _buildNodeMarkers(MapaState state, BuildContext context, MapaNotifier notifier, String medio) {
    return state.nodos.asMap().entries.map((entry) {
      final index = entry.key;
      final punto = entry.value;
      final color = state.coloresNodos[index];

      return Marker(
        point: punto,
        width: 60,
        height: 60,
        child: GestureDetector(
          onLongPress: () => _showDeleteNodeDialog(context, notifier, index),
          child: Center(
            child: medio == 'foot'
                ? PeatonIcono(size: 300, color: color, x: 30/100, y: 30/100)
                : AutoIcono(color: color, x: 30/100, y: 30/100),
          ),
        ),
      );
    }).toList();
  }

  Marker _buildCurrentLocationMarker(LatLng ubicacion) {
    return Marker(
      point: ubicacion,
      width: 50,
      height: 50,
      child: const Icon(
        Icons.location_pin,
        color: Colors.red,
        size: 50,
      ),
    );
  }

  Widget _buildErrorBanner(String error, MapaNotifier notifier) {
    return MaterialBanner(
      content: Text(error),
      backgroundColor: Colors.redAccent,
      actions: [
        TextButton(
          onPressed: notifier.limpiarError,
          child: const Text(
            'Cerrar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, MapaNotifier notifier, MapaState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'ubicacion',
          onPressed: notifier.alternarUbicacionActual,
          child: Icon(
            state.mostrarUbicacion ? Icons.location_off : Icons.location_on,
            color: Colors.white,
          ),
          backgroundColor: state.mostrarUbicacion ? Colors.red : Colors.blue,
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          onPressed: () => state.nodos.isEmpty
              ? _showSnackBar(context, 'No hay puntos para encontrar una ruta')
              : notifier.aplicarKruskal(),
          label: Text(state.mostrandoMST ? 'Mostrar Todas' : 'Ruta Corta'),
          icon: Icon(state.mostrandoMST ? Icons.layers : Icons.shuffle),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          onPressed: () => state.nodos.isEmpty
              ? _showSnackBar(context, 'No hay puntos a eliminar')
              : _showClearAllDialog(context, notifier),
          label: const Text('Limpiar'),
          icon: const Icon(Icons.delete),
          backgroundColor: const Color(0xFFECBDBF),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          onPressed: () => state.nodos.isEmpty
              ? _showSnackBar(context, 'No hay rutas a guardar')
              : _showSaveRouteDialog(context, notifier),
          label: const Text('Guardar'),
          icon: const Icon(Icons.save),
          backgroundColor: const Color(0xFFDBC557),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, MapaNotifier notifier, String medio) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3D8B7D)),
            child: Text('Opciones de Rutas', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_walk,
            title: 'Recorrido a pie',
            isActive: medio == 'foot',
            onTap: () => _navigateTo(context, 'foot'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_car,
            title: 'Recorrido en auto',
            isActive: medio == 'car',
            onTap: () => _navigateTo(context, 'car'),
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
          _buildExpansionTile(
            context,
            icon: Icons.accessibility_new,
            title: 'Lugares',
            children: [
              _buildPlaceCategoryTile(
                context,
                notifier,
                icon: Icons.restaurant,
                title: 'Comida',
                places: [
                  {'nombre': 'Mi Chola Restaurant', 'lat': -16.50830, 'lng': -68.12847},
                  {'nombre': 'Brosso', 'lat': -16.50060, 'lng': -68.13296},
                  {'nombre': 'Mercado Lanza', 'lat': -16.4965, 'lng': -68.1342},
                ],
                color: Colors.red,
              ),
              _buildPlaceCategoryTile(
                context,
                notifier,
                icon: Icons.hotel,
                title: 'Hoteles',
                places: [
                  {'nombre': 'Hotel Presidente', 'lat': -16.49573, 'lng': -68.14591},
                  {'nombre': 'Casa Grande', 'lat': -16.5127, 'lng': -68.1198},
                  {'nombre': 'Hotel Europa', 'lat': -16.50226, 'lng': -68.13085},
                ],
                color: Colors.purple,
              ),
              _buildPlaceCategoryTile(
                context,
                notifier,
                icon: Icons.place,
                title: 'Atracciones',
                places: [
                  {'nombre': 'Valle de la Luna', 'lat': -16.5525, 'lng': -68.0697},
                  {'nombre': 'Parque Purapura', 'lat': -16.48526, 'lng': -68.15180},
                  {'nombre': 'San Francisco', 'lat': -16.49614, 'lng': -68.13718},
                ],
                color: Colors.blue,
              ),
            ],
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
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFF17584C) : const Color(0xFF3D8B7D),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF17584C) : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      tileColor: isActive ? const Color(0xFFDBC557) : null,
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF3D8B7D)),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      children: children,
    );
  }

  Widget _buildPlaceCategoryTile(
    BuildContext context,
    MapaNotifier notifier, {
    required IconData icon,
    required String title,
    required List<Map<String, dynamic>> places,
    required Color color,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: const Color(0xFF3D8B7D)),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      children: places.map((place) => _buildPlaceItem(
        context,
        notifier,
        place['nombre'] as String,
        LatLng(place['lat'] as double, place['lng'] as double),
        color,
      )).toList(),
    );
  }

  Widget _buildPlaceItem(
    BuildContext context,
    MapaNotifier notifier,
    String nombre,
    LatLng coordenadas, 
    Color color,
  ) {
    return ListTile(
      title: Text(nombre),
      onTap: () {
        Navigator.pop(context);
        notifier.agregarMarcadorPredefinido(coordenadas, color, nombre);
        _showSnackBar(context, 'Marcador agregado: $nombre');
      },
    );
  }

  void _showEdgeDescription(BuildContext context, Edge edge) {
    if (edge.descripcionApi == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Descripción de la Ruta"),
        content: SingleChildScrollView(child: Text(edge.descripcionApi!)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _showDeleteNodeDialog(BuildContext context, MapaNotifier notifier, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Marcador"),
        content: const Text("¿Deseas eliminar este marcador y sus rutas asociadas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              notifier.eliminarNodo(index);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, MapaNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Todo"),
        content: const Text("¿Deseas eliminar todos los puntos y rutas?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              notifier.limpiarTodo();
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveRouteDialog(BuildContext context, MapaNotifier notifier) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) {
        String nombreRuta = '';
        return AlertDialog(
          title: const Text('Guardar ruta'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre de la ruta',
              hintText: 'Ej: Ruta al trabajo',
            ),
            onChanged: (value) => nombreRuta = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nombreRuta),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nombre != null && nombre.isNotEmpty) {
      await notifier.guardarRutaActual(nombre);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateTo(BuildContext context, String medio) {
    final currentArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (currentArgs?['medio'] != medio) {
      Navigator.pushReplacementNamed(
        context,
        '/mapa',
        arguments: {'medio': medio},
      );
    } else {
      Navigator.pop(context);
    }
  }
}