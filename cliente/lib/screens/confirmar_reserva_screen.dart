import 'package:flutter/material.dart';

import 'package:cliente/models/cliente.dart';
import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/calculo_reserva.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/utils/sesion_util.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class ConfirmarReservaScreen extends StatefulWidget {
  const ConfirmarReservaScreen({super.key, required this.argumentos});

  final ArgumentosReserva argumentos;

  @override
  State<ConfirmarReservaScreen> createState() => _EstadoConfirmarReserva();
}

class _EstadoConfirmarReserva extends State<ConfirmarReservaScreen> {
  Cliente? _cliente;
  bool _cargandoSesion = true;
  bool _confirmando = false;
  bool _reservaConfirmada = false;

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }

  String? get _errorFechas =>
      FechasUtil.salidaEsValida(
        widget.argumentos.fechaLlegada,
        widget.argumentos.fechaSalida,
      )
      ? null
      : 'Las fechas de la reserva no son válidas.';

  DesglosePrecio get _desglose => DesglosePrecio.calcular(
    fechaLlegada: widget.argumentos.fechaLlegada,
    fechaSalida: widget.argumentos.fechaSalida,
    precioNoche: widget.argumentos.lugar.precioNoche,
    costoLimpieza: widget.argumentos.lugar.costoLimpieza,
  );

  Future<void> _cargarSesion() async {
    final cliente = await SesionUsuario.leer();
    if (!mounted) return;
    if (cliente == null) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Rutas.autenticacion, (ruta) => false);
      return;
    }
    setState(() {
      _cliente = cliente;
      _cargandoSesion = false;
    });
  }

  Future<void> _confirmar() async {
    final cliente = _cliente;
    if (cliente == null || _errorFechas != null) return;

    final desglose = _desglose;
    setState(() => _confirmando = true);
    try {
      await ServicioApi.instancia.enviarJson(
        '/reservas',
        desglose.aDatosApi(
          clienteId: cliente.id,
          lugarId: widget.argumentos.lugar.id,
          fechaLlegada: widget.argumentos.fechaLlegada,
          fechaSalida: widget.argumentos.fechaSalida,
        ),
      );
      if (!mounted) return;
      setState(() => _reservaConfirmada = true);
    } on ExcepcionApi catch (error) {
      if (mounted) FechasUtil.mostrarError(context, error);
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  void _volverAlInicio() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Rutas.busqueda, (ruta) => false);
  }

  void _verMisReservas() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Rutas.misReservas, (ruta) => false);
  }

  Widget _vistaExito() {
    final lugar = widget.argumentos.lugar;
    final desglose = _desglose;

    return Scaffold(
      backgroundColor: ColoresApp.lavanda,
      appBar: AppBar(title: const Text('Reserva confirmada')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Tarjeta(
              relleno: const EdgeInsets.all(24),
              hijo: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 72,
                    color: ColoresApp.violeta,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Reserva confirmada!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.azul,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lugar.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColoresApp.violeta,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilaEspecificacion(
                    icono: Icons.date_range_outlined,
                    texto:
                        '${FechasUtil.formatearInterfaz(widget.argumentos.fechaLlegada)} - '
                        '${FechasUtil.formatearInterfaz(widget.argumentos.fechaSalida)}',
                  ),
                  const SizedBox(height: 12),
                  FilaPrecio(
                    etiqueta: 'Total pagado',
                    valor: FechasUtil.formatearDinero(desglose.precioTotal),
                    resaltado: true,
                    colorEtiqueta: ColoresApp.azul,
                  ),
                  const SizedBox(height: 28),
                  BotonApp(
                    texto: 'Volver al inicio',
                    icono: Icons.home_outlined,
                    alPresionar: _volverAlInicio,
                  ),
                  const SizedBox(height: 12),
                  BotonApp(
                    texto: 'Ver mis reservas',
                    icono: Icons.receipt_long_outlined,
                    alPresionar: _verMisReservas,
                    secundario: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_reservaConfirmada) return _vistaExito();

    final lugar = widget.argumentos.lugar;
    final desglose = _desglose;
    final puedeConfirmar = _cliente != null && _errorFechas == null;

    return Scaffold(
      backgroundColor: ColoresApp.lavanda,
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: SafeArea(
        child: VistaEstado(
          cargando: _cargandoSesion,
          error: _errorFechas,
          vacio: false,
          contenido: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: [
              Tarjeta(
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImagenLugar(url: lugar.fotoPrincipal, altura: 150),
                    const SizedBox(height: 12),
                    Text(
                      lugar.nombre,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.azul,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lugar.ciudad,
                      style: const TextStyle(color: ColoresApp.violeta),
                    ),
                    const SizedBox(height: 12),
                    FilaEspecificacion(
                      icono: Icons.date_range_outlined,
                      texto:
                          '${FechasUtil.formatearInterfaz(widget.argumentos.fechaLlegada)} - '
                          '${FechasUtil.formatearInterfaz(widget.argumentos.fechaSalida)}',
                    ),
                    const SizedBox(height: 6),
                    FilaEspecificacion(
                      icono: Icons.nights_stay_outlined,
                      texto:
                          '${desglose.noches} ${desglose.noches == 1 ? 'noche' : 'noches'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Tarjeta(
                hijo: Column(
                  children: [
                    const TituloSeccion(
                      texto: 'Desglose de precios',
                      icono: Icons.receipt_outlined,
                    ),
                    const SizedBox(height: 14),
                    FilaPrecio(
                      etiqueta:
                          '${desglose.noches} ${desglose.noches == 1 ? 'noche' : 'noches'} × '
                          '${FechasUtil.formatearDinero(desglose.precioNoche)}',
                      valor: FechasUtil.formatearDinero(desglose.precioNoches),
                      colorEtiqueta: ColoresApp.azul,
                    ),
                    const SizedBox(height: 10),
                    FilaPrecio(
                      etiqueta: 'Limpieza',
                      valor: FechasUtil.formatearDinero(desglose.costoLimpieza),
                      colorEtiqueta: ColoresApp.azul,
                    ),
                    const SizedBox(height: 10),
                    FilaPrecio(
                      etiqueta:
                          'Servicio (${(DesglosePrecio.porcentajeServicio * 100).toStringAsFixed(0)}%)',
                      valor: FechasUtil.formatearDinero(
                        desglose.precioServicio,
                      ),
                      colorEtiqueta: ColoresApp.azul,
                    ),
                    const Divider(height: 24, color: ColoresApp.borde),
                    FilaPrecio(
                      etiqueta: 'Total',
                      valor: FechasUtil.formatearDinero(desglose.precioTotal),
                      resaltado: true,
                      colorEtiqueta: ColoresApp.azul,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_cliente != null)
                Tarjeta(
                  hijo: FilaEspecificacion(
                    icono: Icons.person_outline,
                    texto: 'Reservando como ${_cliente!.nombre}',
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: puedeConfirmar
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: BotonApp(
                  texto: 'Confirmar reserva',
                  icono: Icons.check_circle_outline,
                  alPresionar: _confirmar,
                  cargando: _confirmando,
                ),
              ),
            )
          : null,
    );
  }
}
