class Parseo {
  const Parseo._();

  static int entero(dynamic valor, {int porDefecto = 0}) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    if (valor is String) return int.tryParse(valor) ?? porDefecto;
    return porDefecto;
  }

  static double decimal(dynamic valor, {double porDefecto = 0}) {
    if (valor is double) return valor;
    if (valor is num) return valor.toDouble();
    if (valor is String) {
      return double.tryParse(valor.replaceAll(',', '.')) ?? porDefecto;
    }
    return porDefecto;
  }

  static String texto(dynamic valor, {String porDefecto = ''}) {
    if (valor == null) return porDefecto;
    final texto = valor.toString().trim();
    return texto.isEmpty ? porDefecto : texto;
  }

  static bool booleano(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;
    if (valor is String) {
      const verdaderos = {'1', 'true', 'sí', 'si'};
      return verdaderos.contains(valor.toLowerCase());
    }
    return false;
  }

  static List<Map<String, dynamic>> lista(dynamic valor) {
    if (valor is List) return valor.whereType<Map<String, dynamic>>().toList();
    if (valor is Map<String, dynamic>) return <Map<String, dynamic>>[valor];
    return <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> mapa(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }
    return <String, dynamic>{};
  }
}
