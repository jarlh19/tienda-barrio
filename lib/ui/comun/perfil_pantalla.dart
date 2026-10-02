import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../estado/providers.dart';
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
      if (mounted) mostrarAviso(context, 'Datos guardados');
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

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
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
              perfil?.esTendero == true ? 'Tendero' : 'Cliente',
              style: t.textTheme.labelLarge
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Celular',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _direccion,
            decoration: const InputDecoration(
              labelText: 'Dirección',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: const Text('Guardar cambios'),
          ),
          if (perfil?.esTendero == true) ...[
            const Divider(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('Cómo me pagan'),
                subtitle: const Text('Número y QR de Yape / Plin'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TiendaPantalla()),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.read(sesionProvider.notifier).cerrarSesion(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              Config.modoDemo
                  ? '${Config.nombreTienda} · modo demo'
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
