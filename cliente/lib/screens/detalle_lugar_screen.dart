import 'package:flutter/material.dart';

import 'package:cliente/models/lugar.dart';
import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class DetalleLugarScreen extends StatefulWidget {
  const DetalleLugarScreen({super.key, required this.argumentos});

  final ArgumentosDetalle argumentos;

  @override
  State<DetalleLugarScreen> createState() => _EstadoDetalleLugar();
}

class _EstadoDetalleLugar extends State<DetalleLugarScreen> {
  Lugar? _lugar;
  bool _cargando = false;
  String? _error;
  int _indiceFoto = 0;

  @override
  void initState() {
    super.initState();
    _lugar = widget.argumentos.lugar;
    if (_lugar == null) _cargar();
  }

  DateTime get _llegada =>
      widget.argumentos.fechaLlegada ?? FechasUtil.diaSiguiente(DateTime.now());

  DateTime get _salida =>
      widget.argumentos.fechaSalida ??
      FechasUtil.soloFecha(_llegada).add(const Duration(days: 2));

  Future<void> _cargar() async {
    final id = widget.argumentos.lugarId;
    if (id == null) {
      setState(() => _error = 'No se especificó el lugar.');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final respuesta = await ServicioApi.instancia.obtenerJson('/lugares/$id');
      if (!mounted) return;
      setState(() => _lugar = Lugar.fromJson(respuesta));
    } on ExcepcionApi catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Widget _galeria(Lugar lugar) {
    final url = lugar.fotos.isEmpty ? '' : lugar.fotos[_indiceFoto].url;
    return Column(
      children: [
        ImagenRed(
          key: ValueKey('main-photo-$_indiceFoto-$url'),
          url: url,
          altura: 230,
          radio: 16,
        ),
        if (lugar.fotos.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lugar.fotos.length,
              itemBuilder: (contexto, indice) => Padding(
                padding: EdgeInsets.only(
                  right: indice == lugar.fotos.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _indiceFoto = indice),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: indice == _indiceFoto
                            ? ColoresApp.violeta
                            : ColoresApp.borde,
                        width: indice == _indiceFoto ? 2.5 : 1,
                      ),
                    ),
                    child: ImagenLugar(
                      url: lugar.fotos[indice].url,
                      altura: 70,
                      ancho: 92,
                      radio: 9,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _informacion(Lugar lugar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          lugar.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColoresApp.azul,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 17,
              color: ColoresApp.violeta,
            ),
            const SizedBox(width: 4),
            Text(
              lugar.ciudad,
              style: const TextStyle(color: ColoresApp.textoSecundario),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.person_outline,
              size: 17,
              color: ColoresApp.violeta,
            ),
            const SizedBox(width: 4),
            Text('Anfitrión: ${lugar.nombreAnfitrion}'),
          ],
        ),
        const SizedBox(height: 16),
        Tarjeta(
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TituloSeccion(
                texto: 'Detalles del alojamiento',
                icono: Icons.info_outline,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: [
                  FilaEspecificacion(
                    icono: Icons.people_outline,
                    texto: '${lugar.cantPersonas} personas',
                  ),
                  FilaEspecificacion(
                    icono: Icons.bed_outlined,
                    texto: '${lugar.cantCamas} camas',
                  ),
                  FilaEspecificacion(
                    icono: Icons.bathtub_outlined,
                    texto: '${lugar.cantBanios} baños',
                  ),
                  FilaEspecificacion(
                    icono: Icons.meeting_room_outlined,
                    texto: '${lugar.cantHabitaciones} habitaciones',
                  ),
                  FilaEspecificacion(
                    icono: lugar.tieneWifi ? Icons.wifi : Icons.wifi_off,
                    texto: lugar.tieneWifi ? 'Wi-Fi' : 'Sin Wi-Fi',
                  ),
                  FilaEspecificacion(
                    icono: Icons.local_parking_outlined,
                    texto: '${lugar.cantVehiculosParqueo} parqueos',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Tarjeta(
          hijo: Column(
            children: [
              const TituloSeccion(
                texto: 'Descripción',
                icono: Icons.description_outlined,
              ),
              const SizedBox(height: 10),
              Text(
                lugar.descripcion.isEmpty
                    ? 'Este alojamiento aún no tiene descripción.'
                    : lugar.descripcion,
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Tarjeta(
          hijo: Column(
            children: [
              FilaPrecio(
                etiqueta: 'Precio por noche',
                valor: FechasUtil.formatearDinero(lugar.precioNoche),
                resaltado: true,
              ),
              const SizedBox(height: 8),
              FilaPrecio(
                etiqueta: 'Costo de limpieza',
                valor: FechasUtil.formatearDinero(lugar.costoLimpieza),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _reservar(Lugar lugar) {
    Navigator.of(context).pushNamed(
      Rutas.confirmarReserva,
      arguments: ArgumentosReserva(
        lugar: lugar,
        fechaLlegada: _llegada,
        fechaSalida: _salida,
      ),
    );
  }

  Widget _barraReserva(Lugar lugar) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: BotonApp(
          texto: 'Reservar',
          icono: Icons.calendar_month,
          alPresionar: () => _reservar(lugar),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lugar = _lugar;
    return Scaffold(
      appBar: AppBar(title: Text(lugar?.nombre ?? 'Detalle del lugar')),
      body: SafeArea(
        child: VistaEstado(
          cargando: _cargando,
          error: _error,
          vacio: lugar == null,
          alReintentar: _cargar,
          contenido: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_galeria(lugar!), _informacion(lugar)],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _lugar == null ? null : _barraReserva(_lugar!),
    );
  }
}
