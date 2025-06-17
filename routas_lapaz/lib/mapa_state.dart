import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Edge {
  final int from; // Índice en la lista de nodos
  final int to;   // Índice en la lista de nodos
  final double weight;
  final List<LatLng> ruta;
  final LatLng labelPoint;
  final String labelText;
  final Color color;
  final String? descripcionApi;

  Edge(
    this.from,
    this.to,
    this.weight,
    this.ruta,
    this.labelPoint,
    this.labelText,
    this.color, {
    this.descripcionApi,
  });

  Edge copyWith({
    int? from,
    int? to,
    double? weight,
    List<LatLng>? ruta,
    LatLng? labelPoint,
    String? labelText,
    Color? color,
    String? descripcionApi,
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

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'weight': weight,
      'ruta': ruta.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'labelPoint': {'lat': labelPoint.latitude, 'lng': labelPoint.longitude},
      'labelText': labelText,
      'color': color.value,
      'descripcionApi': descripcionApi,
    };
  }

  factory Edge.fromMap(Map<String, dynamic> map) {
    return Edge(
      map['from'] as int,
      map['to'] as int,
      (map['weight'] as num).toDouble(),
      (map['ruta'] as List).map((p) => LatLng(p['lat'], p['lng'])).toList(),
      LatLng(map['labelPoint']['lat'], map['labelPoint']['lng']),
      map['labelText'] as String,
      Color(map['color'] as int),
      descripcionApi: map['descripcionApi'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Edge &&
        other.from == from &&
        other.to == to &&
        other.weight == weight;
  }

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ weight.hashCode;
}

class MapaState {
  final List<LatLng> nodos;
  final List<Color> coloresNodos;
  final List<Edge> edges;
  final List<Edge> mstEdges;
  final bool mostrandoMST;
  final LatLng? ubicacionActual;
  final bool mostrarUbicacion;
  final String medio; // 'foot' o 'car'
  final bool isLoading;
  final String? error;

  const MapaState({
    required this.nodos,
    required this.coloresNodos,
    required this.edges,
    required this.mstEdges,
    this.mostrandoMST = false,
    this.ubicacionActual,
    this.mostrarUbicacion = false,
    required this.medio,
    this.isLoading = false,
    this.error,
  });

  factory MapaState.inicial({required String medio}) {
    return MapaState(
      nodos: [],
      coloresNodos: [],
      edges: [],
      mstEdges: [],
      medio: medio,
    );
  }

  factory MapaState.fromMap(Map<String, dynamic> map, {required String medio}) {
    return MapaState(
      nodos: (map['nodos'] as List)
          .map((n) => LatLng(n['lat'], n['lng']))
          .toList(),
      coloresNodos: (map['coloresNodos'] as List)
          .map((v) => Color(v as int))
          .toList(),
      edges: (map['edges'] as List)
          .map((e) => Edge.fromMap(e))
          .toList(),
      mstEdges: (map['mstEdges'] as List)
          .map((e) => Edge.fromMap(e))
          .toList(),
      medio: medio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medio': medio,
      'nodos': nodos.map((n) => {'lat': n.latitude, 'lng': n.longitude}).toList(),
      'edges': edges.map((e) => e.toMap()).toList(),
      'mstEdges': mstEdges.map((e) => e.toMap()).toList(),
      'coloresNodos': coloresNodos.map((c) => c.value).toList(),
    };
  }

  MapaState copyWith({
    List<LatLng>? nodos,
    List<Color>? coloresNodos,
    List<Edge>? edges,
    List<Edge>? mstEdges,
    bool? mostrandoMST,
    LatLng? ubicacionActual,
    bool? mostrarUbicacion,
    String? medio,
    bool? isLoading,
    String? error,
  }) {
    return MapaState(
      nodos: nodos ?? this.nodos,
      coloresNodos: coloresNodos ?? this.coloresNodos,
      edges: edges ?? this.edges,
      mstEdges: mstEdges ?? this.mstEdges,
      mostrandoMST: mostrandoMST ?? this.mostrandoMST,
      ubicacionActual: ubicacionActual ?? this.ubicacionActual,
      mostrarUbicacion: mostrarUbicacion ?? this.mostrarUbicacion,
      medio: medio ?? this.medio,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapaState &&
        other.nodos == nodos &&
        other.coloresNodos == coloresNodos &&
        other.edges == edges &&
        other.mstEdges == mstEdges &&
        other.mostrandoMST == mostrandoMST &&
        other.ubicacionActual == ubicacionActual &&
        other.mostrarUbicacion == mostrarUbicacion &&
        other.medio == medio;
  }

  @override
  int get hashCode {
    return nodos.hashCode ^
        coloresNodos.hashCode ^
        edges.hashCode ^
        mstEdges.hashCode ^
        mostrandoMST.hashCode ^
        ubicacionActual.hashCode ^
        mostrarUbicacion.hashCode ^
        medio.hashCode;
  }

  @override
  String toString() {
    return 'MapaState(nodos: $nodos, edges: ${edges.length}, mstEdges: ${mstEdges.length}, mostrandoMST: $mostrandoMST)';
  }
}