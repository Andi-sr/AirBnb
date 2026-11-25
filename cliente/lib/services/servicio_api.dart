import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ExcepcionApi implements Exception {
  const ExcepcionApi(this.mensaje, [this.errores = const <String, String>{}]);

  final String mensaje;
  final Map<String, String> errores;

  @override
  String toString() => mensaje;
}

class ServicioApi {
  ServicioApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  static const String urlBase = 'https://api.airbnbmob2.online/api';
  static const Duration _tiempoEspera = Duration(seconds: 20);
  static final ServicioApi instancia = ServicioApi();

  final http.Client _cliente;

  Future<List<Map<String, dynamic>>> obtenerLista(String ruta) async {
    return _comoLista(await _peticion('GET', ruta));
  }

  Future<Map<String, dynamic>> obtenerJson(String ruta) async {
    return _comoMapa(await _peticion('GET', ruta));
  }

  Future<Map<String, dynamic>> enviarFormulario(
    String ruta,
    Map<String, String> datos,
  ) async {
    return _comoMapa(await _peticion('POST', ruta, datos: datos));
  }

  Future<List<Map<String, dynamic>>> enviarFormularioLista(
    String ruta,
    Map<String, String> datos,
  ) async {
    return _comoLista(await _peticion('POST', ruta, datos: datos));
  }

  Future<Map<String, dynamic>> enviarJson(
    String ruta,
    Map<String, String> datos,
  ) async {
    return _comoMapa(
      await _peticion('POST', ruta, datos: datos, esJson: true),
    );
  }

  Future<dynamic> _peticion(
    String metodo,
    String ruta, {
    Map<String, String>? datos,
    bool esJson = false,
  }) async {
    final uri = Uri.parse('$urlBase$ruta');
    final cabeceras = <String, String>{
      'Accept': 'application/json',
      if (esJson) 'Content-Type': 'application/json; charset=utf-8',
    };

    try {
      final respuesta = metodo == 'GET'
          ? await _cliente
              .get(uri, headers: cabeceras)
              .timeout(_tiempoEspera)
          : await _cliente
              .post(
                uri,
                headers: cabeceras,
                body: esJson ? jsonEncode(datos ?? const {}) : datos ?? const {},
              )
              .timeout(_tiempoEspera);
      return _interpretar(respuesta);
    } on ExcepcionApi {
      rethrow;
    } on TimeoutException {
      throw const ExcepcionApi('Tiempo de espera agotado. Intenta de nuevo.');
    } on http.ClientException {
      throw const ExcepcionApi('No se pudo conectar con el servidor.');
    } on FormatException {
      throw const ExcepcionApi('El servidor devolvió una respuesta inválida.');
    }
  }

  dynamic _interpretar(http.Response respuesta) {
    if (respuesta.body.isEmpty) return <String, dynamic>{};

    dynamic contenido;
    try {
      contenido = jsonDecode(respuesta.body);
    } on FormatException {
      throw const ExcepcionApi('El servidor devolvió una respuesta inválida.');
    }

    if (respuesta.statusCode >= 400) {
      throw ExcepcionApi(_mensajeError(contenido, respuesta.statusCode));
    }

    return contenido;
  }

  String _mensajeError(dynamic contenido, int codigo) {
    if (contenido is Map<String, dynamic>) {
      final mensaje = ParseoSeguro.texto(contenido['message']);
      if (mensaje.isNotEmpty) return mensaje;
      final errores = contenido.entries
          .where((entrada) => entrada.value != null)
          .map(
            (entrada) => MapEntry(
              entrada.key,
              ParseoSeguro.texto(entrada.value),
            ),
          )
          .where((entrada) => entrada.value.isNotEmpty)
          .toList();
      if (errores.isNotEmpty) return errores.first.value;
    }
    return 'Error en la solicitud (código $codigo).';
  }

  List<Map<String, dynamic>> _comoLista(dynamic contenido) {
    if (contenido is List) {
      return contenido.whereType<Map<String, dynamic>>().toList();
    }
    if (contenido is Map<String, dynamic>) {
      final datos = contenido['data'];
      if (datos is List) {
        return datos.whereType<Map<String, dynamic>>().toList();
      }
    }
    throw const ExcepcionApi('No se encontraron resultados.');
  }

  Map<String, dynamic> _comoMapa(dynamic contenido) {
    if (contenido is Map<String, dynamic>) return contenido;
    throw const ExcepcionApi('Respuesta inesperada del servidor.');
  }
}

class ParseoSeguro {
  const ParseoSeguro._();

  static String texto(dynamic valor) {
    if (valor == null) return '';
    if (valor is List) return valor.map(texto).where((t) => t.isNotEmpty).join(', ');
    return valor.toString();
  }
}
