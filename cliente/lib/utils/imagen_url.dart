const String _hostApi = 'api.airbnbmob2.online';
const String _servidorApi = 'https://$_hostApi';
const String _tunelLocal = 'bnb-backend.loca.lt';
const List<String> _clavesImagen = <String>[
  'fotos',
  'url',
  'ruta',
  'imagen',
  'foto',
  'portada',
  'path',
  'archivo',
];

String obtenerUrlImagen(dynamic lugar) {
  final valor = _extraerTexto(lugar).replaceAll(r'\', '/').trim();
  if (valor.isEmpty) return '';

  final uri = Uri.tryParse(valor);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return _normalizarAbsoluta(valor);
  }

  if (valor.startsWith('//')) return _normalizarAbsoluta('https:$valor');

  return _normalizarRuta(valor);
}

String _normalizarAbsoluta(String valor) {
  var url = valor.replaceFirst('http://', 'https://');
  url = url.replaceFirst('://www.$_hostApi', '://$_hostApi');
  url = url.replaceFirst('://$_tunelLocal', '://$_hostApi');
  return _codificar(url);
}

String _normalizarRuta(String valor) {
  final limpia = valor.replaceFirst(RegExp(r'^/+'), '');
  final sinApi = limpia.replaceFirst(RegExp(r'^api/+'), '');
  return _codificar('$_servidorApi/$sinApi');
}

String _codificar(String valor) => valor.replaceAll(' ', '%20');

String _extraerTexto(dynamic lugar) {
  if (lugar is String) return lugar.trim();
  if (lugar is List) {
    for (final elemento in lugar) {
      final texto = _extraerTexto(elemento);
      if (texto.isNotEmpty) return texto;
    }
    return '';
  }
  if (lugar is Map) {
    for (final clave in _clavesImagen) {
      final texto = _extraerTexto(lugar[clave]);
      if (texto.isNotEmpty) return texto;
    }
  }
  return '';
}
