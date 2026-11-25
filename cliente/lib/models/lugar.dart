import 'package:latlong2/latlong.dart';

import 'package:cliente/utils/imagen_url.dart';
import 'package:cliente/utils/parseo.dart';

class FotoLugar {
  const FotoLugar({required this.id, required this.url});

  final int id;
  final String url;

  factory FotoLugar.fromJson(Map<String, dynamic> json) =>
      FotoLugar.fromDatos(json);

  factory FotoLugar.fromDatos(dynamic dato) => FotoLugar(
    id: dato is Map ? Parseo.entero(dato['id']) : 0,
    url: obtenerUrlImagen(dato),
  );
}

class Arrendatario {
  const Arrendatario({required this.id, required this.nombreCompleto});

  final int id;
  final String nombreCompleto;

  factory Arrendatario.fromJson(Map<String, dynamic> json) => Arrendatario(
    id: Parseo.entero(json['id']),
    nombreCompleto: Parseo.texto(
      json['nombrecompleto'],
      porDefecto: 'Anfitrión',
    ),
  );
}

class Lugar {
  const Lugar({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantPersonas,
    required this.cantCamas,
    required this.cantBanios,
    required this.cantHabitaciones,
    required this.tieneWifi,
    required this.cantVehiculosParqueo,
    required this.precioNoche,
    required this.costoLimpieza,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    required this.arrendatarioId,
    required this.arrendatario,
    required this.fotos,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final int cantPersonas;
  final int cantCamas;
  final int cantBanios;
  final int cantHabitaciones;
  final bool tieneWifi;
  final int cantVehiculosParqueo;
  final double precioNoche;
  final double costoLimpieza;
  final String ciudad;
  final double latitud;
  final double longitud;
  final int arrendatarioId;
  final Arrendatario? arrendatario;
  final List<FotoLugar> fotos;

  factory Lugar.fromJson(Map<String, dynamic> json) {
    final datosAnfitrion = Parseo.mapa(json['arrendatario']);
    return Lugar(
      id: Parseo.entero(json['id']),
      nombre: Parseo.texto(json['nombre'], porDefecto: 'Alojamiento'),
      descripcion: Parseo.texto(json['descripcion']),
      cantPersonas: Parseo.entero(json['cantPersonas']),
      cantCamas: Parseo.entero(json['cantCamas']),
      cantBanios: Parseo.entero(json['cantBanios']),
      cantHabitaciones: Parseo.entero(json['cantHabitaciones']),
      tieneWifi: Parseo.booleano(json['tieneWifi']),
      cantVehiculosParqueo: Parseo.entero(json['cantVehiculosParqueo']),
      precioNoche: Parseo.decimal(json['precioNoche']),
      costoLimpieza: Parseo.decimal(json['costoLimpieza']),
      ciudad: Parseo.texto(json['ciudad'], porDefecto: 'Bolivia'),
      latitud: Parseo.decimal(json['latitud']),
      longitud: Parseo.decimal(json['longitud']),
      arrendatarioId: Parseo.entero(json['arrendatario_id']),
      arrendatario: datosAnfitrion.isEmpty
          ? null
          : Arrendatario.fromJson(datosAnfitrion),
      fotos: _fotosDe(json),
    );
  }

  static List<FotoLugar> _fotosDe(Map<String, dynamic> json) {
    final valor = json['fotos'];
    final elementos = valor is List
        ? valor
        : valor == null
        ? <dynamic>[]
        : <dynamic>[valor];

    final fotos = elementos
        .map(FotoLugar.fromDatos)
        .where((foto) => foto.url.isNotEmpty)
        .toList();

    if (fotos.isEmpty) {
      final alterna = obtenerUrlImagen(json);
      if (alterna.isNotEmpty) {
        fotos.add(FotoLugar(id: 0, url: alterna));
      }
    }
    return fotos;
  }

  String get nombreAnfitrion => arrendatario?.nombreCompleto ?? 'Anfitrión';

  String get fotoPrincipal => fotos.isEmpty ? '' : fotos.first.url;

  LatLng get ubicacion => LatLng(latitud, longitud);

  bool get tieneUbicacion => latitud != 0 || longitud != 0;
}
