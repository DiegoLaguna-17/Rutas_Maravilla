import 'package:latlong2/latlong.dart';

class Comida {
  final String nombre;
  final String imagePath;
  final LatLng coords;

  Comida({
    required this.nombre,
    required this.imagePath,
    required this.coords,
  });
}
