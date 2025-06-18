import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/comida/comida.dart';
import 'package:latlong2/latlong.dart';

class ComidaNotifier extends StateNotifier<List<Comida>> {
  ComidaNotifier() : super([]);

  void cargarComidas() {
    state = [
      Comida(
        nombre: 'Mi Chola Restaurant',
        imagePath: 'assets/mi_chola.jpg',
        coords: const LatLng(-16.50830, -68.12847),
      ),
      Comida(
        nombre: 'Brosso',
        imagePath: 'assets/brosso.jpg',
        coords: const LatLng(-16.50060, -68.13296),
      ),
      Comida(
        nombre: 'Mercado Lanza',
        imagePath: 'assets/mercado_lanza.jpg',
        coords: const LatLng(-16.4965, -68.1342),
      ),
    ];
  }
}

final comidaNotifierProvider = StateNotifierProvider<ComidaNotifier, List<Comida>>((ref) {
  final notifier = ComidaNotifier();
  notifier.cargarComidas();
  return notifier;
});
