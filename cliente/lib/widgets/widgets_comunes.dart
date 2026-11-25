import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cliente/models/lugar.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/fechas_util.dart';
import 'package:cliente/utils/imagen_url.dart';

import 'imagen_red_stub.dart'
    if (dart.library.html) 'imagen_red_web.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.icono,
    this.esClave = false,
    this.tipo = TextInputType.text,
    this.validador,
    this.lineas = 1,
    this.habilitado = true,
    this.textoAyuda,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final IconData icono;
  final bool esClave;
  final TextInputType tipo;
  final String? Function(String?)? validador;
  final int lineas;
  final bool habilitado;
  final String? textoAyuda;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: esClave,
      keyboardType: tipo,
      maxLines: lineas,
      enabled: habilitado,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: textoAyuda,
        prefixIcon: Icon(icono, color: ColoresApp.violeta),
        suffixIcon: esClave
            ? const Icon(Icons.lock_outline, color: ColoresApp.textoSecundario)
            : null,
      ),
    );
  }
}

class BotonApp extends StatelessWidget {
  const BotonApp({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.cargando = false,
    this.secundario = false,
    this.icono,
    this.expandido = true,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final bool cargando;
  final bool secundario;
  final IconData? icono;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final boton = ElevatedButton(
      onPressed: cargando ? null : alPresionar,
      style: secundario
          ? ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.blanco,
              foregroundColor: ColoresApp.violeta,
              side: const BorderSide(color: ColoresApp.violeta),
            )
          : null,
      child: cargando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColoresApp.blanco,
              ),
            )
          : Row(
              mainAxisSize: expandido ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, size: 19),
                  const SizedBox(width: 8),
                ],
                Text(texto),
              ],
            ),
    );

    return expandido ? SizedBox(width: double.infinity, child: boton) : boton;
  }
}

class SelectorCantidad extends StatelessWidget {
  const SelectorCantidad({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    this.minimo = 1,
    this.maximo = 30,
  });

  final String etiqueta;
  final int valor;
  final ValueChanged<int> alCambiar;
  final int minimo;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: const Icon(Icons.people_outline, color: ColoresApp.violeta),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$valor', style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                onPressed: valor > minimo ? () => alCambiar(valor - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: ColoresApp.violeta,
              ),
              IconButton(
                onPressed: valor < maximo ? () => alCambiar(valor + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: ColoresApp.violeta,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CampoFecha extends StatelessWidget {
  const CampoFecha({
    super.key,
    required this.etiqueta,
    required this.fecha,
    required this.alElegir,
    this.fechaMinima,
    this.fechaMaxima,
    this.obligatorio = true,
  });

  final String etiqueta;
  final DateTime? fecha;
  final ValueChanged<DateTime> alElegir;
  final DateTime? fechaMinima;
  final DateTime? fechaMaxima;
  final bool obligatorio;

  @override
  Widget build(BuildContext context) {
    final hoy = FechasUtil.soloFecha(DateTime.now());

    return FormField<DateTime>(
      key: ValueKey('$etiqueta-$fecha'),
      initialValue: fecha,
      validator: (valor) =>
          obligatorio && valor == null ? 'Selecciona $etiqueta' : null,
      builder: (estado) => InkWell(
        onTap: () async {
          final elegida = await FechasUtil.elegirFecha(
            context,
            fechaInicial: fecha ?? hoy,
            fechaMinima: fechaMinima ?? hoy,
            fechaMaxima: fechaMaxima,
          );
          if (elegida != null) alElegir(elegida);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: etiqueta,
            errorText: estado.errorText,
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: ColoresApp.violeta,
            ),
            suffixIcon: const Icon(
              Icons.expand_more,
              color: ColoresApp.textoSecundario,
            ),
          ),
          child: Text(
            FechasUtil.formatearInterfaz(fecha),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.hijo,
    this.alTocar,
    this.relleno = const EdgeInsets.all(14),
  });

  final Widget hijo;
  final VoidCallback? alTocar;
  final EdgeInsets relleno;

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(padding: relleno, child: hijo);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: alTocar == null
          ? contenido
          : InkWell(onTap: alTocar, child: contenido),
    );
  }
}

Widget _iconoImagenNoDisponible() =>
    const Icon(Icons.image_not_supported, size: 48, color: ColoresApp.violeta);

class ImagenRed extends StatelessWidget {
  const ImagenRed({
    super.key,
    required this.url,
    this.altura = 160,
    this.ancho,
    this.ajuste = BoxFit.cover,
    this.radio = 12,
  });

  final String url;
  final double altura;
  final double? ancho;
  final BoxFit ajuste;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final urlNormalizada = obtenerUrlImagen(url);
    final uri = urlNormalizada.isEmpty ? null : Uri.tryParse(urlNormalizada);
    final imagen = uri == null
        ? _iconoImagenNoDisponible()
        : kIsWeb
        ? construirImagenWeb(url: urlNormalizada, ajuste: ajuste, radio: radio)
        : Image.network(
            urlNormalizada,
            fit: ajuste,
            errorBuilder: (_, _, _) => _iconoImagenNoDisponible(),
            loadingBuilder: (contexto, hijo, progreso) =>
                progreso == null && contexto.mounted
                ? hijo
                : const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColoresApp.violeta,
                    ),
                  ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: SizedBox(
        height: altura,
        width: ancho ?? double.infinity,
        child: Container(
          color: ColoresApp.lavanda.withValues(alpha: 0.35),
          alignment: Alignment.center,
          child: imagen,
        ),
      ),
    );
  }
}

