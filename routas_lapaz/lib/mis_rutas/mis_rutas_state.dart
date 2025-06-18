import 'package:equatable/equatable.dart';

class MisRutasState extends Equatable {
  final List<Map<String, dynamic>> rutas;

  const MisRutasState({this.rutas = const []});

  MisRutasState copyWith({
    List<Map<String, dynamic>>? rutas,
  }) {
    return MisRutasState(
      rutas: rutas ?? this.rutas,
    );
  }

  @override
  List<Object> get props => [rutas];
}
