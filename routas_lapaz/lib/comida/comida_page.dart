import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routas_lapaz/comida/comida.dart';
import 'package:routas_lapaz/comida/comida_notifier.dart';
import 'package:routas_lapaz/mapa.dart';

class ComidaPage extends ConsumerWidget {
  const ComidaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comidas = ref.watch(comidaNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('River Lugares de Comida'),
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
              children: comidas.map((comida) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: _buildFoodButton(context, comida),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodButton(BuildContext context, Comida comida) {
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
                comida.imagePath,
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
                      'nodos': [{'lat': comida.coords.latitude, 'lng': comida.coords.longitude}],
                      'edges': [],
                      'mstEdges': [],
                      'coloresNodos': [Colors.red.value],
                      'medio': 'foot',
                    },
              },
            );

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFECBDBF).withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: Text(
              comida.nombre,
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
