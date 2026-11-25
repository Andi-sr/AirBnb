import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:cliente/models/lugar.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/ciudades_bolivia.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({super.key, required this.argumentos});

  final ArgumentosResultados argumentos;

  @override
  State<ResultadosScreen> createState() => _EstadoResultados();
}

class _EstadoResultados extends State<ResultadosScreen> {
  final _controladorLista = ScrollController();
  final MapController _controladorMapa = MapController();
  bool _vistaMapa = false;

  @override
  void dispose() {
    _controladorLista.dispose();
    _controladorMapa.dispose();
    super.dispose();
  }

  void _abrirDetalle(Lugar lugar) {
    Navigator.of(context).pushNamed(
      Rutas.detalle,
      arguments: ArgumentosDetalle(
        lugar: lugar,
        fechaLlegada: widget.argumentos.fechaLlegada,
        fechaSalida: widget.argumentos.fechaSalida,
        cantidadHuespedes: widget.argumentos.cantidadHuespedes,
      ),
    );
  }

  Future<void> _mostrarResumen(Lugar lugar) async {
    final seleccionado = await showModalBottomSheet<Lugar>(
      context: context,
      showDragHandle: true,
      builder: (contexto) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lugar.nombre,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.azul,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${lugar.ciudad} · ${lugar.cantPersonas} personas',
                style: const TextStyle(color: ColoresApp.textoSecundario),
              ),
              const SizedBox(height: 8),
              Text(
                lugar.descripcion.isEmpty
                    ? 'Sin descripción'
                    : lugar.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              FilaPrecio(
                etiqueta: 'Precio por noche',
                valor: FechasUtil.formatearDinero(lugar.precioNoche),
                resaltado: true,
              ),
              const SizedBox(height: 16),
              BotonApp(
                texto: 'Ver detalle',
                icono: Icons.open_in_new,
                alPresionar: () => Navigator.of(contexto).pop(lugar),
              ),
            ],
          ),
        ),
      ),
    );
    if (seleccionado != null && mounted) _abrirDetalle(seleccionado);
  }

  LatLng _centro() {
    final ciudad =
        CiudadesBolivia.buscarCiudad(widget.argumentos.ciudad) ??
        CiudadesBolivia.centroPorDefecto();
    return ciudad.ubicacion;
  }

  void _cambiarZoom(double delta) {
    final camara = _controladorMapa.camera;
    final zoom = (camara.zoom + delta).clamp(2.0, 18.0).toDouble();
    _controladorMapa.move(camara.center, zoom);
  }

  Widget _botonZoom(IconData icono, String etiqueta, VoidCallback alPresionar) {
    return FloatingActionButton(
      heroTag: etiqueta,
      mini: true,
      onPressed: alPresionar,
      backgroundColor: ColoresApp.blanco,
      foregroundColor: ColoresApp.azul,
      tooltip: etiqueta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColoresApp.borde),
      ),
      child: Icon(icono),
    );
  }

  Widget _vistaLista() {
    final lugares = widget.argumentos.lugares;
    return VistaEstado(
      cargando: false,
      error: null,
      vacio: lugares.isEmpty,
      contenido: ListView.separated(
        controller: _controladorLista,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        itemCount: lugares.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (contexto, indice) => TarjetaLugar(
          lugar: lugares[indice],
          alTocar: () => _abrirDetalle(lugares[indice]),
        ),
      ),
    );
  }

  Widget _vistaDelMapa() {
    final marcadores = widget.argumentos.lugares
        .where((lugar) => lugar.tieneUbicacion)
        .map(
          (lugar) => Marker(
            point: lugar.ubicacion,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _mostrarResumen(lugar),
              child: const Icon(
                Icons.place,
                color: ColoresApp.violeta,
                size: 42,
                shadows: [Shadow(color: ColoresApp.azul, blurRadius: 4)],
              ),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _controladorMapa,
          options: MapOptions(initialCenter: _centro(), initialZoom: 12.5),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.proyectofinal.cliente',
            ),
            MarkerLayer(markers: marcadores),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 96,
          child: Column(
            children: [
              _botonZoom(Icons.add, 'Acercar', () => _cambiarZoom(1)),
              const SizedBox(height: 10),
              _botonZoom(Icons.remove, 'Alejar', () => _cambiarZoom(-1)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantidad = widget.argumentos.lugares.length;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('$cantidad ${cantidad == 1 ? 'lugar' : 'lugares'}'),
            Text(
              '${widget.argumentos.ciudad} · '
              '${FechasUtil.formatearInterfaz(widget.argumentos.fechaLlegada)} - '
              '${FechasUtil.formatearInterfaz(widget.argumentos.fechaSalida)}',
              style: const TextStyle(
                fontSize: 13,
                color: ColoresApp.blanco,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _vistaMapa ? 1 : 0,
        children: [_vistaLista(), _vistaDelMapa()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cambiar-vista',
        onPressed: () => setState(() => _vistaMapa = !_vistaMapa),
        icon: Icon(_vistaMapa ? Icons.list : Icons.map),
        label: Text(_vistaMapa ? 'Vista de lista' : 'Vista de mapa'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
