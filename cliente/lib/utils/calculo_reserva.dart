import 'package:cliente/utils/fechas_util.dart';

class DesglosePrecio {
  const DesglosePrecio({
    required this.noches,
    required this.precioNoche,
    required this.costoLimpieza,
    required this.precioNoches,
    required this.precioServicio,
    required this.precioTotal,
  });

  final int noches;
  final double precioNoche;
  final double costoLimpieza;
  final double precioNoches;
  final double precioServicio;
  final double precioTotal;

  static const double porcentajeServicio = 0.10;

  factory DesglosePrecio.calcular({
    required DateTime? fechaLlegada,
    required DateTime? fechaSalida,
    required double precioNoche,
    required double costoLimpieza,
  }) {
    final noches = FechasUtil.calcularNoches(fechaLlegada, fechaSalida);
    final precioNoches = _redondear(noches * precioNoche);
    final limpieza = _redondear(costoLimpieza);
    final servicio = _redondear(precioNoches * porcentajeServicio);
    return DesglosePrecio(
      noches: noches,
      precioNoche: precioNoche,
      costoLimpieza: limpieza,
      precioNoches: precioNoches,
      precioServicio: servicio,
      precioTotal: _redondear(precioNoches + limpieza + servicio),
    );
  }

  Map<String, String> aDatosApi({
    required int clienteId,
    required int lugarId,
    required DateTime fechaLlegada,
    required DateTime fechaSalida,
  }) {
    return {
      'cliente_id': '$clienteId',
      'lugar_id': '$lugarId',
      'fechaInicio': FechasUtil.formatearApi(fechaLlegada),
      'fechaFin': FechasUtil.formatearApi(fechaSalida),
      'precioTotal': _comoTexto(precioTotal),
      'precioNoches': _comoTexto(precioNoches),
      'precioServicio': _comoTexto(precioServicio),
      'precioLimpieza': _comoTexto(costoLimpieza),
    };
  }

  static double _redondear(double valor) =>
      double.parse(valor.toStringAsFixed(2));

  static String _comoTexto(double valor) => valor.toStringAsFixed(2);
}
