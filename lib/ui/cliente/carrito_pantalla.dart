import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../estado/carrito.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class CarritoPantalla extends ConsumerWidget {
  const CarritoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(carritoProvider);
    final carrito = ref.read(carritoProvider.notifier);
    final total = ref.watch(totalCarritoProvider);
    final t = Theme.of(context);
    final l = L.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.carritoTitulo),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                carrito.limpiar();
                mostrarAviso(context, l.carritoVaciado);
              },
              child: Text(l.vaciar),
            ),
        ],
      ),
      body: items.isEmpty
          ? EstadoVacio(
              icono: Icons.shopping_cart_outlined,
              titulo: l.carritoVacioTitulo,
              detalle: l.carritoVacioDetalle,
              accion: FilledButton.tonal(
                onPressed: () => context.pop(),
                child: Text(l.verCatalogo),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = items[i];
                return Dismissible(
                  key: ValueKey(item.productoId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: t.colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete_outline,
                        color: t.colorScheme.onErrorContainer),
                  ),
                  onDismissed: (_) => carrito.quitar(item.productoId),
                  child: ListTile(
                    title: Text(item.nombre),
                    subtitle: Text(
                      '${Formato.soles(item.precioUnitario)} x ${item.cantidad} ${item.unidad}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () =>
                              carrito.ajustar(item.productoId, -1),
                        ),
                        Text('${item.cantidad}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => carrito.ajustar(item.productoId, 1),
                        ),
                        SizedBox(
                          width: 72,
                          child: Text(
                            Formato.soles(item.subtotal),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.total, style: t.textTheme.titleMedium),
                        Text(
                          Formato.soles(total),
                          style: t.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push('/checkout'),
                      child: Text(l.continuarPago),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
