import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../cliente/mis_pedidos_pantalla.dart';
import '../comun/widgets.dart';

class PedidosAdminPantalla extends ConsumerStatefulWidget {
  const PedidosAdminPantalla({super.key});

  @override
  ConsumerState<PedidosAdminPantalla> createState() =>
      _PedidosAdminPantallaState();
}

class _PedidosAdminPantallaState extends ConsumerState<PedidosAdminPantalla> {
  bool _soloAbiertos = true;

  Future<void> _accion(Future<void> Function() f) async {
    try {
      await f();
      if (mounted) refrescarTodo(ref);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = ref.watch(pedidosTiendaProvider);
    final repo = ref.read(pedidosRepoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Solo activos'),
              selected: _soloAbiertos,
              onSelected: (v) => setState(() => _soloAbiertos = v),
            ),
          ),
        ],
      ),
      body: AsyncVista(
        valor: pedidos,
        alReintentar: () => ref.invalidate(pedidosTiendaProvider),
        constructor: (todos) {
          final lista =
              _soloAbiertos ? todos.where((p) => p.estado.abierto).toList() : todos;
          if (lista.isEmpty) {
            return EstadoVacio(
              icono: Icons.inbox_outlined,
              titulo: _soloAbiertos ? 'No hay pedidos activos' : 'Aún no hay pedidos',
              detalle: 'Los pedidos nuevos aparecen aquí al instante.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final p = lista[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TarjetaPedido(
                  pedido: p,
                  mostrarCliente: true,
                  acciones: _Acciones(
                    pedido: p,
                    alAvanzar: () => _accion(
                      () => repo.cambiarEstado(p.id, p.estado.siguiente!),
                    ),
                    alCancelar: () => _accion(
                      () => repo.cambiarEstado(p.id, EstadoPedido.cancelado),
                    ),
                    alConfirmarPago: () => _accion(
                      () => repo.cambiarEstadoPago(p.id, EstadoPago.pagado),
                    ),
                    alRechazarPago: () => _accion(
                      () => repo.cambiarEstadoPago(p.id, EstadoPago.fallido),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Acciones extends StatelessWidget {
  const _Acciones({
    required this.pedido,
    required this.alAvanzar,
    required this.alCancelar,
    required this.alConfirmarPago,
    required this.alRechazarPago,
  });

  final Pedido pedido;
  final VoidCallback alAvanzar;
  final VoidCallback alCancelar;
  final VoidCallback alConfirmarPago;
  final VoidCallback alRechazarPago;

  @override
  Widget build(BuildContext context) {
    final siguiente = pedido.estado.siguiente;
    final porVerificar = pedido.estadoPago == EstadoPago.verificando;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (porVerificar) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifica ${Formato.soles(pedido.total)} por '
                  '${pedido.metodoPago.etiqueta}'
                  '${pedido.referenciaPago.isEmpty ? '' : ' · op. ${pedido.referenciaPago}'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: alConfirmarPago,
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(36)),
                        child: const Text('Pago recibido'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: alRechazarPago,
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(36)),
                        child: const Text('No llegó'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            if (siguiente != null)
              Expanded(
                child: FilledButton(
                  onPressed: alAvanzar,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(40)),
                  child: Text('Marcar ${siguiente.etiqueta.toLowerCase()}'),
                ),
              ),
            if (siguiente != null && pedido.estado.abierto)
              const SizedBox(width: 8),
            if (pedido.estado.abierto)
              OutlinedButton(
                onPressed: alCancelar,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40)),
                child: const Text('Cancelar'),
              ),
          ],
        ),
      ],
    );
  }
}
