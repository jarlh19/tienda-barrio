import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/etiquetas.dart';
import '../comun/widgets.dart';
import 'movimiento_hoja.dart';

/// Cuánto entró, cuánto salió y con qué se queda el tendero. Todo sale del
/// kardex: las ventas lo alimentan solas, la producción y las compras las
/// registra el tendero desde aquí.
class CajaPantalla extends ConsumerWidget {
  const CajaPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenCajaProvider);
    final movimientos = ref.watch(movimientosProvider);
    final deInsumos = ref.watch(movimientosInsumoProvider);
    final periodo = ref.watch(periodoCajaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).navCaja)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-caja',
        onPressed: () => abrirHojaMovimiento(context, ref),
        icon: const Icon(Icons.add),
        label: Text(L.of(context).registrar),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(movimientosProvider);
          ref.invalidate(movimientosInsumoProvider);
          ref.invalidate(resumenCajaProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in Periodo.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p.texto(L.of(context))),
                        selected: periodo == p,
                        onSelected: (_) =>
                            ref.read(periodoCajaProvider.notifier).state = p,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            resumen.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => EstadoVacio(
                icono: Icons.cloud_off_outlined,
                titulo: L.of(context).cajaNoCalculada,
                detalle: L.of(context).errorDetalle,
              ),
              data: (r) => _Resumen(resumen: r),
            ),
            const SizedBox(height: 24),
            Text(L.of(context).movimientos,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            AsyncVista(
              valor: movimientos,
              alReintentar: () => ref.invalidate(movimientosProvider),
              constructor: (lista) {
                final insumos = deInsumos.valueOrNull ?? const [];
                if (lista.isEmpty && insumos.isEmpty) {
                  return EstadoVacio(
                    icono: Icons.receipt_long_outlined,
                    titulo: L.of(context).sinMovimientosPeriodo,
                    detalle: L.of(context).sinMovimientosPeriodoDetalle,
                  );
                }
                // Los dos kardex se muestran juntos y en orden: el tendero ve
                // una sola historia del día, no dos listas separadas.
                final filas = <(DateTime, Widget)>[
                  for (final m in lista) (m.fecha, _FilaMovimiento(movimiento: m)),
                  for (final m in insumos)
                    (m.fecha, _FilaInsumo(movimiento: m)),
                ]..sort((a, b) => b.$1.compareTo(a.$1));

                return Column(children: [for (final f in filas) f.$2]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.resumen});

  final ResumenCaja resumen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resumen.enGanancia
                      ? L.of(context).cajaTeQueda
                      : L.of(context).cajaVasPerdiendo,
                  style: t.textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  Formato.soles(resumen.utilidad.abs()),
                  style: t.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: resumen.enGanancia
                        ? t.colorScheme.primary
                        : t.colorScheme.error,
                  ),
                ),
                if (resumen.ingresos > 0)
                  Text(
                    L.of(context).cajaMargen(
                        resumen.margen.toStringAsFixed(0),
                        resumen.unidadesVendidas),
                    style: t.textTheme.bodySmall
                        ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  ),
                if (resumen.perdidas > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      L.of(context)
                          .cajaMerma(Formato.soles(resumen.perdidas)),
                      style: t.textTheme.bodySmall
                          ?.copyWith(color: t.colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Tarjeta(
                titulo: L.of(context).cajaEntro,
                monto: resumen.ingresos,
                icono: Icons.arrow_downward,
                color: t.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Tarjeta(
                titulo: L.of(context).cajaSalio,
                monto: resumen.egresos,
                icono: Icons.arrow_upward,
                color: t.colorScheme.error,
              ),
            ),
          ],
        ),
        if (resumen.porProducto.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(L.of(context).cajaQueSeVendio, style: t.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  for (final linea in resumen.porProducto)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${linea.unidades} × ${linea.productoNombre}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Formato.soles(linea.ingreso),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Un movimiento del almacén de insumos, en la misma lista que los productos.
class _FilaInsumo extends StatelessWidget {
  const _FilaInsumo({required this.movimiento});

  final MovimientoInsumo movimiento;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final (icono, color) = switch (movimiento.tipo) {
      TipoMovimientoInsumo.compra => (Icons.local_shipping_outlined, t.colorScheme.error),
      TipoMovimientoInsumo.consumo => (Icons.grain, t.colorScheme.outline),
      TipoMovimientoInsumo.merma => (Icons.delete_outline, t.colorScheme.error),
      TipoMovimientoInsumo.ajuste => (Icons.tune, t.colorScheme.outline),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icono, size: 18, color: color),
      ),
      title: Text(
        '${movimiento.tipo.texto(L.of(context))} · ${movimiento.insumoNombre}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${movimiento.deltaStock > 0 ? '+' : ''}'
        '${Formato.cantidad(movimiento.deltaStock)}'
        '${movimiento.presentaciones > 0 ? L.of(context).movPresentaciones(Formato.cantidad(movimiento.presentaciones)) : ''}'
        ' · ${Formato.hace(L.of(context), movimiento.fecha)}',
      ),
      trailing: movimiento.egreso <= 0
          ? null
          : Text(
              '−${Formato.soles(movimiento.egreso)}',
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: t.colorScheme.error,
              ),
            ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.titulo,
    required this.monto,
    required this.icono,
    required this.color,
  });

  final String titulo;
  final double monto;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 16, color: color),
                const SizedBox(width: 4),
                Text(titulo, style: t.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              Formato.soles(monto),
              style: t.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaMovimiento extends StatelessWidget {
  const _FilaMovimiento({required this.movimiento});

  final MovimientoInventario movimiento;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final entra = movimiento.ingreso > 0;
    final sale = movimiento.egreso > 0;

    final (icono, color) = switch (movimiento.tipo) {
      TipoMovimientoInventario.produccion => (Icons.bakery_dining, t.colorScheme.tertiary),
      TipoMovimientoInventario.compra => (Icons.local_shipping_outlined, t.colorScheme.tertiary),
      TipoMovimientoInventario.venta => (Icons.point_of_sale, t.colorScheme.primary),
      TipoMovimientoInventario.merma => (Icons.delete_outline, t.colorScheme.error),
      TipoMovimientoInventario.ajuste => (Icons.tune, t.colorScheme.outline),
      TipoMovimientoInventario.devolucion => (Icons.undo, t.colorScheme.error),
    };

    final signo = entra ? '+' : (sale ? '−' : '');
    final monto = movimiento.monto == 0
        ? ''
        : '$signo${Formato.soles(movimiento.monto)}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icono, size: 18, color: color),
      ),
      title: Text(
        '${movimiento.tipo.texto(L.of(context))} · ${movimiento.productoNombre}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${movimiento.deltaStock > 0 ? '+' : ''}'
        '${L.of(context).movUnidades('${movimiento.deltaStock}')}'
        '${movimiento.lotes > 0 ? L.of(context).movLotes(Formato.cantidad(movimiento.lotes)) : ''}'
        ' · ${Formato.hace(L.of(context), movimiento.fecha)}',
      ),
      trailing: monto.isEmpty
          ? null
          : Text(
              monto,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: entra ? t.colorScheme.primary : t.colorScheme.error,
              ),
            ),
    );
  }
}

