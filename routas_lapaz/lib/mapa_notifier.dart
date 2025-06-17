import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mapa_state.dart';

class MapaNotifier extends StateNotifier<MapaState> {
  MapaNotifier({required String medio})
      : _random = Random(),
        super(MapaState.inicial(medio: medio));

  final Random _random;
  static const String _graphhopperApiKey = '63b19cd4-a9f9-47bd-a58b-0273d67721fa';
  static const String _apiBaseUrl = 'https://api-descripcion-xs5h.vercel.app';

  // Cargar estado inicial desde datos guardados
  Future<void> cargarRutaGuardada(Map<String, dynamic>? rutaGuardada) async {
    if (rutaGuardada == null) return;

    try {
      state = state.copyWith(isLoading: true);

      final nuevosNodos = (rutaGuardada['nodos'] as List)
          .map((n) => LatLng(n['lat'], n['lng']))
          .toList();

      final nuevosColores = (rutaGuardada['coloresNodos'] as List)
          .map((v) => Color(v))
          .toList();

      final nuevasEdges = (rutaGuardada['edges'] as List)
          .map((e) => Edge.fromMap(e))
          .toList();

      final nuevasMstEdges = (rutaGuardada['mstEdges'] as List)
          .map((e) => Edge.fromMap(e))
          .toList();

      state = state.copyWith(
        nodos: nuevosNodos,
        coloresNodos: nuevosColores,
        edges: nuevasEdges,
        mstEdges: nuevasMstEdges,
        isLoading: false,
      );

      _actualizarCapaRutasYLabels();
    } catch (e) {
      state = state.copyWith(
        error: 'Error al cargar ruta: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Manejo de ubicación
  Future<void> alternarUbicacionActual() async {
    if (!state.mostrarUbicacion) {
      try {
        state = state.copyWith(isLoading: true);
        
        final posicion = await _obtenerPosicionActual();
        final nuevaUbicacion = LatLng(posicion.latitude, posicion.longitude);
        
        state = state.copyWith(
          ubicacionActual: nuevaUbicacion,
          mostrarUbicacion: true,
          isLoading: false,
        );
      } catch (e) {
        state = state.copyWith(
          error: 'Error al obtener ubicación: ${e.toString()}',
          isLoading: false,
        );
      }
    } else {
      state = state.copyWith(
        mostrarUbicacion: false,
        ubicacionActual: null,
      );
    }
  }

  Future<Position> _obtenerPosicionActual() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw Exception('Servicio de ubicación desactivado');
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw Exception('Permisos permanentemente denegados');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  // Manejo de nodos y rutas
  Future<void> agregarNodo(LatLng punto) async {
    if (state.mostrandoMST) return;

    final nuevoIndex = state.nodos.length;
    final nuevoColor = Colors.primaries[_random.nextInt(Colors.primaries.length)];

    state = state.copyWith(
      nodos: [...state.nodos, punto],
      coloresNodos: [...state.coloresNodos, nuevoColor],
    );

    if (state.nodos.length > 1) {
      for (int i = 0; i < state.nodos.length - 1; i++) {
        await obtenerRutaGraphHopper(
          state.nodos[i],
          punto,
          state.coloresNodos[i],
          i,
          nuevoIndex,
        );
      }
    }
  }

  Future<void> obtenerRutaGraphHopper(
    LatLng start,
    LatLng end,
    Color color,
    int startIndex,
    int endIndex,
  ) async {
    final url = Uri.parse(
      'https://graphhopper.com/api/1/route'
      '?point=${start.latitude},${start.longitude}'
      '&point=${end.latitude},${end.longitude}'
      '&vehicle=${state.medio}&locale=es&points_encoded=false&key=$_graphhopperApiKey',
    );

    try {
      state = state.copyWith(isLoading: true);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['paths'] == null || data['paths'].isEmpty) {
          throw Exception('No se encontró ruta entre los puntos');
        }

        final coords = data['paths'][0]['points']['coordinates'] as List;
        final ruta = coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
        final duracion = data['paths'][0]['time'] / 60000.0;
        final midPoint = ruta.isNotEmpty ? ruta[ruta.length ~/ 2] : start;

        final (unidad, duracionMostrar) = duracion > 60
            ? ('hrs', duracion / 60.0)
            : ('mins', duracion);

        final nuevaArista = Edge(
          startIndex,
          endIndex,
          duracion,
          ruta,
          midPoint,
          '${duracionMostrar.toStringAsFixed(1)} $unidad',
          color,
        );

        state = state.copyWith(
          edges: [...state.edges, nuevaArista],
          isLoading: false,
        );
        _actualizarCapaRutasYLabels();
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al obtener ruta: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Algoritmo Kruskal
  void aplicarKruskal() {
    if (state.mostrandoMST) {
      state = state.copyWith(
        mostrandoMST: false,
        mstEdges: [],
      );
      _actualizarCapaRutasYLabels();
      return;
    }

    if (state.nodos.length < 2) {
      state = state.copyWith(error: 'Se necesitan al menos 2 nodos');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      final parent = List.generate(state.nodos.length, (i) => i);

      int find(int i) => parent[i] == i ? i : (parent[i] = find(parent[i]));

      void union(int i, int j) {
        final rootI = find(i);
        final rootJ = find(j);
        if (rootI != rootJ) parent[rootI] = rootJ;
      }

      final aristasOrdenadas = List<Edge>.from(state.edges)
        ..sort((a, b) => a.weight.compareTo(b.weight));

      final mstTemporal = <Edge>[];
      for (final edge in aristasOrdenadas) {
        if (edge.from < state.nodos.length && edge.to < state.nodos.length) {
          if (find(edge.from) != find(edge.to)) {
            union(edge.from, edge.to);
            mstTemporal.add(edge);
          }
        }
      }

      state = state.copyWith(
        mostrandoMST: true,
        mstEdges: mstTemporal,
        isLoading: false,
      );
      _actualizarCapaRutasYLabels();

      // Obtener descripciones para las nuevas aristas
      _obtenerDescripcionesMST();
    } catch (e) {
      state = state.copyWith(
        error: 'Error en Kruskal: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> _obtenerDescripcionesMST() async {
    for (final edge in state.mstEdges) {
      if (edge.descripcionApi == null) {
        await obtenerDescripcionRutaAPI(edge);
      }
    }
  }

  Future<void> obtenerDescripcionRutaAPI(Edge edge) async {
    if (edge.ruta.isEmpty) return;

    try {
      final inicio = edge.ruta.first;
      final fin = edge.ruta.last;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/describir_ruta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitud_inicio': inicio.latitude,
          'longitud_inicio': inicio.longitude,
          'latitud_fin': fin.latitude,
          'longitud_fin': fin.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final descripcion = data['descripcion'] ?? "Descripción no disponible";

        final nuevasMstEdges = state.mstEdges.map((e) {
          return e.from == edge.from && e.to == edge.to && e.weight == edge.weight
              ? e.copyWith(descripcionApi: descripcion)
              : e;
        }).toList();

        state = state.copyWith(mstEdges: nuevasMstEdges);
        _actualizarCapaRutasYLabels();
      } else {
        throw Exception('Error API ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al obtener descripción: ${e.toString()}',
      );
    }
  }

  // Persistencia
  Future<void> guardarRutaActual(String nombre) async {
    if (state.nodos.isEmpty) {
      state = state.copyWith(error: 'No hay rutas para guardar');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      final rutasGuardadas = prefs.getStringList('rutas_guardadas') ?? [];

      final rutaActual = state.toMap()
        ..addAll({
          'nombre': nombre,
          'fecha': DateTime.now().toIso8601String(),
        });

      rutasGuardadas.add(jsonEncode(rutaActual));
      await prefs.setStringList('rutas_guardadas', rutasGuardadas);

      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error al guardar: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  // Limpieza
  void eliminarNodo(int index) {
    if (state.mostrandoMST || index >= state.nodos.length) return;

    final nuevosNodos = List<LatLng>.from(state.nodos)..removeAt(index);
    final nuevosColores = List<Color>.from(state.coloresNodos)..removeAt(index);

    // Actualizar índices en las aristas
    final nuevasEdges = state.edges
        .where((e) => e.from != index && e.to != index)
        .map((e) {
          final nuevoFrom = e.from > index ? e.from - 1 : e.from;
          final nuevoTo = e.to > index ? e.to - 1 : e.to;
          return e.copyWith(from: nuevoFrom, to: nuevoTo);
        })
        .toList();

    state = state.copyWith(
      nodos: nuevosNodos,
      coloresNodos: nuevosColores,
      edges: nuevasEdges,
      mstEdges: [],
      mostrandoMST: false,
    );
    _actualizarCapaRutasYLabels();
  }

  void limpiarTodo() {
    state = MapaState.inicial(medio: state.medio);
  }

  // Helpers
  void _actualizarCapaRutasYLabels() {
    // Esta función ahora es manejada por la UI basada en el estado actual
    // Se mantiene por compatibilidad pero no modifica el estado directamente
  }

  // Manejo de errores
  void limpiarError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void agregarMarcadorPredefinido(LatLng coordenadas, Color color, String nombreLugar) {
    // Evitar duplicados
    if (state.nodos.contains(coordenadas)) {
      return;
    }

    final nuevoIndex = state.nodos.length;
    
    state = state.copyWith(
      nodos: [...state.nodos, coordenadas],
      coloresNodos: [...state.coloresNodos, color],
    );

    // Calcular rutas desde otros nodos existentes
    if (state.nodos.length > 1) {
      for (int i = 0; i < state.nodos.length - 1; i++) {
        obtenerRutaGraphHopper(
          state.nodos[i],
          coordenadas,
          state.coloresNodos[i],
          i,
          nuevoIndex,
        );
      }
    }
  }
  void actualizarMedio(String nuevoMedio) {
    state = state.copyWith(medio: nuevoMedio);
  }
}

final mapaProvider = StateNotifierProvider<MapaNotifier, MapaState>((ref) {
  throw UnimplementedError('Debe ser sobreescrito con el medio correcto');
});