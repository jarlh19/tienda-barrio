import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class LoginPantalla extends ConsumerStatefulWidget {
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _clave = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();

  /// El formulario nace escondido: el camino corto es Google. Solo aparece si
  /// el vecino lo pide, o si Google no está disponible en este dispositivo.
  bool _usarCorreo = false;
  bool _registrando = false;
  bool _ocultarClave = true;
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _clave.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  /// Envuelve cualquier entrada: apaga los botones mientras trabaja y muestra
  /// el error sin dejar la pantalla trabada.
  Future<void> _intentar(Future<void> Function() accion) async {
    setState(() => _cargando = true);
    try {
      await accion();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _entrarGoogle() => _intentar(
        () => ref.read(sesionProvider.notifier).entrarConGoogle(),
      );

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    await _intentar(() async {
      final sesion = ref.read(sesionProvider.notifier);
      if (_registrando) {
        await sesion.registrar(
          nombre: _nombre.text.trim(),
          email: _email.text,
          clave: _clave.text,
          telefono: _telefono.text.trim(),
          direccion: _direccion.text.trim(),
        );
      } else {
        await sesion.iniciarSesion(_email.text, _clave.text);
      }
    });
  }

  /// Atajo del modo demo. No pasa por `_enviar` a propósito: si el formulario
  /// está en registro, sus validadores (nombre) aún viven en este frame y
  /// bloquearían el acceso.
  Future<void> _entrarDemo(String email) async {
    _email.text = email;
    _clave.text = 'demo1234';
    setState(() => _registrando = false);
    await _intentar(
      () => ref.read(sesionProvider.notifier).iniciarSesion(email, 'demo1234'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = L.of(context);
    final hayGoogle = ref.watch(hayGoogleProvider);
    // Sin Google no hay alternativa que ofrecer: el formulario es el camino.
    final mostrarForm = _usarCorreo || !hayGoogle;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.storefront,
                        size: 64, color: t.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      Config.nombreTienda,
                      textAlign: TextAlign.center,
                      style: t.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.loginLema,
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodyMedium
                          ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    if (hayGoogle) ...[
                      _BotonGoogle(
                        onPressed: _cargando ? null : _entrarGoogle,
                        cargando: _cargando,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.loginGoogleDetalle,
                        textAlign: TextAlign.center,
                        style: t.textTheme.bodySmall
                            ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                      if (!mostrarForm)
                        TextButton(
                          onPressed: _cargando
                              ? null
                              : () => setState(() => _usarCorreo = true),
                          child: Text(l.loginPrefieroCorreo),
                        ),
                    ],
                    if (mostrarForm) ...[
                      if (hayGoogle)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  l.loginOCorreo,
                                  style: t.textTheme.labelMedium?.copyWith(
                                      color: t.colorScheme.onSurfaceVariant),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        ),
                      if (_registrando) ...[
                        TextFormField(
                          controller: _nombre,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l.campoNombre,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().length < 2)
                              ? l.validaNombre
                              : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l.campoCorreo,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? l.validaCorreo
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _clave,
                        obscureText: _ocultarClave,
                        decoration: InputDecoration(
                          labelText: l.campoClave,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_ocultarClave
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _ocultarClave = !_ocultarClave),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? l.validaClave
                            : null,
                      ),
                      if (_registrando) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telefono,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l.campoCelular,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _direccion,
                          decoration: InputDecoration(
                            labelText: l.campoDireccionEntrega,
                            prefixIcon: const Icon(Icons.home_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _cargando ? null : _enviar,
                        child: _cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_registrando
                                ? l.loginCrearCuenta
                                : l.loginEntrar),
                      ),
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () =>
                                setState(() => _registrando = !_registrando),
                        child: Text(_registrando
                            ? l.loginYaTengoCuenta
                            : l.loginNoTengoCuenta),
                      ),
                    ],
                    if (Config.modoDemo) ...[
                      const Divider(height: 32),
                      Text(
                        l.loginDemo,
                        textAlign: TextAlign.center,
                        style: t.textTheme.labelMedium
                            ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cargando
                                  ? null
                                  : () => _entrarDemo('cliente@demo.com'),
                              icon: const Icon(Icons.shopping_basket_outlined),
                              label: Text(l.rolCliente),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _cargando
                                  ? null
                                  : () => _entrarDemo('tendero@demo.com'),
                              icon: const Icon(Icons.storefront_outlined),
                              label: Text(l.rolTendero),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de entrada con Google.
///
/// La "G" va dibujada con texto a propósito: la marca oficial es un archivo que
/// Google entrega en sus guías y que hay que incorporar antes de publicar en
/// Play Store, porque las condiciones de la marca no admiten una imitación.
class _BotonGoogle extends StatelessWidget {
  const _BotonGoogle({required this.onPressed, required this.cargando});

  final VoidCallback? onPressed;
  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: cargando
          ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G',
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4285F4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(L.of(context).loginGoogle),
              ],
            ),
    );
  }
}
