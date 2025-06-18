import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/lugares/lugar.dart';
import 'package:routas_lapaz/lugares/lugares_notifier.dart';
import 'package:routas_lapaz/mapa/mapa_screen.dart';

class LugaresPage extends ConsumerWidget {
  const LugaresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lugares = ref.watch(lugaresNotifierProvider);

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
              children: lugares.map((lugar) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: _buildPlaceButton(context, lugar),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceButton(BuildContext context, Lugar lugar) {
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
                lugar.imagePath,
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
                      'nodos': [{'lat': lugar.coords.latitude, 'lng': lugar.coords.longitude}],
                      'edges': [],
                      'mstEdges': [],
                      'coloresNodos': [Colors.red.value],
                      'medio': 'foot',
                    },
              },
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
              lugar.nombre,
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
