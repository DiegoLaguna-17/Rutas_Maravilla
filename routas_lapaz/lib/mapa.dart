import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:routas_lapaz/formas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routas_lapaz/ayuda.dart';
import 'package:routas_lapaz/mis_rutas.dart';
import 'package:routas_lapaz/conoce.dart';


import 'package:geolocator/geolocator.dart';

class MapaLaPaz extends StatefulWidget {
  final String medio;
   final Map<String, dynamic>? rutaGuardada;

  const MapaLaPaz({super.key, required this.medio, this.rutaGuardada});

  @override
  State<MapaLaPaz> createState() => _MapaLaPazState();
}

class Edge {
  final int from; // Índice en la lista _nodos
  final int to;   // Índice en la lista _nodos
  final double weight;
  final List<LatLng> ruta;
  final LatLng labelPoint;
  final String labelText;
  final Color color;
  String? descripcionApi; // Para almacenar la descripción de la API

  Edge(this.from, this.to, this.weight, this.ruta, this.labelPoint, this.labelText, this.color, {this.descripcionApi});

  // Método copyWith para actualizar fácilmente la descripción u otros campos
  Edge copyWith({
    int? from,
    int? to,
    double? weight,
    List<LatLng>? ruta,
    LatLng? labelPoint,
    String? labelText,
    Color? color,
    String? descripcionApi, // Hacer que descripcionApi sea nombrada y opcional
  }) {
    return Edge(
      from ?? this.from,
      to ?? this.to,
      weight ?? this.weight,
      ruta ?? this.ruta,
      labelPoint ?? this.labelPoint,
      labelText ?? this.labelText,
      color ?? this.color,
      descripcionApi: descripcionApi ?? this.descripcionApi,
    );
  }
}

class _MapaLaPazState extends State<MapaLaPaz> {
  double x = 30, y = 30, w = 50, h = 50;
  List<LatLng> _nodos = [];
  List<Polyline> _rutas = [];
  List<Marker> _pesoLabels = [];
  List<Color> _coloresNodos = [];
  List<Edge> _edges = []; // Todas las aristas posibles
  List<Edge> _mstEdges = []; // Aristas que forman parte del MST
  bool _mostrandoMST = false;

  //para ubicacion
  bool _mostrarUbicacionActual = false;
  LatLng? _ubicacionActual;

  // !!! IMPORTANTE: Reemplaza con la URL de tu API !!!
  // Si la API se ejecuta localmente y Flutter en emulador Android: http://10.0.2.2:PUERTO_API
  // Si la API se ejecuta localmente y Flutter en emulador iOS: http://localhost:PUERTO_API
  // Si la API se ejecuta localmente y Flutter en dispositivo físico (misma red): http://TU_IP_COMPUTADORA:PUERTO_API
  // Si la API está desplegada: https://tu-dominio-api.com
  static const String miApiBaseUrl = 'https://api-descripcion-xs5h.vercel.app'; // Ejemplo para API local y emulador Android

