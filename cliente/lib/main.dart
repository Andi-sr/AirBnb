import 'package:flutter/material.dart';

import 'package:cliente/models/cliente.dart';
import 'package:cliente/screens/autenticacion_screen.dart';
import 'package:cliente/screens/busqueda_inicio_screen.dart';
import 'package:cliente/screens/confirmar_reserva_screen.dart';
import 'package:cliente/screens/detalle_lugar_screen.dart';
import 'package:cliente/screens/mis_reservas_screen.dart';
import 'package:cliente/screens/resultados_screen.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/utils/sesion_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sesion = await SesionUsuario.leer();
  runApp(Aplicacion(sesionInicial: sesion));
}

class Aplicacion extends StatelessWidget {
  const Aplicacion({super.key, this.sesionInicial});

  final Cliente? sesionInicial;

  static Route<dynamic> generarRuta(RouteSettings ajustes) {
    final Widget pantalla;

    switch (ajustes.name) {
      case Rutas.busqueda:
        pantalla = const BusquedaInicioScreen();
        break;
      case Rutas.resultados:
        final argumentos = ajustes.arguments;
        pantalla = argumentos is ArgumentosResultados
            ? ResultadosScreen(argumentos: argumentos)
            : const BusquedaInicioScreen();
        break;
      case Rutas.detalle:
        final argumentos = ajustes.arguments;
        pantalla = argumentos is ArgumentosDetalle
            ? DetalleLugarScreen(argumentos: argumentos)
            : const BusquedaInicioScreen();
        break;
      case Rutas.confirmarReserva:
        final argumentos = ajustes.arguments;
        pantalla = argumentos is ArgumentosReserva
            ? ConfirmarReservaScreen(argumentos: argumentos)
            : const BusquedaInicioScreen();
        break;
      case Rutas.misReservas:
        pantalla = const MisReservasScreen();
        break;
      case Rutas.autenticacion:
      default:
        pantalla = const AutenticacionScreen();
        break;
    }

    return MaterialPageRoute<dynamic>(
      builder: (_) => pantalla,
      settings: ajustes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estadía',
      theme: ColoresApp.tema,
      debugShowCheckedModeBanner: false,
      initialRoute: sesionInicial == null
          ? Rutas.autenticacion
          : Rutas.busqueda,
      onGenerateRoute: generarRuta,
    );
  }
}
