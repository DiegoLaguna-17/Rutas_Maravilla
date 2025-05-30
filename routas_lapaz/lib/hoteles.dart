import 'package:flutter/material.dart';
import 'package:routas_lapaz/mapa.dart';
import 'package:latlong2/latlong.dart';

class HotelesPage extends StatelessWidget {
  const HotelesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoteles Recomendados'),
        backgroundColor: const Color(0xFF3D8B7D),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9DFE0),
              Color(0xFF8FBC91),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHotelButton(
                  context,
                  imagePath: 'assets/hotel_presidente.jpg',
                  text: 'Hotel Presidente',
                  coords: const LatLng(-16.49573, -68.14591),
                ),
                const SizedBox(height: 30),
                _buildHotelButton(
                  context,
                  imagePath: 'assets/casa_grande.jpg',
                  text: 'Casa Grande',
                  coords: const LatLng(-16.5127, -68.1198),
                ),
                const SizedBox(height: 30),
                _buildHotelButton(
                  context,
                  imagePath: 'assets/hotel_europa.jpg',
                  text: 'Hotel Europa',
                  coords: const LatLng(-16.50226, -68.13085),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelButton(BuildContext context, {
    required String imagePath,
    required String text,
    required LatLng coords,
  }) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapaLaPaz(
                    medio: 'car',
                    rutaGuardada: {
                      'nodos': [{'lat': coords.latitude, 'lng': coords.longitude}],
                      'edges': [],
                      'mstEdges': [],
                      'coloresNodos': [Colors.purple.value],
                      'medio': 'car',
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDBC557).withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}