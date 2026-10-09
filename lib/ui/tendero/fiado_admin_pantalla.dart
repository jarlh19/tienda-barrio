import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../cliente/mi_fiado_pantalla.dart';
import '../../core/config.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class FiadoAdminPantalla extends ConsumerWidget {
  const FiadoAdminPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuentas = ref.watch(cuentasFiadoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).navFiado)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(cuentasFiadoProvider),
        child: AsyncVista(
          valor: cuentas,
          alReintentar: () => ref.invalidate(cuentasFiadoProvider),
          constructor: (lista) {
            if (lista.isEmpty) {
              return EstadoVacio(
                icono: Icons.people_outline,
                titulo: L.of(context).sinClientes,
                detalle: L.of(context).sinClientesDetalle,
              );
            }
            final total = lista.fold<double>(0, (s, c) => s + c.saldo);
            final deudores = lista.where((c) => c.saldo > 0).length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(L.of(context).teDebenEnTotal,
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          Formato.soles(total),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(L.of(context).clientesConSaldo(deudores)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final c in lista)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _abrirCuenta(context, c),
                      leading: CircleAvatar(
                        child: Text(c.clienteNombre.isEmpty
                            ? '?'
                            : c.clienteNombre.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(c.clienteNombre),
                      subtitle: Text(
                        L.of(context).cupoYDisponible(
                            Formato.soles(c.limite),
                            Formato.soles(c.disponible)),
                      ),
                      trailing: Text(
                        Formato.soles(c.saldo),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: c.saldo > 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _abrirCuenta(BuildContext context, CuentaFiado cuenta) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, controlador) =>
          _DetalleCuenta(cuenta: cuenta, controlador: controlador),
    ),
  );
}

class _DetalleCuenta extends ConsumerWidget {
  const _DetalleCuenta({required this.cuenta, required this.controlador});

  final CuentaFiado cuenta;
  final ScrollController controlador;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      controller: controlador,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text(cuenta.clienteNombre,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ResumenFiado(cuenta: cuenta),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    _registrar(context, ref, cuenta, TipoMovimiento.abono),
                icon: const Icon(Icons.payments_outlined),
                label: Text(L.of(context).abono),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _registrar(context, ref, cuenta, TipoMovimiento.cargo),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(L.of(context).cargo),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => _cambiarLimite(context, ref, cuenta),
          icon: const Icon(Icons.tune),
          label: Text(L.of(context).cambiarCupo),
        ),
        const Divider(height: 24),
        Text(L.of(context).movimientos,
            style: Theme.of(context).textTheme.titleSmall),
        if (cuenta.movimientos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(L.of(context).sinMovimientosPunto,
                textAlign: TextAlign.center),
          ),
        for (final m in cuenta.movimientos) FilaMovimiento(movimiento: m),
      ],
    );
  }
}

Future<void> _registrar(
  BuildContext context,
  WidgetRef ref,
  CuentaFiado cuenta,
  TipoMovimiento tipo,
) async {
  final monto = TextEditingController();
  final detalle = TextEditingController();
  final esAbono = tipo == TipoMovimiento.abono;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(esAbono
          ? L.of(context).registrarAbono
          : L.of(context).registrarConsumo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: monto,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                labelText: L.of(context).campoMonto,
                prefixText: '${Config.simboloMoneda} '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: detalle,
            decoration: InputDecoration(
              labelText: L.of(context).campoDetalle,
              hintText: esAbono
                  ? L.of(context).detalleAbonoEjemplo
                  : L.of(context).detalleCargoEjemplo,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(L.of(context).cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(L.of(context).guardar),
        ),
      ],
    ),
  );

  if (confirmado != true) return;
  final valor = double.tryParse(monto.text.replaceAll(',', '.'));
  if (valor == null || valor <= 0) {
    if (context.mounted) mostrarAviso(context, L.of(context).montoInvalido);
    return;
  }

  try {
    await ref.read(fiadoRepoProvider).registrarMovimiento(
          MovimientoFiado(
            id: '',
            clienteId: cuenta.clienteId,
            tipo: tipo,
            monto: valor,
            fecha: DateTime.now(),
            descripcion: detalle.text.trim(),
          ),
        );
    if (!context.mounted) return;
    ref.invalidate(cuentasFiadoProvider);
    ref.invalidate(miCuentaFiadoProvider);
    Navigator.of(context).pop(); // cierra la hoja para recargar con datos nuevos
    mostrarAviso(
        context,
        esAbono
            ? L.of(context).abonoRegistrado
            : L.of(context).consumoRegistrado);
  } catch (e) {
    if (context.mounted) mostrarError(context, e);
  }
}

Future<void> _cambiarLimite(
  BuildContext context,
  WidgetRef ref,
  CuentaFiado cuenta,
) async {
  final ctrl =
      TextEditingController(text: cuenta.limite.toStringAsFixed(0));
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(L.of(context).cupoDeFiado),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: L.of(context).campoMaximo,
            prefixText: '${Config.simboloMoneda} '),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(L.of(context).cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(L.of(context).guardar),
        ),
      ],
    ),
  );
  if (confirmado != true) return;
  final valor = double.tryParse(ctrl.text.replaceAll(',', '.'));
  if (valor == null || valor < 0) {
    if (context.mounted) mostrarAviso(context, L.of(context).montoInvalido);
    return;
  }
  try {
    await ref.read(fiadoRepoProvider).cambiarLimite(cuenta.clienteId, valor);
    if (!context.mounted) return;
    ref.invalidate(cuentasFiadoProvider);
    ref.invalidate(miCuentaFiadoProvider);
    Navigator.of(context).pop();
    mostrarAviso(context, L.of(context).cupoActualizado);
  } catch (e) {
    if (context.mounted) mostrarError(context, e);
  }
}
