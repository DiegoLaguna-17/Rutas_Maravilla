import 'package:latlong2/latlong.dart';

class Lugar {
  final String nombre;
  final String imagePath;
  final LatLng coords;

  Lugar({
    required this.nombre,
    required this.imagePath,
    required this.coords,
  });
}
