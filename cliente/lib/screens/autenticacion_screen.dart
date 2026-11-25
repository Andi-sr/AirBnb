import 'package:flutter/material.dart';

import 'package:cliente/models/cliente.dart';
import 'package:cliente/services/servicio_api.dart';
import 'package:cliente/theme/colores_app.dart';
import 'package:cliente/utils/rutas.dart';
import 'package:cliente/utils/sesion_util.dart';
import 'package:cliente/widgets/widgets_comunes.dart';

class AutenticacionScreen extends StatefulWidget {
  const AutenticacionScreen({super.key});

  @override
  State<AutenticacionScreen> createState() => _EstadoAutenticacion();
}

class _EstadoAutenticacion extends State<AutenticacionScreen> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorClave = TextEditingController();
  final _controladorTelefono = TextEditingController();

  bool _esRegistro = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCorreo.dispose();
    _controladorClave.dispose();
    _controladorTelefono.dispose();
    super.dispose();
  }

  Future<Cliente> _iniciarSesion() async {
    final respuesta = await ServicioApi.instancia.enviarFormulario(
      '/cliente/login',
      {
        'email': _controladorCorreo.text.trim(),
        'password': _controladorClave.text,
      },
    );
    return Cliente.fromRespuesta(respuesta);
  }

  Future<Cliente> _registrar() async {
    final datos = {
      'nombre': _controladorNombre.text.trim(),
      'email': _controladorCorreo.text.trim(),
      'password': _controladorClave.text,
      'telefono': _controladorTelefono.text.trim(),
    };
    try {
      return Cliente.fromRespuesta(
        await ServicioApi.instancia.enviarFormulario('/cliente/registro', datos),
      );
    } on ExcepcionApi {
      return _iniciarSesion();
    }
  }

  Future<void> _enviar() async {
    if (!_claveFormulario.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final cliente = _esRegistro ? await _registrar() : await _iniciarSesion();
      await SesionUsuario.guardar(cliente);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        Rutas.busqueda,
        (ruta) => false,
      );
    } on ExcepcionApi catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String? _validarCorreo(String? valor) {
    if (valor == null || !valor.contains('@') || !valor.contains('.')) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validarClave(String? valor) {
    if (valor == null || valor.length < 4) return 'Mínimo 4 caracteres';
    return null;
  }

  String? _validarRequerido(String? valor, String etiqueta) {
    if (valor == null || valor.trim().isEmpty) return 'Ingresa $etiqueta';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.holiday_village, size: 70, color: ColoresApp.violeta),
              const SizedBox(height: 16),
              const Text(
                'Estadía',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: ColoresApp.azul,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _esRegistro
                    ? 'Crea tu cuenta para empezar a reservar'
                    : 'Ingresa para encontrar tu próxima estadía',
                textAlign: TextAlign.center,
                style: const TextStyle(color: ColoresApp.textoSecundario),
              ),
              const SizedBox(height: 30),
              Form(
                key: _claveFormulario,
                child: Column(
                  children: [
                    if (_esRegistro) ...[
                      CampoTexto(
                        controlador: _controladorNombre,
                        etiqueta: 'Nombre completo',
                        icono: Icons.person_outline,
                        validador: (valor) =>
                            _validarRequerido(valor, 'tu nombre'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    CampoTexto(
                      controlador: _controladorCorreo,
                      etiqueta: 'Correo electrónico',
                      icono: Icons.email_outlined,
                      tipo: TextInputType.emailAddress,
                      validador: _validarCorreo,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      controlador: _controladorClave,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock_outline,
                      esClave: true,
                      validador: _validarClave,
                    ),
                    if (_esRegistro) ...[
                      const SizedBox(height: 16),
                      CampoTexto(
                        controlador: _controladorTelefono,
                        etiqueta: 'Teléfono',
                        icono: Icons.phone_outlined,
                        tipo: TextInputType.phone,
                        validador: (valor) =>
                            _validarRequerido(valor, 'tu teléfono'),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFB3261E)),
                      ),
                    ],
                    const SizedBox(height: 24),
                    BotonApp(
                      texto: _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                      alPresionar: _enviar,
                      cargando: _cargando,
                      icono: _esRegistro ? Icons.person_add : Icons.login,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _cargando
                    ? null
                    : () => setState(() {
                          _esRegistro = !_esRegistro;
                          _error = null;
                        }),
                child: Text(
                  _esRegistro
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
