import 'package:flutter/material.dart';

import 'package:cliente/models/lugar.dart';
import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/ciudades_bolivia.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/filtro_lugares.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/utils/sesion_util.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class BusquedaInicioScreen extends StatefulWidget {
  const BusquedaInicioScreen({super.key});

  @override
  State<BusquedaInicioScreen> createState() => _EstadoBusquedaInicio();
}

class _EstadoBusquedaInicio extends State<BusquedaInicioScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorCiudadLibre = TextEditingController();
  final _controladorCamas = TextEditingController();
  final _controladorBanios = TextEditingController();
  final _controladorHabitaciones = TextEditingController();
  final _controladorPrecioMin = TextEditingController();
  final _controladorPrecioMax = TextEditingController();

  String _departamento = 'Santa Cruz';
  String _ciudadSeleccionada = 'Santa Cruz';
  DateTime? _fechaLlegada;
  DateTime? _fechaSalida;
  int _cantidadHuespedes = 1;
  int _cantidadVehiculos = 0;
  bool _tieneWifi = false;
  bool _avanzado = false;
  bool _cargando = false;
  String _nombreUsuario = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _fechaLlegada = FechasUtil.diaSiguiente(hoy);
    _fechaSalida = hoy.add(const Duration(days: 4));
    _cargarNombre();
  }

  String get _saludo {
    final nombre = _nombreUsuario.trim();
    if (nombre.isEmpty) return 'Buscar alojamiento';
    return '¡Hi, ${nombre.split(RegExp(r'\s+')).first}!';
  }

  Future<void> _cargarNombre() async {
    final sesion = await SesionUsuario.leer();
    if (!mounted) return;
    setState(() => _nombreUsuario = sesion?.nombre ?? '');
  }

  @override
  void dispose() {
    _controladorCiudadLibre.dispose();
    _controladorCamas.dispose();
    _controladorBanios.dispose();
    _controladorHabitaciones.dispose();
    _controladorPrecioMin.dispose();
    _controladorPrecioMax.dispose();
    super.dispose();
  }

  void _cambiarLlegada(DateTime fecha) {
    setState(() {
      _fechaLlegada = fecha;
      if (!FechasUtil.salidaEsValida(_fechaLlegada, _fechaSalida)) {
        _fechaSalida = FechasUtil.diaSiguiente(fecha);
      }
    });
  }

  String? _validarOpcional(String? valor, String etiqueta) {
    if (valor == null || valor.trim().isEmpty) return null;
    final numero = double.tryParse(valor);
    if (numero == null || numero < 0) return '$etiqueta debe ser positivo';
    return null;
  }

  int _entero(TextEditingController controlador) =>
      int.tryParse(controlador.text.trim()) ?? 0;

  double _decimal(TextEditingController controlador) =>
      double.tryParse(controlador.text.trim()) ?? 0;

  Future<void> _buscar() async {
    if (!_claveFormulario.currentState!.validate()) return;
    if (!FechasUtil.salidaEsValida(_fechaLlegada, _fechaSalida)) {
      setState(
        () => _error = 'La fecha de salida debe ser posterior a la de llegada.',
      );
      return;
    }

    final ciudad = _controladorCiudadLibre.text.trim().isNotEmpty
        ? _controladorCiudadLibre.text.trim()
        : _ciudadSeleccionada;
    final criterios = CriteriosBusqueda(
      ciudad: ciudad,
      huespedes: _cantidadHuespedes,
      fechaLlegada: _fechaLlegada!,
      fechaSalida: _fechaSalida!,
      avanzado: _avanzado,
      camas: _entero(_controladorCamas),
      banios: _entero(_controladorBanios),
      habitaciones: _entero(_controladorHabitaciones),
      tieneWifi: _tieneWifi,
      vehiculos: _cantidadVehiculos,
      precioMin: _decimal(_controladorPrecioMin),
      precioMax: _decimal(_controladorPrecioMax),
    );

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final ruta = _avanzado ? '/lugares/advancedsearch' : '/lugares/search';
      final resultados = await ServicioApi.instancia.enviarFormularioLista(
        ruta,
        criterios.aDatosApi(),
      );
      if (!mounted) return;
      final lugares = FiltroLugares.aplicar(
        resultados.map(Lugar.fromJson).toList(),
        criterios,
      );
      Navigator.of(context).pushNamed(
        Rutas.resultados,
        arguments: ArgumentosResultados(
          lugares: lugares,
          ciudad: ciudad,
          fechaLlegada: _fechaLlegada!,
          fechaSalida: _fechaSalida!,
          cantidadHuespedes: _cantidadHuespedes,
        ),
      );
    } on ExcepcionApi catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await SesionUsuario.cerrar();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Rutas.autenticacion, (ruta) => false);
  }

  void _irMisReservas() {
    Navigator.of(context).pushNamed(Rutas.misReservas);
  }

  Future<void> _accionMenu(String valor) async {
    if (valor == 'cerrar') {
      await _cerrarSesion();
      return;
    }
    if (valor == 'reservas') _irMisReservas();
  }

  @override
  Widget build(BuildContext context) {
    final ciudades = CiudadesBolivia.ciudadesDe(_departamento);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    _saludo,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: ColoresApp.blanco,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: ColoresApp.lavanda,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 13,
                    color: ColoresApp.violeta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Buscar alojamiento',
              style: TextStyle(
                fontSize: 12,
                color: ColoresApp.blanco.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: ColoresApp.blanco),
            tooltip: 'Menú',
            color: ColoresApp.blanco,
            surfaceTintColor: ColoresApp.blanco,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ColoresApp.borde),
            ),
            onSelected: _accionMenu,
            itemBuilder: (contexto) => const [
              PopupMenuItem<String>(
                value: 'reservas',
                child: Row(
                  children: [
                    Icon(Icons.event_available, color: ColoresApp.violeta),
                    SizedBox(width: 10),
                    Text(
                      'Mis Reservas',
                      style: TextStyle(color: ColoresApp.azul),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'cerrar',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: ColoresApp.violeta),
                    SizedBox(width: 10),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: ColoresApp.azul),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _claveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TituloSeccion(
                  texto: '¿A dónde quieres ir?',
                  icono: Icons.travel_explore,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _departamento,
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                      color: ColoresApp.violeta,
                    ),
                  ),
                  items: CiudadesBolivia.departamentos
                      .map(
                        (nombre) => DropdownMenuItem(
                          value: nombre,
                          child: Text(nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor == null) return;
                    setState(() {
                      _departamento = valor;
                      _ciudadSeleccionada = CiudadesBolivia.ciudadesDe(valor)
                          .first
                          .nombre;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _ciudadSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                      color: ColoresApp.violeta,
                    ),
                  ),
                  items: ciudades
                      .map(
                        (ciudad) => DropdownMenuItem(
                          value: ciudad.nombre,
                          child: Text(ciudad.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() => _ciudadSeleccionada = valor);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _controladorCiudadLibre,
                  etiqueta: 'Otra ciudad (opcional)',
                  icono: Icons.edit_location_alt_outlined,
                  textoAyuda: 'Se usa en lugar de la ciudad seleccionada',
                ),
                const SizedBox(height: 16),
                CampoFecha(
                  etiqueta: 'Fecha de llegada',
                  fecha: _fechaLlegada,
                  alElegir: _cambiarLlegada,
                ),
                const SizedBox(height: 16),
                CampoFecha(
                  etiqueta: 'Fecha de salida',
                  fecha: _fechaSalida,
                  alElegir: (fecha) => setState(() => _fechaSalida = fecha),
                  fechaMinima: _fechaLlegada == null
                      ? null
                      : FechasUtil.diaSiguiente(_fechaLlegada!),
                ),
                const SizedBox(height: 16),
                SelectorCantidad(
                  etiqueta: 'Huéspedes',
                  valor: _cantidadHuespedes,
                  alCambiar: (valor) =>
                      setState(() => _cantidadHuespedes = valor),
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => setState(() => _avanzado = !_avanzado),
                  icon: Icon(
                    _avanzado ? Icons.expand_less : Icons.tune,
                    color: ColoresApp.violeta,
                  ),
                  label: Text(
                    _avanzado
                        ? 'Ocultar búsqueda avanzada'
                        : 'Búsqueda avanzada',
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  alignment: Alignment.topCenter,
                  child: _avanzado
                      ? Column(
                          children: [
                            const SizedBox(height: 8),
                            CampoTexto(
                              controlador: _controladorCamas,
                              etiqueta: 'Camas (mínimo)',
                              icono: Icons.bed_outlined,
                              tipo: TextInputType.number,
                              validador: (valor) =>
                                  _validarOpcional(valor, 'El número de camas'),
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              controlador: _controladorBanios,
                              etiqueta: 'Baños (mínimo)',
                              icono: Icons.bathtub_outlined,
                              tipo: TextInputType.number,
                              validador: (valor) =>
                                  _validarOpcional(valor, 'El número de baños'),
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              controlador: _controladorHabitaciones,
                              etiqueta: 'Habitaciones (mínimo)',
                              icono: Icons.meeting_room_outlined,
                              tipo: TextInputType.number,
                              validador: (valor) => _validarOpcional(
                                valor,
                                'El número de habitaciones',
                              ),
                            ),
                            const SizedBox(height: 12),
                            CheckboxListTile(
                              value: _tieneWifi,
                              onChanged: (valor) =>
                                  setState(() => _tieneWifi = valor ?? false),
                              title: const Text('Requiere Wi-Fi'),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            SelectorCantidad(
                              etiqueta: 'Vehículos de parqueo',
                              valor: _cantidadVehiculos,
                              minimo: 0,
                              alCambiar: (valor) =>
                                  setState(() => _cantidadVehiculos = valor),
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              controlador: _controladorPrecioMin,
                              etiqueta: 'Precio mínimo por noche',
                              icono: Icons.price_change_outlined,
                              tipo: TextInputType.number,
                              validador: (valor) =>
                                  _validarOpcional(valor, 'El precio mínimo'),
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              controlador: _controladorPrecioMax,
                              etiqueta: 'Precio máximo por noche',
                              icono: Icons.price_check_outlined,
                              tipo: TextInputType.number,
                              validador: (valor) =>
                                  _validarOpcional(valor, 'El precio máximo'),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB3261E)),
                  ),
                ],
                const SizedBox(height: 20),
                BotonApp(
                  texto: 'Buscar',
                  icono: Icons.search,
                  alPresionar: _buscar,
                  cargando: _cargando,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
