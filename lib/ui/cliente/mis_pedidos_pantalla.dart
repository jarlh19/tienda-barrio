import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class MisPedidosPantalla extends ConsumerWidget {
  const MisPedidosPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidos = ref.watch(misPedidosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).misPedidosTitulo)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(misPedidosProvider),
        child: AsyncVista(
          valor: pedidos,
          alReintentar: () => ref.invalidate(misPedidosProvider),
          constructor: (lista) {
            if (lista.isEmpty) {
              return EstadoVacio(
                icono: Icons.receipt_long_outlined,
                titulo: L.of(context).sinPedidosTitulo,
                detalle: L.of(context).sinPedidosDetalle,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lista.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TarjetaPedido(pedido: lista[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Tarjeta de pedido reutilizada por el cliente y por el panel del tendero.
class TarjetaPedido extends StatelessWidget {
  const TarjetaPedido({
    super.key,
    required this.pedido,
    this.mostrarCliente = false,
    this.acciones,
  });

  final Pedido pedido;
  final bool mostrarCliente;
  final Widget? acciones;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = L.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mostrarCliente
                        ? pedido.clienteNombre
                        : l.pedidoNumero(pedido.codigo),
                    style: t.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                ChipEstado(estado: pedido.estado),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              mostrarCliente
                  ? '${pedido.codigo} · ${Formato.hace(l, pedido.creadoEn)}'
                  : Formato.fechaHora(l, pedido.creadoEn),
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            for (final item in pedido.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.cantidad} × ${item.nombre}')),
                    Text(Formato.soles(item.subtotal),
                        style: t.textTheme.bodyMedium),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: ChipPago(
                    estado: pedido.estadoPago,
                    metodo: pedido.metodoPago,
                  ),
                ),
                Text(
                  Formato.soles(pedido.total),
                  style: t.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (pedido.referenciaPago.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.operacionNumero(pedido.referenciaPago),
                  style: t.textTheme.bodySmall
                      ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                ),
              ),
            if (pedido.direccion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_outlined,
                        size: 15, color: t.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pedido.direccion,
                        style: t.textTheme.bodySmall
                            ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            if (pedido.notas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '“${pedido.notas}”',
                  style: t.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (acciones != null) ...[
              const SizedBox(height: 12),
              acciones!,
            ],
          ],
        ),
      ),
    );
  }
}
