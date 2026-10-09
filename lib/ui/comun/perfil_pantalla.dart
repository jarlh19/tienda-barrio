import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../estado/preferencias.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../tendero/tienda_pantalla.dart';
import 'widgets.dart';

class PerfilPantalla extends ConsumerStatefulWidget {
  const PerfilPantalla({super.key});

  @override
  ConsumerState<PerfilPantalla> createState() => _PerfilPantallaState();
}

class _PerfilPantallaState extends ConsumerState<PerfilPantalla> {
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = ref.read(sesionProvider);
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _telefono = TextEditingController(text: p?.telefono ?? '');
    _direccion = TextEditingController(text: p?.direccion ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final perfil = ref.read(sesionProvider);
    if (perfil == null) return;
    setState(() => _guardando = true);
    try {
      await ref.read(sesionProvider.notifier).guardar(
            perfil.copiar(
              nombre: _nombre.text.trim(),
              telefono: _telefono.text.trim(),
              direccion: _direccion.text.trim(),
            ),
          );
      if (mounted) mostrarAviso(context, L.of(context).perfilDatosGuardados);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = ref.watch(sesionProvider);
    final t = Theme.of(context);
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.perfilTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: t.colorScheme.primaryContainer,
              child: Text(
                (perfil?.nombre.isNotEmpty ?? false)
                    ? perfil!.nombre.substring(0, 1).toUpperCase()
                    : '?',
                style: t.textTheme.headlineMedium
                    ?.copyWith(color: t.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              perfil?.esTendero == true ? l.rolTendero : l.rolCliente,
              style: t.textTheme.labelLarge
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nombre,
            decoration: InputDecoration(
              labelText: l.campoNombre,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefono,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l.campoCelular,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccion,
            decoration: InputDecoration(
              labelText: l.campoDireccion,
              prefixIcon: const Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(l.guardarCambios),
          ),
          if (perfil?.esTendero == true) ...[
            const Divider(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: Text(l.comoMePagan),
                subtitle: Text(l.comoMePaganDetalle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TiendaPantalla()),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Divider(height: 32),
          _Preferencia<ThemeMode>(
            icono: Icons.brightness_6_outlined,
            titulo: l.apariencia,
            valor: ref.watch(temaProvider),
            opciones: {
              ThemeMode.system: l.temaAutomatico,
              ThemeMode.light: l.temaClaro,
              ThemeMode.dark: l.temaOscuro,
            },
            alCambiar: (v) => ref.read(temaProvider.notifier).cambiar(v),
          ),
          const SizedBox(height: 12),
          _Preferencia<String>(
            icono: Icons.translate_outlined,
            titulo: l.idioma,
            // Cadena vacía = automático: `Locale` no tiene un valor para
            // "ninguno" que sirva de clave en el menú.
            valor: ref.watch(idiomaProvider)?.languageCode ?? '',
            opciones: {
              '': l.idiomaAutomatico,
              'es': l.idiomaEspanol,
              'en': l.idiomaIngles,
            },
            alCambiar: (v) => ref
                .read(idiomaProvider.notifier)
                .cambiar(v.isEmpty ? null : Locale(v)),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(sesionProvider.notifier).cerrarSesion(),
            icon: const Icon(Icons.logout),
            label: Text(l.cerrarSesion),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              Config.modoDemo
                  ? l.piePieDemo(Config.nombreTienda)
                  : Config.nombreTienda,
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una preferencia con sus opciones, en una sola fila.
///
/// El menú desplegable gana al grupo de botones porque la pantalla de perfil
/// ya es larga y estas dos opciones se tocan una vez en la vida.
class _Preferencia<T> extends StatelessWidget {
  const _Preferencia({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.opciones,
    required this.alCambiar,
  });

  final IconData icono;
  final String titulo;
  final T valor;
  final Map<T, String> opciones;
  final void Function(T) alCambiar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: DropdownButton<T>(
          value: valor,
          underline: const SizedBox.shrink(),
          onChanged: (v) {
            if (v != null) alCambiar(v);
          },
          items: [
            for (final e in opciones.entries)
              DropdownMenuItem(value: e.key, child: Text(e.value)),
          ],
        ),
      ),
    );
  }
}
