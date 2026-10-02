import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/carrito.dart';
import '../../estado/checkout.dart';
import '../../estado/providers.dart';
import '../comun/widgets.dart';
import '../tendero/tienda_pantalla.dart' show VistaQr;

class CheckoutPantalla extends ConsumerStatefulWidget {
  const CheckoutPantalla({super.key});

  @override
  ConsumerState<CheckoutPantalla> createState() => _CheckoutPantallaState();
}

class _CheckoutPantallaState extends ConsumerState<CheckoutPantalla> {
  late final TextEditingController _direccion;
  final _notas = TextEditingController();
  final _referencia = TextEditingController();

  MetodoPago _metodo = MetodoPago.efectivo;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _direccion =
        TextEditingController(text: ref.read(sesionProvider)?.direccion ?? '');
  }

  @override
  void dispose() {
    _direccion.dispose();
    _notas.dispose();
    _referencia.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      final pedido = await ref.read(checkoutProvider).confirmar(
            metodo: _metodo,
            direccion: _direccion.text,
            referencia: _referencia.text,
            notas: _notas.text,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, size: 40),
          title: const Text('¡Pedido enviado!'),
          content: Text(
            'Tu pedido ${pedido.codigo} por ${Formato.soles(pedido.total)} '
            'llegó a la tienda.\n\n${pedido.estadoPago.etiqueta}.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/pedidos');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final items = ref.watch(carritoProvider);
    final total = ref.watch(totalCarritoProvider);
    final cuenta = ref.watch(miCuentaFiadoProvider).valueOrNull;
    final tienda = ref.watch(tiendaProvider).valueOrNull ?? const Tienda();

    return Scaffold(
      appBar: AppBar(title: const Text('Pagar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Seccion(
            titulo: 'Entrega',
            hijo: Column(
              children: [
                TextField(
                  controller: _direccion,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notas,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nota para la tienda (opcional)',
                    hintText: 'Ej.: tocar el timbre 2 veces',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Seccion(
            titulo: 'Forma de pago',
            hijo: Column(
              children: [
                RadioGroup<MetodoPago>(
                  groupValue: _metodo,
                  onChanged: (v) => setState(() => _metodo = v!),
                  child: Column(
                    children: [
                      for (final m in MetodoPago.values)
                        RadioListTile<MetodoPago>(
                          value: m,
                          contentPadding: EdgeInsets.zero,
                          title: Text(m.etiqueta),
                          subtitle: _subtituloMetodo(m, cuenta, total, tienda),
                          enabled: _habilitado(m, cuenta, total, tienda),
                        ),
                    ],
                  ),
                ),
                if (_metodo.requiereComprobante) ...[
                  const SizedBox(height: 8),
                  _DatosDeCobro(
                    metodo: _metodo,
                    tienda: tienda,
                    total: total,
                    referencia: _referencia,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Seccion(
            titulo: 'Resumen (${items.length} productos)',
            hijo: Column(
              children: [
                for (final i in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text('${i.cantidad} × ${i.nombre}')),
                        Text(Formato.soles(i.subtotal)),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: t.textTheme.titleMedium),
                    Text(
                      Formato.soles(total),
                      style: t.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enviando || items.isEmpty ? null : _confirmar,
            child: _enviando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Confirmar pedido · ${Formato.soles(total)}'),
          ),
        ],
      ),
    );
  }

  bool _habilitado(
      MetodoPago m, CuentaFiado? cuenta, double total, Tienda tienda) {
    if (m == MetodoPago.tarjeta) return false; // pasarela aún no conectada
    if (m == MetodoPago.fiado) return cuenta != null && cuenta.alcanzaPara(total);
    // Yape y Plin solo si la tienda ya dijo a dónde le pagan.
    if (m.requiereComprobante) return tienda.aceptaPagoCon(m);
    return true;
  }

  Widget? _subtituloMetodo(
      MetodoPago m, CuentaFiado? cuenta, double total, Tienda tienda) {
    if (m == MetodoPago.tarjeta) {
      return const Text('Próximamente');
    }
    if (m.requiereComprobante && !tienda.aceptaPagoCon(m)) {
      return const Text('La tienda aún no lo tiene configurado');
    }
    if (m == MetodoPago.fiado) {
      if (cuenta == null) return const Text('Sin cuenta de fiado');
      final texto = 'Disponible ${Formato.soles(cuenta.disponible)} '
          'de ${Formato.soles(cuenta.limite)}';
      return Text(
        cuenta.alcanzaPara(total) ? texto : '$texto — no alcanza para este pedido',
      );
    }
    return null;
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijo});

  final String titulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            hijo,
          ],
        ),
      ),
    );
  }
}

/// Lo que el cliente necesita para pagar: el QR que subió el tendero, el
/// número por si prefiere teclearlo, y el código de operación de vuelta.
class _DatosDeCobro extends StatelessWidget {
  const _DatosDeCobro({
    required this.metodo,
    required this.tienda,
    required this.total,
    required this.referencia,
  });

  final MetodoPago metodo;
  final Tienda tienda;
  final double total;
  final TextEditingController referencia;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final qr = tienda.qrDe(metodo);
    final numero = tienda.numeroDe(metodo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Paga ${Formato.soles(total)} con ${metodo.etiqueta}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: t.colorScheme.onSecondaryContainer,
            ),
          ),
          if (qr.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: VistaQr(url: qr, alto: 220),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Escanea el QR desde tu app, o guarda la imagen si estás pagando '
              'desde este mismo celular.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.onSecondaryContainer),
            ),
          ],
          if (numero.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone_android,
                    size: 18, color: t.colorScheme.onSecondaryContainer),
                const SizedBox(width: 6),
                Expanded(
                  child: SelectableText(
                    numero,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                BotonCopiar(
                  texto: numero,
                  aviso: 'Número copiado. Pégalo en ${metodo.etiqueta}.',
                  color: t.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: referencia,
            decoration: const InputDecoration(
              labelText: 'Código de operación',
              hintText: 'Ej.: 00123456',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
