import 'package:cliente/models/lugar.dart';

class Rutas {
  const Rutas._();

  static const String autenticacion = '/autenticacion';
  static const String busqueda = '/busqueda';
  static const String resultados = '/resultados';
  static const String detalle = '/detalle';
  static const String confirmarReserva = '/confirmar-reserva';
  static const String misReservas = '/mis-reservas';
}

class ArgumentosResultados {
  const ArgumentosResultados({
    required this.lugares,
    required this.ciudad,
    required this.fechaLlegada,
    required this.fechaSalida,
    required this.cantidadHuespedes,
  });

  final List<Lugar> lugares;
  final String ciudad;
  final DateTime fechaLlegada;
  final DateTime fechaSalida;
  final int cantidadHuespedes;
}

class ArgumentosDetalle {
  const ArgumentosDetalle({
    this.lugar,
    this.lugarId,
    this.fechaLlegada,
    this.fechaSalida,
    this.cantidadHuespedes = 1,
  });

  final Lugar? lugar;
  final int? lugarId;
  final DateTime? fechaLlegada;
  final DateTime? fechaSalida;
  final int cantidadHuespedes;
}

class ArgumentosReserva {
  const ArgumentosReserva({
    required this.lugar,
    required this.fechaLlegada,
    required this.fechaSalida,
  });

  final Lugar lugar;
  final DateTime fechaLlegada;
  final DateTime fechaSalida;
}
