import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/utils/parseo.dart';

class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
  });

  final int id;
  final String nombre;
  final String email;
  final String telefono;

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: Parseo.entero(json['id'] ?? json['cliente_id']),
        nombre: Parseo.texto(
          json['nombrecompleto'] ?? json['nombre'],
          porDefecto: 'Cliente',
        ),
        email: Parseo.texto(json['email']),
        telefono: Parseo.texto(json['telefono']),
      );

  factory Cliente.fromRespuesta(Map<String, dynamic> respuesta) {
    final fuente = _buscarFuente(respuesta);
    if (fuente.isEmpty) {
      final mensaje = Parseo.texto(
        respuesta['message'],
        porDefecto: 'No se pudo obtener la información del cliente.',
      );
      throw ExcepcionApi(mensaje);
    }
    return Cliente.fromJson(fuente);
  }

  static Map<String, dynamic> _buscarFuente(Map<String, dynamic> respuesta) {
    for (final clave in const ['cliente', 'user', 'usuario', 'data']) {
      final candidato = Parseo.mapa(respuesta[clave]);
      if (candidato.isNotEmpty &&
          (candidato.containsKey('id') ||
              candidato.containsKey('cliente_id'))) {
        return candidato;
      }
    }
    if (respuesta.containsKey('id') || respuesta.containsKey('cliente_id')) {
      return respuesta;
    }
    return const <String, dynamic>{};
  }
}
