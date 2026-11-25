import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cliente/services/servicio_api.dart';

class FechasUtil {
  const FechasUtil._();

  static final DateFormat _formatoApi = DateFormat('yyyy-MM-dd');
  static final DateFormat _formatoInterfaz = DateFormat('dd/MM/yyyy');
  static final NumberFormat _formatoDinero = NumberFormat.currency(
    locale: 'es_BO',
    symbol: 'Bs ',
    decimalDigits: 2,
  );

  static String formatearApi(DateTime fecha) => _formatoApi.format(fecha);

  static String? formatearApiOpcional(DateTime? fecha) =>
      fecha == null ? null : _formatoApi.format(fecha);

  static DateTime? parsearApi(dynamic valor) {
    if (valor is DateTime) return valor;
    if (valor is! String || valor.isEmpty) return null;
    return DateTime.tryParse(valor.length > 10 ? valor.substring(0, 10) : valor);
  }

  static String formatearInterfaz(DateTime? fecha) =>
      fecha == null ? '—' : _formatoInterfaz.format(fecha);

  static String formatearDinero(double valor) => _formatoDinero.format(valor);

  static DateTime soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  static DateTime diaSiguiente(DateTime fecha) =>
      soloFecha(fecha).add(const Duration(days: 1));

  static int calcularNoches(DateTime? fechaLlegada, DateTime? fechaSalida) {
    if (fechaLlegada == null || fechaSalida == null) return 1;
    final dias = soloFecha(fechaSalida)
        .difference(soloFecha(fechaLlegada))
        .inDays;
    return dias < 1 ? 1 : dias;
  }

  static bool salidaEsValida(DateTime? fechaLlegada, DateTime? fechaSalida) {
    if (fechaLlegada == null || fechaSalida == null) return false;
    return soloFecha(fechaSalida).isAfter(soloFecha(fechaLlegada));
  }

  static Future<DateTime?> elegirFecha(
    BuildContext context, {
    required DateTime fechaInicial,
    required DateTime fechaMinima,
    DateTime? fechaMaxima,
  }) {
    final minima = soloFecha(fechaMinima);
    final maxima = fechaMaxima ?? DateTime(minima.year + 3, 12, 31);
    var inicial = soloFecha(fechaInicial);
    if (inicial.isBefore(minima)) inicial = minima;
    if (inicial.isAfter(maxima)) inicial = maxima;

    return showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: minima,
      lastDate: maxima,
      helpText: 'Selecciona una fecha',
    );
  }

  static void mostrarError(BuildContext context, Object error) {
    final mensaje = error is ExcepcionApi ? error.mensaje : 'Ocurrió un error';
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }
}
