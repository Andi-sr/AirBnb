import 'package:shared_preferences/shared_preferences.dart';

import 'package:cliente/models/cliente.dart';

class SesionUsuario {
  const SesionUsuario._();

  static const String _claveId = 'cliente_id';
  static const String _claveNombre = 'cliente_nombre';
  static const String _claveCorreo = 'cliente_email';
  static const String _claveTelefono = 'cliente_telefono';

  static Future<void> guardar(Cliente cliente) async {
    final preferencias = await SharedPreferences.getInstance();
    await Future.wait([
      preferencias.setInt(_claveId, cliente.id),
      preferencias.setString(_claveNombre, cliente.nombre),
      preferencias.setString(_claveCorreo, cliente.email),
      preferencias.setString(_claveTelefono, cliente.telefono),
    ]);
  }

  static Future<Cliente?> leer() async {
    final preferencias = await SharedPreferences.getInstance();
    final id = preferencias.getInt(_claveId);
    if (id == null) return null;
    return Cliente(
      id: id,
      nombre: preferencias.getString(_claveNombre) ?? '',
      email: preferencias.getString(_claveCorreo) ?? '',
      telefono: preferencias.getString(_claveTelefono) ?? '',
    );
  }

  static Future<void> cerrar() async {
    final preferencias = await SharedPreferences.getInstance();
    await Future.wait([
      preferencias.remove(_claveId),
      preferencias.remove(_claveNombre),
      preferencias.remove(_claveCorreo),
      preferencias.remove(_claveTelefono),
    ]);
  }
}
