import 'package:cliente/models/lugar.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/parseo.dart';

class Reserva {
  const Reserva({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioTotal,
    required this.precioLimpieza,
    required this.precioNoches,
    required this.precioServicio,
    required this.lugar,
    required this.nombreCliente,
  });

  final int id;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final double precioTotal;
  final double precioLimpieza;
  final double precioNoches;
  final double precioServicio;
  final Lugar? lugar;
  final String nombreCliente;

  factory Reserva.fromJson(Map<String, dynamic> json) {
    final listaLugares = Parseo.lista(json['lugar']);
    final datosLugar = listaLugares.isEmpty
        ? Parseo.mapa(json['lugar'])
        : listaLugares.first;
    final datosCliente = Parseo.mapa(json['cliente']);

    return Reserva(
      id: Parseo.entero(json['id']),
      fechaInicio: FechasUtil.parsearApi(json['fechaInicio']),
      fechaFin: FechasUtil.parsearApi(json['fechaFin']),
      precioTotal: Parseo.decimal(json['precioTotal']),
      precioLimpieza: Parseo.decimal(json['precioLimpieza']),
      precioNoches: Parseo.decimal(json['precioNoches']),
      precioServicio: Parseo.decimal(json['precioServicio']),
      lugar: datosLugar.isEmpty ? null : Lugar.fromJson(datosLugar),
      nombreCliente: Parseo.texto(
        datosCliente['nombrecompleto'],
        porDefecto: 'Cliente',
      ),
    );
  }

  int get noches => FechasUtil.calcularNoches(fechaInicio, fechaFin);
}
