import 'package:latlong2/latlong.dart';

import 'package:cliente/utils/texto_util.dart';

class CiudadBolivia {
  const CiudadBolivia({
    required this.nombre,
    required this.departamento,
    required this.latitud,
    required this.longitud,
  });

  final String nombre;
  final String departamento;
  final double latitud;
  final double longitud;

  LatLng get ubicacion => LatLng(latitud, longitud);
}

class CiudadesBolivia {
  const CiudadesBolivia._();

  static const Map<String, List<CiudadBolivia>> ciudadesPorDepartamento = {
    'La Paz': [
      CiudadBolivia(
        nombre: 'La Paz',
        departamento: 'La Paz',
        latitud: -16.4897,
        longitud: -68.1193,
      ),
      CiudadBolivia(
        nombre: 'El Alto',
        departamento: 'La Paz',
        latitud: -16.5044,
        longitud: -68.1181,
      ),
      CiudadBolivia(
        nombre: 'Coroico',
        departamento: 'La Paz',
        latitud: -16.1944,
        longitud: -67.7311,
      ),
      CiudadBolivia(
        nombre: 'Copacabana',
        departamento: 'La Paz',
        latitud: -16.1635,
        longitud: -68.3211,
      ),
      CiudadBolivia(
        nombre: 'Viacha',
        departamento: 'La Paz',
        latitud: -16.6333,
        longitud: -68.3000,
      ),
    ],
    'Oruro': [
      CiudadBolivia(
        nombre: 'Oruro',
        departamento: 'Oruro',
        latitud: -17.9837,
        longitud: -67.0081,
      ),
      CiudadBolivia(
        nombre: 'Huanuni',
        departamento: 'Oruro',
        latitud: -18.2000,
        longitud: -66.8500,
      ),
      CiudadBolivia(
        nombre: 'Llallagua',
        departamento: 'Oruro',
        latitud: -18.4000,
        longitud: -66.7500,
      ),
      CiudadBolivia(
        nombre: 'Challapata',
        departamento: 'Oruro',
        latitud: -19.0167,
        longitud: -66.7667,
      ),
    ],
    'Potosí': [
      CiudadBolivia(
        nombre: 'Potosí',
        departamento: 'Potosí',
        latitud: -19.5837,
        longitud: -65.7531,
      ),
      CiudadBolivia(
        nombre: 'Uyuni',
        departamento: 'Potosí',
        latitud: -20.4633,
        longitud: -66.8286,
      ),
      CiudadBolivia(
        nombre: 'Tupiza',
        departamento: 'Potosí',
        latitud: -21.4417,
        longitud: -65.7208,
      ),
      CiudadBolivia(
        nombre: 'Villazón',
        departamento: 'Potosí',
        latitud: -22.0956,
        longitud: -65.5925,
      ),
    ],
    'Chuquisaca': [
      CiudadBolivia(
        nombre: 'Sucre',
        departamento: 'Chuquisaca',
        latitud: -19.0330,
        longitud: -65.2628,
      ),
      CiudadBolivia(
        nombre: 'Yamparáez',
        departamento: 'Chuquisaca',
        latitud: -19.1000,
        longitud: -65.2000,
      ),
      CiudadBolivia(
        nombre: 'Monteagudo',
        departamento: 'Chuquisaca',
        latitud: -20.1667,
        longitud: -64.9333,
      ),
      CiudadBolivia(
        nombre: 'Camargo',
        departamento: 'Chuquisaca',
        latitud: -20.0500,
        longitud: -64.9000,
      ),
    ],
    'Cochabamba': [
      CiudadBolivia(
        nombre: 'Cochabamba',
        departamento: 'Cochabamba',
        latitud: -17.4148,
        longitud: -66.0246,
      ),
      CiudadBolivia(
        nombre: 'Quillacollo',
        departamento: 'Cochabamba',
        latitud: -17.3933,
        longitud: -66.2797,
      ),
      CiudadBolivia(
        nombre: 'Sacaba',
        departamento: 'Cochabamba',
        latitud: -17.3147,
        longitud: -66.0381,
      ),
      CiudadBolivia(
        nombre: 'Tiquipaya',
        departamento: 'Cochabamba',
        latitud: -17.3833,
        longitud: -66.2000,
      ),
      CiudadBolivia(
        nombre: 'Villa Tunari',
        departamento: 'Cochabamba',
        latitud: -16.9500,
        longitud: -65.4000,
      ),
    ],
    'Beni': [
      CiudadBolivia(
        nombre: 'Trinidad',
        departamento: 'Beni',
        latitud: -14.8333,
        longitud: -64.9000,
      ),
      CiudadBolivia(
        nombre: 'Riberalta',
        departamento: 'Beni',
        latitud: -11.0000,
        longitud: -66.0000,
      ),
      CiudadBolivia(
        nombre: 'Guayaramerín',
        departamento: 'Beni',
        latitud: -10.8700,
        longitud: -65.3500,
      ),
      CiudadBolivia(
        nombre: 'San Borja',
        departamento: 'Beni',
        latitud: -14.8500,
        longitud: -66.7500,
      ),
      CiudadBolivia(
        nombre: 'Magdalena',
        departamento: 'Beni',
        latitud: -13.0000,
        longitud: -64.0000,
      ),
    ],
    'Pando': [
      CiudadBolivia(
        nombre: 'Cobija',
        departamento: 'Pando',
        latitud: -11.0066,
        longitud: -68.5658,
      ),
      CiudadBolivia(
        nombre: 'Porvenir',
        departamento: 'Pando',
        latitud: -10.8700,
        longitud: -68.5500,
      ),
      CiudadBolivia(
        nombre: 'San Buenaventura',
        departamento: 'Pando',
        latitud: -11.0500,
        longitud: -68.6500,
      ),
    ],
    'Santa Cruz': [
      CiudadBolivia(
        nombre: 'Santa Cruz',
        departamento: 'Santa Cruz',
        latitud: -17.7833,
        longitud: -63.1821,
      ),
      CiudadBolivia(
        nombre: 'Samaipata',
        departamento: 'Santa Cruz',
        latitud: -18.1789,
        longitud: -63.8741,
      ),
      CiudadBolivia(
        nombre: 'Warnes',
        departamento: 'Santa Cruz',
        latitud: -17.5333,
        longitud: -63.1667,
      ),
      CiudadBolivia(
        nombre: 'Montero',
        departamento: 'Santa Cruz',
        latitud: -17.0333,
        longitud: -64.4000,
      ),
      CiudadBolivia(
        nombre: 'Porongo',
        departamento: 'Santa Cruz',
        latitud: -17.8555,
        longitud: -63.3084,
      ),
      CiudadBolivia(
        nombre: 'San Ignacio de Velasco',
        departamento: 'Santa Cruz',
        latitud: -16.3667,
        longitud: -60.9500,
      ),
    ],
    'Tarija': [
      CiudadBolivia(
        nombre: 'Tarija',
        departamento: 'Tarija',
        latitud: -21.5355,
        longitud: -64.7296,
      ),
      CiudadBolivia(
        nombre: 'Yacuiba',
        departamento: 'Tarija',
        latitud: -22.0000,
        longitud: -63.6667,
      ),
      CiudadBolivia(
        nombre: 'Bermejo',
        departamento: 'Tarija',
        latitud: -22.7333,
        longitud: -64.3500,
      ),
      CiudadBolivia(
        nombre: 'Villa Montes',
        departamento: 'Tarija',
        latitud: -21.4500,
        longitud: -63.4000,
      ),
    ],
  };

  static List<String> get departamentos =>
      ciudadesPorDepartamento.keys.toList();

  static List<CiudadBolivia> ciudadesDe(String departamento) =>
      ciudadesPorDepartamento[departamento] ?? const <CiudadBolivia>[];

  static CiudadBolivia? buscarCiudad(String nombre) {
    final objetivo = TextoUtil.normalizar(nombre);
    for (final ciudades in ciudadesPorDepartamento.values) {
      for (final ciudad in ciudades) {
        if (TextoUtil.normalizar(ciudad.nombre) == objetivo) {
          return ciudad;
        }
      }
    }
    return null;
  }

  static CiudadBolivia centroPorDefecto() =>
      ciudadesPorDepartamento['Santa Cruz']!.first;
}
