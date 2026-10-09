import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/etiquetas.dart';
import '../comun/widgets.dart';

/// Datos de cobro de la tienda. Aquí el tendero pone su número y sube el QR
/// que exportó de Yape o Plin; es lo que verá el cliente al pagar.
class TiendaPantalla extends ConsumerWidget {
  const TiendaPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tienda = ref.watch(tiendaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).comoMePagan)),
      body: AsyncVista(
        valor: tienda,
        alReintentar: () => ref.invalidate(tiendaProvider),
        constructor: (t) => _Formulario(tienda: t),
      ),
    );
  }
}

class _Formulario extends ConsumerStatefulWidget {
  const _Formulario({required this.tienda});

  final Tienda tienda;

  @override
  ConsumerState<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends ConsumerState<_Formulario> {
  late final TextEditingController _yape;
  late final TextEditingController _plin;
  late Tienda _tienda;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tienda = widget.tienda;
    _yape = TextEditingController(text: _tienda.numeroYape);
    _plin = TextEditingController(text: _tienda.numeroPlin);
  }

  @override
  void dispose() {
    _yape.dispose();
    _plin.dispose();
    super.dispose();
  }

  Future<void> _subirQr(MetodoPago metodo) async {
    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
      );
      if (archivo == null) return;

      setState(() => _guardando = true);
      final bytes = await archivo.readAsBytes();
      final extension =
          archivo.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';

      final url = await ref.read(tiendaRepoProvider).subirQr(
            metodo: metodo,
            bytes: bytes,
            extension: extension,
          );

      final actualizada = metodo == MetodoPago.plin
          ? _tienda.copiar(qrPlinUrl: url)
          : _tienda.copiar(qrYapeUrl: url);
      // El QR se guarda al momento: si la app se cierra, la imagen ya subida
      // no queda huérfana sin su fila.
      final guardada = await ref.read(tiendaRepoProvider).guardar(actualizada);

      if (!mounted) return;
      setState(() => _tienda = guardada);
      ref.invalidate(tiendaProvider);
      mostrarAviso(
          context, L.of(context).qrActualizado(metodo.texto(L.of(context))));
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _quitarQr(MetodoPago metodo) async {
    final actualizada = metodo == MetodoPago.plin
        ? _tienda.copiar(qrPlinUrl: '')
        : _tienda.copiar(qrYapeUrl: '');
    await _persistir(actualizada, L.of(context).qrQuitado);
  }

  Future<void> _guardarNumeros() => _persistir(
        _tienda.copiar(
          numeroYape: _yape.text.trim(),
          numeroPlin: _plin.text.trim(),
        ),
        L.of(context).perfilDatosGuardados,
      );

  Future<void> _persistir(Tienda tienda, String aviso) async {
    setState(() => _guardando = true);
    try {
      final guardada = await ref.read(tiendaRepoProvider).guardar(tienda);
      if (!mounted) return;
      setState(() => _tienda = guardada);
      ref.invalidate(tiendaProvider);
      mostrarAviso(context, aviso);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          L.of(context).tiendaExplicacion,
          style: t.textTheme.bodyMedium
              ?.copyWith(color: t.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        _BloqueMetodo(
          metodo: MetodoPago.yape,
          controlador: _yape,
          qrUrl: _tienda.qrYapeUrl,
          ocupado: _guardando,
          alSubir: () => _subirQr(MetodoPago.yape),
          alQuitar: () => _quitarQr(MetodoPago.yape),
        ),
        const SizedBox(height: 16),
        _BloqueMetodo(
          metodo: MetodoPago.plin,
          controlador: _plin,
          qrUrl: _tienda.qrPlinUrl,
          ocupado: _guardando,
          alSubir: () => _subirQr(MetodoPago.plin),
          alQuitar: () => _quitarQr(MetodoPago.plin),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _guardando ? null : _guardarNumeros,
          child: Text(L.of(context).guardarNumeros),
        ),
      ],
    );
  }
}

class _BloqueMetodo extends StatelessWidget {
  const _BloqueMetodo({
    required this.metodo,
    required this.controlador,
    required this.qrUrl,
    required this.ocupado,
    required this.alSubir,
    required this.alQuitar,
  });

  final MetodoPago metodo;
  final TextEditingController controlador;
  final String qrUrl;
  final bool ocupado;
  final VoidCallback alSubir;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(metodo.texto(L.of(context)), style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: controlador,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: L.of(context).campoNumero,
                prefixIcon: const Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 16),
            if (qrUrl.isEmpty)
              _SinQr(ocupado: ocupado, alSubir: alSubir)
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: VistaQr(url: qrUrl, alto: 200),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: ocupado ? null : alSubir,
                        icon: const Icon(Icons.sync),
                        label: Text(L.of(context).cambiar),
                      ),
                      TextButton.icon(
                        onPressed: ocupado ? null : alQuitar,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(L.of(context).quitar),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SinQr extends StatelessWidget {
  const _SinQr({required this.ocupado, required this.alSubir});

  final bool ocupado;
  final VoidCallback alSubir;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, size: 48, color: t.colorScheme.outline),
          const SizedBox(height: 8),
          Text(
            L.of(context).sinQr,
            style: t.textTheme.bodyMedium
                ?.copyWith(color: t.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: ocupado ? null : alSubir,
            icon: const Icon(Icons.upload_outlined),
            label: Text(L.of(context).subirQr),
          ),
        ],
      ),
    );
  }
}

/// Pinta el QR venga de donde venga: una URL de Storage o el data URI que
/// usa el modo demo.
class VistaQr extends StatelessWidget {
  const VistaQr({super.key, required this.url, this.alto = 200});

  final String url;
  final double alto;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:')) {
      final base64 = url.substring(url.indexOf(',') + 1);
      return Image.memory(
        const Base64Decoder().convert(base64),
        height: alto,
        fit: BoxFit.contain,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      height: alto,
      fit: BoxFit.contain,
      placeholder: (_, _) => SizedBox(
        height: alto,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, _, _) => SizedBox(
        height: alto,
        child: Center(child: Text(L.of(context).qrNoCarga)),
      ),
    );
  }
}