class ImagenLugar extends StatelessWidget {
  const ImagenLugar({
    super.key,
    required this.url,
    this.altura = 160,
    this.ancho,
    this.ajuste = BoxFit.cover,
    this.radio = 12,
  });

  final String url;
  final double altura;
  final double? ancho;
  final BoxFit ajuste;
  final double radio;

  @override
  Widget build(BuildContext context) => ImagenRed(
    url: url,
    altura: altura,
    ancho: ancho,
    ajuste: ajuste,
    radio: radio,
  );
}

class FilaEspecificacion extends StatelessWidget {
  const FilaEspecificacion({
    super.key,
    required this.icono,
    required this.texto,
  });

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 18, color: ColoresApp.violeta),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class FilaPrecio extends StatelessWidget {
  const FilaPrecio({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.resaltado = false,
    this.colorEtiqueta = ColoresApp.textoSecundario,
  });

  final String etiqueta;
  final String valor;
  final bool resaltado;
  final Color colorEtiqueta;

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontSize: resaltado ? 17 : 14,
      fontWeight: resaltado ? FontWeight.bold : FontWeight.normal,
      color: resaltado ? ColoresApp.violeta : ColoresApp.azul,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: TextStyle(color: colorEtiqueta)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(valor, style: estilo, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

class TituloSeccion extends StatelessWidget {
  const TituloSeccion({super.key, required this.texto, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icono != null) ...[
          Icon(icono, color: ColoresApp.violeta, size: 21),
          const SizedBox(width: 8),
        ],
        Text(
          texto,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColoresApp.azul,
          ),
        ),
      ],
    );
  }
}

class VistaEstado extends StatelessWidget {
  const VistaEstado({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.contenido,
    this.mensajeVacio = 'No hay resultados para tu búsqueda.',
    this.alReintentar,
  });

  final bool cargando;
  final String? error;
  final bool vacio;
  final Widget contenido;
  final String mensajeVacio;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(color: ColoresApp.violeta),
      );
    }
    if (error != null && error!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: ColoresApp.violeta,
              ),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              if (alReintentar != null) ...[
                const SizedBox(height: 16),
                BotonApp(
                  texto: 'Reintentar',
                  alPresionar: alReintentar,
                  expandido: false,
                  icono: Icons.refresh,
                ),
              ],
            ],
          ),
        ),
      );
    }
    if (vacio) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 42, color: ColoresApp.violeta),
              const SizedBox(height: 12),
              Text(mensajeVacio, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return contenido;
  }
}

class TarjetaLugar extends StatelessWidget {
  const TarjetaLugar({super.key, required this.lugar, required this.alTocar});

  final Lugar lugar;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      alTocar: alTocar,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImagenLugar(url: lugar.fotoPrincipal, altura: 150),
          const SizedBox(height: 10),
          Text(
            lugar.nombre,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColoresApp.azul,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lugar.descripcion.isEmpty ? 'Sin descripción' : lugar.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ColoresApp.textoSecundario),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              FilaEspecificacion(
                icono: Icons.people_outline,
                texto: '${lugar.cantPersonas} personas',
              ),
              FilaEspecificacion(
                icono: Icons.location_on_outlined,
                texto: lugar.ciudad,
              ),
            ],
          ),
          const Divider(height: 18, color: ColoresApp.borde),
          FilaPrecio(
            etiqueta: 'Precio por noche',
            valor: FechasUtil.formatearDinero(lugar.precioNoche),
            resaltado: true,
          ),
        ],
      ),
    );
  }
}
