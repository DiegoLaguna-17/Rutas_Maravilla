import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/lugares/lugar.dart';
import 'package:latlong2/latlong.dart';

class LugaresNotifier extends StateNotifier<List<Lugar>> {
  LugaresNotifier() : super([]);

  void cargarLugares() {
    state = [
      Lugar(
        nombre: 'Valle de la Luna',
        imagePath: 'assets/valle_luna.jpg',
        coords: const LatLng(-16.5525, -68.0697),
      ),
      Lugar(
        nombre: 'Parque Pura Pura',
        imagePath: 'assets/parque_purapura.jpg',
        coords: const LatLng(-16.48526, -68.15180),
      ),
      Lugar(
        nombre: 'Iglesia San Francisco',
        imagePath: 'assets/san_francisco.jpg',
        coords: const LatLng(-16.49614, -68.13718),
      ),
    ];
  }
}

final lugaresNotifierProvider = StateNotifierProvider<LugaresNotifier, List<Lugar>>((ref) {
  final notifier = LugaresNotifier();
  notifier.cargarLugares();
  return notifier;
});
