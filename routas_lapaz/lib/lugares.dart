import 'package:flutter/material.dart';
import 'package:routas_lapaz/mapa.dart';
import 'package:latlong2/latlong.dart';

class LugaresPage extends StatelessWidget {
  const LugaresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares Turísticos'),
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
                _buildPlaceButton(
                  context,
                  imagePath: 'assets/valle_luna.jpg',
                  text: 'Valle de la Luna',
                  coords: const LatLng(-16.5525, -68.0697),
                ),
                const SizedBox(height: 30),
                _buildPlaceButton(
                  context,
                  imagePath: 'assets/parque_purapura.jpg',
                  text: 'Parque Pura Pura',
                  coords: const LatLng(-16.48526, -68.15180),
                ),
                const SizedBox(height: 30),
                _buildPlaceButton(
                  context,
                  imagePath: 'assets/san_francisco.jpg',
                  text: 'Iglesia San Francisco',
                  coords: const LatLng(-16.49614, -68.13718),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceButton(BuildContext context, {
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
                    medio: 'foot',
                    rutaGuardada: {
                      'nodos': [{'lat': coords.latitude, 'lng': coords.longitude}],
                      'edges': [],
                      'mstEdges': [],
                      'coloresNodos': [Colors.blue.value],
                      'medio': 'foot',
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3D8B7D).withOpacity(0.9),
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}