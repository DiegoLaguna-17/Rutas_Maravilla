import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/hoteles/hotel.dart';
import 'package:routas_lapaz/hoteles/hoteles_notifier.dart';
import 'package:routas_lapaz/mapa/mapa_screen.dart';

class HotelesPage extends ConsumerWidget {
  const HotelesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoteles = ref.watch(hotelesNotifierProvider);

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
              children: hoteles.map((hotel) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: _buildHotelButton(context, hotel),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelButton(BuildContext context, Hotel hotel) {
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
                hotel.imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
             Navigator.pushNamed(
              context,
              '/mapa',
              arguments: {
                'medio': 'foot', // o simplemente 'car' si quieres fijo
                'rutaGuardada': {
                  'nodos': [
                    {'lat': hotel.coords.latitude, 'lng': hotel.coords.longitude}
                  ],
                  'edges': [],
                  'mstEdges': [],
                  'coloresNodos': [Colors.purple.value],
                  // 'medio' no va aquí dentro, porque ya lo mandas arriba
                },
              },
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
              hotel.name,
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
