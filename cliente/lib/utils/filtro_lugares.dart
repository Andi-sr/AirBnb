import 'package:cliente/models/lugar.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/texto_util.dart';

class CriteriosBusqueda {
  const CriteriosBusqueda({
    required this.ciudad,
    required this.huespedes,
    required this.fechaLlegada,
    required this.fechaSalida,
    this.avanzado = false,
    this.camas = 0,
    this.banios = 0,
    this.habitaciones = 0,
    this.tieneWifi = false,
    this.vehiculos = 0,
    this.precioMin = 0,
    this.precioMax = 0,
  });

  final String ciudad;
  final int huespedes;
  final DateTime fechaLlegada;
  final DateTime fechaSalida;
  final bool avanzado;
  final int camas;
  final int banios;
  final int habitaciones;
  final bool tieneWifi;
  final int vehiculos;
  final double precioMin;
  final double precioMax;

  Map<String, String> aDatosApi() => <String, String>{
    if (avanzado) 'ciudad': ciudad else 'search': ciudad,
    'fechaInicio': FechasUtil.formatearApi(fechaLlegada),
    'fechaFin': FechasUtil.formatearApi(fechaSalida),
    'cantPersonas': '$huespedes',
    if (avanzado && camas > 0) 'cantCamas': '$camas',
    if (avanzado && banios > 0) 'cantBanios': '$banios',
    if (avanzado && habitaciones > 0) 'cantHabitaciones': '$habitaciones',
    if (avanzado && tieneWifi) 'tieneWifi': '1',
    if (avanzado && vehiculos > 0) 'cantVehiculosParqueo': '$vehiculos',
    if (avanzado && precioMin > 0) 'precioMin': '$precioMin',
    if (avanzado && precioMax > 0) 'precioMax': '$precioMax',
  };
}

class FiltroLugares {
  const FiltroLugares._();

  static List<Lugar> aplicar(List<Lugar> lugares, CriteriosBusqueda criterios) {
    final objetivo = TextoUtil.normalizar(criterios.ciudad);

    return lugares.where((lugar) {
      final ciudadLugar = TextoUtil.normalizar(lugar.ciudad);
      final coincideCiudad =
          objetivo.isEmpty ||
          (ciudadLugar.isNotEmpty &&
              (ciudadLugar.contains(objetivo) ||
                  objetivo.contains(ciudadLugar)));
      if (!coincideCiudad) return false;
      if (lugar.cantPersonas < criterios.huespedes) return false;
      if (!criterios.avanzado) return true;

      if (criterios.camas > 0 && lugar.cantCamas < criterios.camas) {
        return false;
      }
      if (criterios.banios > 0 && lugar.cantBanios < criterios.banios) {
        return false;
      }
      if (criterios.habitaciones > 0 &&
          lugar.cantHabitaciones < criterios.habitaciones) {
        return false;
      }
      if (criterios.tieneWifi && !lugar.tieneWifi) return false;
      if (criterios.vehiculos > 0 &&
          lugar.cantVehiculosParqueo < criterios.vehiculos) {
        return false;
      }
      if (criterios.precioMin > 0 && lugar.precioNoche < criterios.precioMin) {
        return false;
      }
      if (criterios.precioMax > 0 && lugar.precioNoche > criterios.precioMax) {
        return false;
      }
      return true;
    }).toList();
  }
}
