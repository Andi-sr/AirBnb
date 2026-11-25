import 'package:flutter/material.dart';

import 'package:cliente/models/reserva.dart';
import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/utils/sesion_util.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _EstadoMisReservas();
}

class _EstadoMisReservas extends State<MisReservasScreen> {
  final List<Reserva> _reservas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cliente = await SesionUsuario.leer();
      if (cliente == null) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          Rutas.autenticacion,
          (ruta) => false,
        );
        return;
      }
      final respuesta = await ServicioApi.instancia
          .obtenerLista('/reservas/cliente/${cliente.id}');
      if (!mounted) return;
      setState(() {
        _reservas
          ..clear()
          ..addAll(respuesta.map(Reserva.fromJson));
      });
    } on ExcepcionApi catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await SesionUsuario.cerrar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      Rutas.autenticacion,
      (ruta) => false,
    );
  }

  Widget _tarjeta(Reserva reserva) {
    final lugar = reserva.lugar;
    return Tarjeta(
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagenLugar(
                url: lugar?.fotoPrincipal ?? '',
                altura: 92,
                ancho: 92,
                radio: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reserva #${reserva.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lugar?.nombre ?? 'Alojamiento',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.azul,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lugar?.ciudad ?? '',
                      style: const TextStyle(
                          color: ColoresApp.textoSecundario, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilaEspecificacion(
            icono: Icons.date_range_outlined,
            texto:
                '${FechasUtil.formatearInterfaz(reserva.fechaInicio)} - '
                '${FechasUtil.formatearInterfaz(reserva.fechaFin)}',
          ),
          const SizedBox(height: 6),
          FilaEspecificacion(
            icono: Icons.nights_stay_outlined,
            texto: '${reserva.noches} ${reserva.noches == 1 ? 'noche' : 'noches'}',
          ),
          const SizedBox(height: 6),
          FilaEspecificacion(
            icono: Icons.person_outline,
            texto: lugar?.nombreAnfitrion ?? 'Anfitrión',
          ),
          const Divider(height: 20, color: ColoresApp.borde),
          FilaPrecio(
            etiqueta: 'Total pagado',
            valor: FechasUtil.formatearDinero(reserva.precioTotal),
            resaltado: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reservas'),
        actions: [
          IconButton(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: SafeArea(
        child: VistaEstado(
          cargando: _cargando,
          error: _error,
          vacio: _reservas.isEmpty,
          mensajeVacio: 'Aún no tienes reservas.',
          alReintentar: _cargar,
          contenido: RefreshIndicator(
            onRefresh: _cargar,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: _reservas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (contexto, indice) => _tarjeta(_reservas[indice]),
            ),
          ),
        ),
      ),
    );
  }
}
