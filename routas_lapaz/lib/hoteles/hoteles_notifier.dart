import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/hoteles/hotel.dart';
import 'package:latlong2/latlong.dart';

class HotelesNotifier extends StateNotifier<List<Hotel>> {
  HotelesNotifier() : super([]);

  void cargarHoteles() {
    state = [
      Hotel(
        name: 'Hotel Presidente',
        imagePath: 'assets/hotel_presidente.jpg',
        coords: const LatLng(-16.49573, -68.14591),
      ),
      Hotel(
        name: 'Casa Grande',
        imagePath: 'assets/casa_grande.jpg',
        coords: const LatLng(-16.5127, -68.1198),
      ),
      Hotel(
        name: 'Hotel Europa',
        imagePath: 'assets/hotel_europa.jpg',
        coords: const LatLng(-16.50226, -68.13085),
      ),
    ];
  }
}

final hotelesNotifierProvider = StateNotifierProvider<HotelesNotifier, List<Hotel>>((ref) {
  final notifier = HotelesNotifier();
  notifier.cargarHoteles();
  return notifier;
});
