import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/estado/providers.dart';
import 'package:tienda_barrio/ui/tendero/pedidos_admin_pantalla.dart';

import 'ayuda.dart';

/// Un Yape o un Plin que nadie verifica deja el stock apartado para siempre:
/// el panel del tendero tiene que notarlo, sin cancelar nada por su cuenta.
void main() {
  final ahora = DateTime(2026, 11, 5, 18);

  Pedido pedido(
    String id, {
    required Duration hace,
    EstadoPago pago = EstadoPago.verificando,
    EstadoPedido estado = EstadoPedido.pendiente,
  }) =>
      Pedido(
        id: id,
        clienteId: 'u-cliente',
        clienteNombre: 'Ana',
        items: const [],
        creadoEn: ahora.subtract(hace),
        estado: estado,
        metodoPago: MetodoPago.yape,
        estadoPago: pago,
      );

  test('un pago por verificar hace más de 2 horas está atrasado', () {
    expect(pedido('a', hace: const Duration(hours: 3)).pagoAtrasado(ahora),
        isTrue);
    expect(
        pedido('b', hace: const Duration(minutes: 90)).pagoAtrasado(ahora),
        isFalse);
  });

  test('un pago ya resuelto o un pedido cerrado no están atrasados', () {
    expect(
        pedido('c', hace: const Duration(hours: 5), pago: EstadoPago.pagado)
            .pagoAtrasado(ahora),
        isFalse);
    expect(
        pedido('d',
                hace: const Duration(hours: 5),
                estado: EstadoPedido.cancelado)
            .pagoAtrasado(ahora),
        isFalse);
  });

  test('en el panel los pagos atrasados van primero, el resto sigue igual',
      () {
    final lista = [
      pedido('nuevo', hace: const Duration(minutes: 5), pago: EstadoPago.pendiente),
      pedido('atrasado', hace: const Duration(hours: 4)),
      pedido('reciente', hace: const Duration(minutes: 30)),
      pedido('mas-atrasado', hace: const Duration(hours: 6)),
    ];
    expect(ordenarParaTendero(lista, ahora).map((p) => p.id),
        ['mas-atrasado', 'atrasado', 'nuevo', 'reciente']);
  });

  testWidgets('el panel resalta el pago atrasado y dice qué hacer',
      (tester) async {
    final real = DateTime.now();
    Pedido conPago(String id, Duration hace) => Pedido(
          id: id,
          clienteId: 'u-cliente',
          clienteNombre: id,
          items: const [],
          creadoEn: real.subtract(hace),
          metodoPago: MetodoPago.yape,
          estadoPago: EstadoPago.verificando,
        );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pedidosTiendaProvider.overrideWith((ref) => Stream.value([
              conPago('Reciente', const Duration(minutes: 20)),
              conPago('Atrasado', const Duration(hours: 3)),
            ])),
      ],
      child: pantalla(const PedidosAdminPantalla()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Esperando el pago hace 3 h'), findsOneWidget);
    expect(find.textContaining('cancela el pedido para devolver el stock'),
        findsOneWidget);
    // El atrasado sube arriba aunque llegó antes.
    expect(tester.getTopLeft(find.text('Atrasado')).dy,
        lessThan(tester.getTopLeft(find.text('Reciente')).dy));
  });
}