  static const String graphhopperApiKey = '63b19cd4-a9f9-47bd-a58b-0273d67721fa'; // Tu clave de GraphHopper
  //key 1 7bfad773-8832-4eee-9d15-1a9d07c3a5c1
  // key 2 63b19cd4-a9f9-47bd-a58b-0273d67721fa
@override
void initState() {
  super.initState();
  if (widget.rutaGuardada != null) {
    final data = widget.rutaGuardada!;
    
    // Verificar si 'nodos' existe y no está vacío
    if (data['nodos'] != null && data['nodos'] is List && (data['nodos'] as List).isNotEmpty) {
      _nodos = (data['nodos'] as List)
          .map((n) => LatLng(n['lat'], n['lng']))
          .toList();

      _coloresNodos = (data['coloresNodos'] as List)
          .map((v) => Color(v))
          .toList();
    }

    // Inicializar edges si existen
    if (data['edges'] != null && data['edges'] is List) {
      _edges = (data['edges'] as List).map((e) {
        return Edge(
          e['from'],
          e['to'],
          (e['weight'] as num).toDouble(),
          (e['ruta'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList(),
          LatLng(e['labelPoint']['lat'], e['labelPoint']['lng']),
          e['labelText'],
          Color(e['color']),
          descripcionApi: e['descripcionApi'],
        );
      }).toList();
    }

    // Inicializar mstEdges si existen
    if (data['mstEdges'] != null && data['mstEdges'] is List) {
      _mstEdges = (data['mstEdges'] as List).map((e) {
        return Edge(
          e['from'],
          e['to'],
          (e['weight'] as num).toDouble(),
          (e['ruta'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList(),
          LatLng(e['labelPoint']['lat'], e['labelPoint']['lng']),
          e['labelText'],
          Color(e['color']),
          descripcionApi: e['descripcionApi'],
        );
      }).toList();
    }
  }
  _actualizarCapaRutasYLabels();
}

  // Función para obtener la ubicación actual
  Future<void> _obtenerUbicacionActual() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool? enabled = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('GPS desactivado'),
            content: Text('¿Quieres activar el servicio de ubicación?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Activar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
        
        if (enabled == true) {
          serviceEnabled = await Geolocator.openLocationSettings();
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw Exception('Permisos permanentemente denegados');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 10),
      );

      if (!mounted) return;

      setState(() {
        _ubicacionActual = LatLng(position.latitude, position.longitude);
        print("Nueva ubicación establecida: $_ubicacionActual");
      });
    } catch (e) {
      print("Error en _obtenerUbicacionActual: $e");
      rethrow;
    }
  }

  // Función para alternar la visibilidad de la ubicación
  void _alternarUbicacionActual() async {
    if (!_mostrarUbicacionActual) {
      try {
        Position posicion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        
        setState(() {
          _ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
          _mostrarUbicacionActual = true;
        });
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    } else {
      setState(() {
        _mostrarUbicacionActual = false;
        _ubicacionActual = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NO USAR'),
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
      body: FlutterMap(
        options: MapOptions(
          center: _ubicacionActual != null 
              ? _ubicacionActual 
              : LatLng(-16.5, -68.11),
          zoom: 12.7,
          onTap: (tapPosition, point) async {
            if (_mostrandoMST) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Para agregar nuevos puntos, primero muestra todas las rutas."),
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }

            int nuevoNodoIndex = _nodos.length;

            setState(() {
              _nodos.add(point);
              _coloresNodos.add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
            });

            if (_nodos.length > 1) {

              for (int i = 0; i < _nodos.length - 1; i++) {
                
                await obtenerRutaGraphHopper(_nodos[i], point, _coloresNodos[i], i, nuevoNodoIndex);
              }
            }
          },
        ),
        children: [
          // Capa de mapa base
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          
          // Capa de polilíneas (rutas)
          PolylineLayer(polylines: _rutas),
          
          // Capa de etiquetas de peso
          MarkerLayer(markers: _pesoLabels),
          
          // Capa de marcadores de nodos
          MarkerLayer(
            markers: _nodos.asMap().entries.map((entry) {
              return Marker(
                point: entry.value,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onLongPress: () {
                    if (_mostrandoMST) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Para eliminar puntos, primero muestra todas las rutas."),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    _mostrarDialogoEliminar(context, entry.key);
                  },
                  child: Center(
                    child: widget.medio =='foot'
                        ? PeatonIcono(size:300, color: _coloresNodos[entry.key], x:x/100, y:y/100)
                        : AutoIcono(color: _coloresNodos[entry.key], x:x/100, y:y/100),
                  )
                ),
              );
            }).toList(),
          ),
          
          // --- NUEVA CAPA PARA UBICACIÓN ACTUAL --- //
          if (_mostrarUbicacionActual && _ubicacionActual != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _ubicacionActual!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'ubicacion',
            onPressed: _alternarUbicacionActual,
            child: Icon(
              _mostrarUbicacionActual ? Icons.location_off : Icons.location_on,
              color: Colors.white,
            ),
            backgroundColor: _mostrarUbicacionActual ? Colors.red : Colors.blue,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {

              if (_nodos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No hay puntos para encontrar una ruta"),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                aplicarKruskal();
              }
            },
            label: const Text('Ruta Corta'),
            icon: const Icon(Icons.shuffle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              if (_mostrandoMST) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Para limpiar, primero muestra todas las rutas."),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }
              if (_nodos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No hay puntos a eliminar"),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                _dialogoBorrarTodo(context);
              }
            },
            label: const Text('Limpiar'),
            icon: const Icon(Icons.delete),
            backgroundColor: const Color(0xFFECBDBF),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {

              if (_nodos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No hay rutas a guardar"),
                    duration: Duration(seconds: 2),
                  )
                );
              } else {
                _guardarRutaActual(context);
              }
            },
            label: const Text('Guardar'),
            icon: const Icon(Icons.save),
            backgroundColor: const Color(0xFFDBC557),
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
            isActive: widget.medio == 'foot',
            onTap: () {
              if (widget.medio != 'foot') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapaLaPaz(medio: 'foot'),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.directions_car,
            title: 'Recorrido en auto',
            isActive: widget.medio == 'car',
            onTap: () {
              if (widget.medio != 'car') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapaLaPaz(medio: 'car'),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
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
          // Menú desplegable principal para "lugares"
          _buildExpansionTile(
            context,
            icon: Icons.accessibility_new,
            title: 'Lugares',
            children: [
              // Submenú para Comida
              _buildExpansionTile(
                context,
                icon: Icons.restaurant,
                title: 'Comida',
                children: [
                  _buildSubMenuItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Mi Chola Restaurant',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.50830, -68.12847),
                      Colors.red,
                      'Mi Chola Restaurant',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Brosso',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.50060, -68.13296),
                      Colors.red,
                      'Brosso',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Mercado Lanza',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.4965, -68.1342),
                      Colors.red,
                      'Mercado Lanza',
                    ),
                  ),
                ],
              ),
              // Submenú para Hoteles
              _buildExpansionTile(
                context,
                icon: Icons.hotel,
                title: 'Hoteles',
                children: [
                  _buildSubMenuItem(
                    context,
                    icon: Icons.king_bed,
                    title: 'Hotel Presidente',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.49573, -68.14591),
                      Colors.purple,
                      'Hotel Presidente',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.king_bed,
                    title: 'Casa Grande',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.5127, -68.1198),
                      Colors.purple,
                      'Casa Grande',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.king_bed,
                    title: 'Hotel Europa',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.50226, -68.13085),
                      Colors.purple,
                      'Hotel Europa',
                    ),
                  ),
                ],
              ),
              // Submenú para Lugares turísticos
              _buildExpansionTile(
                context,
                icon: Icons.place,
                title: 'Atracciones',
                children: [
                  _buildSubMenuItem(
                    context,
                    icon: Icons.landscape,
                    title: 'Valle de la Luna',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.5525, -68.0697),
                      Colors.blue,
                      'Valle de la Luna',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.park,
                    title: 'Parque Purapura',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.48526, -68.15180),
                      Colors.blue,
                      'Parque Purapura',
                    ),
                  ),
                  _buildSubMenuItem(
                    context,
                    icon: Icons.church,
                    title: 'San Francisco',
                    onTap: () => _agregarMarcador(
                      context,
                      const LatLng(-16.49614, -68.13718),
                      Colors.blue,
                      'San Francisco',
                    ),
                  ),
                ],
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

  // Función para agregar marcadores al mapa
  void _agregarMarcador(BuildContext context, LatLng coordenadas, Color color, String nombreLugar) {
    Navigator.pop(context); // Cierra el drawer
    
    setState(() {
      // Agrega el nuevo nodo
      _nodos.add(coordenadas);
      _coloresNodos.add(color);
      
      // Muestra un mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marcador de $nombreLugar agregado'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Si hay más de un nodo, calcula las rutas
      if (_nodos.length > 1) {
        for (int i = 0; i < _nodos.length - 1; i++) {
          obtenerRutaGraphHopper(
            _nodos[i],
            coordenadas,
            _coloresNodos[i],
            i,
            _nodos.length - 1,
          );
        }
      }
    });
  }

  // Widget para ExpansionTile personalizado
  Widget _buildExpansionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    bool isHovered = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFECBDBF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              leading: Icon(icon, color: const Color(0xFF3D8B7D)),
              title: Text(title, style: const TextStyle(color: Colors.black87)),
              children: children,
            ),
          ),
        );
      },
    );
  }

  // Widget para los ítems del submenú
  Widget _buildSubMenuItem(
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
          child: Container(
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFECBDBF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(icon, color: const Color(0xFF3D8B7D)),
              title: Text(title, style: const TextStyle(color: Colors.black87)),
              onTap: onTap,
              contentPadding: const EdgeInsets.only(left: 64.0),
              dense: true,
            ),
          ),
        );
      },
    );
  }

