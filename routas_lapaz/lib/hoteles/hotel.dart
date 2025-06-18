import 'package:latlong2/latlong.dart';

class Hotel {
  final String name;
  final String imagePath;
  final LatLng coords;

  Hotel({
    required this.name,
    required this.imagePath,
    required this.coords,
  });
}
