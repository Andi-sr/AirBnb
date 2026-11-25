import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final Map<String, String> _tiposVista = <String, String>{};
int _secuenciaVista = 0;

Widget construirImagenWeb({
  required String url,
  required BoxFit ajuste,
  required double radio,
}) {
  final clave = '$url|$ajuste|$radio';
  final tipo = _tiposVista.putIfAbsent(clave, () {
    final nombre = 'imagen_red_${_secuenciaVista++}';
    ui_web.platformViewRegistry.registerViewFactory(nombre, (int viewId) {
      final elemento =
          web.document.createElement('img') as web.HTMLImageElement;
      elemento.setAttribute('src', url);
      elemento.setAttribute('alt', 'Imagen del alojamiento');
      elemento.setAttribute('loading', 'lazy');
      elemento.setAttribute('decoding', 'async');
      elemento.style.setProperty('display', 'block');
      elemento.style.setProperty('width', '100%');
      elemento.style.setProperty('height', '100%');
      elemento.style.setProperty('object-fit', _ajusteCss(ajuste));
      elemento.style.setProperty('border-radius', '${radio}px');
      elemento.style.pointerEvents = 'none';
      return elemento;
    });
    return nombre;
  });
  return IgnorePointer(child: HtmlElementView(viewType: tipo));
}

String _ajusteCss(BoxFit ajuste) {
  switch (ajuste) {
    case BoxFit.contain:
    case BoxFit.scaleDown:
      return 'contain';
    case BoxFit.fill:
      return 'fill';
    case BoxFit.none:
      return 'none';
    case BoxFit.cover:
    case BoxFit.fitHeight:
    case BoxFit.fitWidth:
      return 'cover';
  }
}