Future<void> _guardarRutaActual(BuildContext context) async {
  // Mostrar diálogo para ingresar el nombre
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

  if (nombre == null || nombre.isEmpty) return;

  // Armar el objeto ruta
  final rutaActual = {
    'medio':widget.medio,
    'nombre': nombre,
    'fecha': DateTime.now().toIso8601String(),
    'nodos': _nodos.map((n) => {'lat': n.latitude, 'lng': n.longitude}).toList(),
    'edges': _edges.map((e) => {
      'from': e.from,
      'to': e.to,
      'weight': e.weight,
      'ruta': e.ruta.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'labelPoint': {'lat': e.labelPoint.latitude, 'lng': e.labelPoint.longitude},
      'labelText': e.labelText,
      'color': e.color.value,
      'descripcionApi': e.descripcionApi,
    }).toList(),
    'mstEdges': _mstEdges.map((e) => {
      'from': e.from,
      'to': e.to,
      'weight': e.weight,
      'ruta': e.ruta.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'labelPoint': {'lat': e.labelPoint.latitude, 'lng': e.labelPoint.longitude},
      'labelText': e.labelText,
      'color': e.color.value,
      'descripcionApi': e.descripcionApi,
    }).toList(),
    'coloresNodos': _coloresNodos.map((c) => c.value).toList(),
  };

  // Guardar en SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final rutasGuardadas = prefs.getStringList('rutas_guardadas') ?? [];
  rutasGuardadas.add(jsonEncode(rutaActual));
  await prefs.setStringList('rutas_guardadas', rutasGuardadas);

  if (!context.mounted) return;

  // Mostrar notificación
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Ruta "$nombre" guardada correctamente'),
      duration: const Duration(seconds: 2),
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

  Future<void> obtenerRutaGraphHopper(LatLng start, LatLng end, Color color, int startIndex, int endIndex) async {
    final url = Uri.parse(
        'https://graphhopper.com/api/1/route'
        '?point=${start.latitude},${start.longitude}'
        '&point=${end.latitude},${end.longitude}'
        '&vehicle=${widget.medio}&locale=es&points_encoded=false&key=$graphhopperApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paths'] == null || data['paths'].isEmpty) {
          print('No se encontró ruta entre ${start.toString()} y ${end.toString()}');
          return;
        }
        final List<dynamic> coords = data['paths'][0]['points']['coordinates'];
        final List<LatLng> ruta = coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();

        double duracion = data['paths'][0]['time'] / 60000.0; // Convertir milisegundos a minutos
        final midIndex = (ruta.length / 2).floor();
        final midPoint = ruta.isNotEmpty ? ruta[midIndex] : start; // Manejar ruta vacía

        String unidad = duracion > 60 ? 'hrs' : 'mins';
        double duracionMostrar = duracion > 60 ? duracion / 60.0 : duracion;

        Edge nuevaArista = Edge(
          startIndex, // Índice del nodo de inicio en _nodos
          endIndex,   // Índice del nodo de fin en _nodos
          duracion,
          ruta,
          midPoint,
          '${duracionMostrar.toStringAsFixed(1)} $unidad',
          color,
        );

        if (!mounted) return;
        setState(() {
          _edges.add(nuevaArista);
          _actualizarCapaRutasYLabels(); // Actualización centralizada
        });
        print('Ruta agregada (${startIndex} -> ${endIndex}): ${nuevaArista.labelText}');
      } else {
        print('Error al obtener la ruta de GraphHopper: ${response.statusCode}');
        print(response.body);
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error GraphHopper (${response.statusCode}) al obtener ruta.')),
        );
      }
    } catch (e) {
      print('Excepción al obtener la ruta de GraphHopper: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción GraphHopper: $e')),
      );
    }
  }

  Future<void> obtenerDescripcionRutaAPI(Edge edge) async {
    if (edge.ruta.isEmpty) {
      print("No se puede obtener descripción para una ruta vacía.");
      return;
    }

    // Usar el primer y último punto de la lista 'ruta' de la arista
    LatLng inicio = edge.ruta.first;
    LatLng fin = edge.ruta.last;

    try {
      final response = await http.post(
        Uri.parse('$miApiBaseUrl/describir_ruta'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, double>{
          'latitud_inicio': inicio.latitude,
          'longitud_inicio': inicio.longitude,
          'latitud_fin': fin.latitude,
          'longitud_fin': fin.longitude,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String descripcion = data['descripcion'] ?? "Descripción no disponible.";

        setState(() {
          // Actualizar la arista específica en _mstEdges con la descripción
          int mstEdgeIndex = _mstEdges.indexWhere((e) =>
              e.from == edge.from && e.to == edge.to && e.weight == edge.weight);
          if (mstEdgeIndex != -1) {
            _mstEdges[mstEdgeIndex] = _mstEdges[mstEdgeIndex].copyWith(descripcionApi: descripcion);
            print('Descripción API para ${edge.from}-${edge.to}: $descripcion');
            _actualizarCapaRutasYLabels(); // Reconstruir etiquetas para que el onTap funcione
          } else {
             print('Error: No se encontró la arista en _mstEdges para actualizar descripción.');
          }
        });
      } else {
        print('Error API /describir_ruta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error API Descripción (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('Excepción al llamar a API /describir_ruta: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción llamando a API: $e')),
      );
    }
  }

  void aplicarKruskal() async {
    if (_mostrandoMST) {
      setState(() {
        _mostrandoMST = false;
        _mstEdges.clear(); // Limpiar las aristas específicas del MST
        _actualizarCapaRutasYLabels(); // Mostrar todas las aristas de _edges
      });
      return;
    }

    if (_nodos.length < 2) return;

    List<Edge> mstTemporal = [];
    List<int> parent = List.generate(_nodos.length, (i) => i);

    int find(int i) {
      if (parent[i] == i) return i;
      return parent[i] = find(parent[i]); // Compresión de camino
    }

    void union(int i, int j) {
      int rootI = find(i);
      int rootJ = find(j);
      if (rootI != rootJ) {
        parent[rootI] = rootJ;
      }
    }

    // Crear una copia de _edges para ordenarla, ya que _edges se usa para mostrar todas las rutas
    List<Edge> aristasOrdenadas = List.from(_edges);
    aristasOrdenadas.sort((a, b) => a.weight.compareTo(b.weight));

    for (var edge in aristasOrdenadas) {
      // Asegurarse que los índices 'from' y 'to' son válidos para la lista 'parent'
      if (edge.from < _nodos.length && edge.to < _nodos.length) {
        if (find(edge.from) != find(edge.to)) {
          union(edge.from, edge.to);
          mstTemporal.add(edge);
        }
      } else {
        print("Error: Índices de arista fuera de rango. From: ${edge.from}, To: ${edge.to}, Nodos: ${_nodos.length}");
      }
    }

    if (!mounted) return;
    setState(() {
      _mostrandoMST = true;
      _mstEdges = List.from(mstTemporal); // Guardar las aristas del MST
      _actualizarCapaRutasYLabels(); // Mostrar solo las aristas del MST
    });

    // Obtener descripciones para las aristas del MST
    for (var edge in _mstEdges) {
       await obtenerDescripcionRutaAPI(edge);
    }
  }

  void _actualizarCapaRutasYLabels() {
    if (!mounted) return;

    if (_mostrandoMST) {
      _rutas = _mstEdges.map((e) => Polyline(
        points: e.ruta,
        color: Colors.green,
        strokeWidth: 6,
      )).toList();

      _pesoLabels = _mstEdges.map((edge) {
        return Marker(
          point: edge.labelPoint,
          width: 120, // Ajusta según sea necesario
          height: 40, // Aumentado para mejor toque
          child: GestureDetector(
            onTap: () {
              if (edge.descripcionApi != null && edge.descripcionApi!.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Descripción de la Ruta"),
                    content: SingleChildScrollView(child: Text(edge.descripcionApi!)),
                    actions: [
                      TextButton(
                        child: const Text("Cerrar"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Descripción no disponible o aún cargando.")),
                );
              }
            },
            child:Row(
              children:[
                Icon(
                  Icons.info,
                  color:Colors.red,
                  ),
            Text(
              
                edge.labelText,
                
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              ]
            )
          ),
        );
      }).toList();
    } else {
      // Mostrar todas las rutas de _edges
      _rutas = _edges.map((e) => Polyline(
        points: e.ruta,
        color: e.color,
        strokeWidth: 4,
      )).toList();
      _pesoLabels = _edges.map((e) => Marker(
        point: e.labelPoint,
        width: 120,
        height: 30,
        child:  Text(
          
              e.labelText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                backgroundColor:Colors.white),
              overflow: TextOverflow.ellipsis,
              
            ),
        
      )).toList();
    }
  }

  void _dialogoBorrarTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Todo"),
          content: const Text("¿Deseas eliminar todos los puntos y rutas?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _nodos.clear();
                  _rutas.clear();
                  _pesoLabels.clear();
                  _coloresNodos.clear();
                  _edges.clear();
                  _mstEdges.clear();
                  _mostrandoMST = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, int indexToRemove) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Marcador"),
          content: const Text("¿Deseas eliminar este marcador y sus rutas asociadas?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _nodos.removeAt(indexToRemove);
                  _coloresNodos.removeAt(indexToRemove);

                  // Eliminar aristas conectadas al nodo eliminado
                  _edges.removeWhere((edge) => edge.from == indexToRemove || edge.to == indexToRemove);

                  // Re-indexar las aristas restantes
                  List<Edge> updatedEdges = [];
                  for (var edge in _edges) {
                    int newFrom = edge.from > indexToRemove ? edge.from - 1 : edge.from;
                    int newTo = edge.to > indexToRemove ? edge.to - 1 : edge.to;
                    updatedEdges.add(edge.copyWith(from: newFrom, to: newTo));
                  }
                  _edges = updatedEdges;

                  // Si se estaba mostrando el MST, es mejor recalcular o volver a la vista de todas las rutas
                  if (_mostrandoMST) {
                    _mostrandoMST = false;
                    _mstEdges.clear();
                  }
                  _actualizarCapaRutasYLabels(); // Re-renderizar
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // La función _recalcularRutas ya no es necesaria con el enfoque incremental actual
  // y la lógica de eliminación actualizada.
}