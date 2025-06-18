import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/sugerencias/sugerencia.dart';
import '../lugares/lugares_page.dart';
import '../comida/comida_page.dart';
import '../hoteles/hoteles_page.dart';

class SugerenciasNotifier extends StateNotifier<List<Sugerencia>> {
  SugerenciasNotifier() : super([]);

  void cargarSugerencias() {
    state = [
      Sugerencia(
        titulo: 'Lugares Turísticos',
        imagePath: 'assets/lugares.jpg',
        page: const LugaresPage(),
      ),
      Sugerencia(
        titulo: 'Lugares de Comida',
        imagePath: 'assets/comida.jpg',
        page: const ComidaPage(),
      ),
      Sugerencia(
        titulo: 'Hoteles Recomendados',
        imagePath: 'assets/hoteles.jpg',
        page: const HotelesPage(),
      ),
    ];
  }
}

final sugerenciasProvider =
    StateNotifierProvider<SugerenciasNotifier, List<Sugerencia>>((ref) {
  final notifier = SugerenciasNotifier();
  notifier.cargarSugerencias();
  return notifier;
});
