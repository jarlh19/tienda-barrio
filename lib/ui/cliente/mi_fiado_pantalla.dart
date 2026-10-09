import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class MiFiadoPantalla extends ConsumerWidget {
  const MiFiadoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuenta = ref.watch(miCuentaFiadoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).miCuentaTitulo)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(miCuentaFiadoProvider),
        child: AsyncVista(
          valor: cuenta,
          alReintentar: () => ref.invalidate(miCuentaFiadoProvider),
          constructor: (c) {
            if (c == null) {
              return EstadoVacio(
                icono: Icons.account_balance_wallet_outlined,
                titulo: L.of(context).sinFiadoTitulo,
                detalle: L.of(context).sinFiadoDetalle,
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ResumenFiado(cuenta: c),
                const SizedBox(height: 20),
                Text(L.of(context).movimientos,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (c.movimientos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(L.of(context).sinMovimientos,
                        textAlign: TextAlign.center),
                  ),
                for (final m in c.movimientos) FilaMovimiento(movimiento: m),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ResumenFiado extends StatelessWidget {
  const ResumenFiado({super.key, required this.cuenta});

  final CuentaFiado cuenta;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = L.of(context);
    final usado = cuenta.limite == 0 ? 0.0 : (cuenta.saldo / cuenta.limite).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.fiadoDebes, style: t.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              Formato.soles(cuenta.saldo),
              style: t.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cuenta.saldo > 0 ? t.colorScheme.error : t.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usado.toDouble(),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.fiadoCupoDisponible(Formato.soles(cuenta.disponible),
                  Formato.soles(cuenta.limite)),
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class FilaMovimiento extends StatelessWidget {
  const FilaMovimiento({super.key, required this.movimiento});

  final MovimientoFiado movimiento;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = L.of(context);
    final esCargo = movimiento.tipo == TipoMovimiento.cargo;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: esCargo
            ? t.colorScheme.errorContainer
            : t.colorScheme.primaryContainer,
        child: Icon(
          esCargo ? Icons.arrow_upward : Icons.arrow_downward,
          size: 18,
          color: esCargo
              ? t.colorScheme.onErrorContainer
              : t.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(movimiento.descripcion.isEmpty
          ? (esCargo ? l.fiadoConsumo : l.fiadoAbono)
          : movimiento.descripcion),
      subtitle: Text(Formato.fechaHora(l, movimiento.fecha)),
      trailing: Text(
        '${esCargo ? '+' : '-'}${Formato.soles(movimiento.monto)}',
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: esCargo ? t.colorScheme.error : t.colorScheme.primary,
        ),
      ),
    );
  }
}
