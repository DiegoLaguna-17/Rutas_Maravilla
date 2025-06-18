// archivo: lib/notifiers/mis_rutas_notifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routas_lapaz/mis_rutas/mis_rutas_state.dart';

final misRutasProvider =
    StateNotifierProvider<MisRutasNotifier, MisRutasState>((ref) {
  return MisRutasNotifier();
});

class MisRutasNotifier extends StateNotifier<MisRutasState> {
  MisRutasNotifier() : super(const MisRutasState()) {
    cargarRutas();
  }

  Future<void> cargarRutas() async {
    final prefs = await SharedPreferences.getInstance();
    final rutasJson = prefs.getStringList('rutas_guardadas') ?? [];
    final rutas = rutasJson
        .map((r) => jsonDecode(r) as Map<String, dynamic>)
        .toList();
    state = state.copyWith(rutas: rutas);
  }

  Future<void> eliminarRuta(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rutasGuardadas = prefs.getStringList('rutas_guardadas') ?? [];

    if (index >= 0 && index < rutasGuardadas.length) {
      rutasGuardadas.removeAt(index);
      await prefs.setStringList('rutas_guardadas', rutasGuardadas);
      cargarRutas();
    }
  }
  
} 
