import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';
import 'package:tienda_barrio/estado/carrito.dart';
import 'package:tienda_barrio/estado/checkout.dart';
import 'package:tienda_barrio/estado/providers.dart';

/// Abusos que la app tiene que aguantar. Cada prueba nace de un "cómo
/// atacaría esto": el pedido lo arma el celular del cliente, así que nada
/// de lo que manda puede darse por bueno.
void main() {
  late ProviderContainer contenedor;
  late AlmacenMemoria almacen;

  setUp(() async {
    contenedor = ProviderContainer();
    almacen = AlmacenMemoria.instancia;
    await contenedor.read(sesionProvider.notifier).iniciarSesion(
          'cliente@demo.com',
          'demo1234',
        );
  });

  tearDown(() => contenedor.dispose());

  Producto panDemo() =>
      almacen.productos.firstWhere((p) => p.id == 'p13');

  test('la deuda del fiado se anota una sola vez y la escribe el repo',
      () async {
    final cliente = contenedor.read(sesionProvider)!;
    final antes = almacen.movimientos
        .where((m) => m.clienteId == cliente.id)
        .length;

    contenedor.read(carritoProvider.notifier).agregar(panDemo(), cantidad: 4);
    final pedido = await contenedor.read(checkoutProvider).confirmar(
          metodo: MetodoPago.fiado,
          direccion: 'Jr. Las Flores 45',
        );

    final cargos = almacen.movimientos
        .where((m) => m.pedidoId == pedido.id && m.tipo == TipoMovimiento.cargo)
        .toList();

    // Uno solo: si el checkout lo escribiera además del repo, saldrían dos y
    // el cliente terminaría debiendo el doble.
    expect(cargos, hasLength(1));
    expect(cargos.single.monto, closeTo(pedido.total, 0.001));
    expect(
      almacen.movimientos.where((m) => m.clienteId == cliente.id).length,
      antes + 1,
    );
  });

  test('cancelar el pedido devuelve la deuda al cliente', () async {
    contenedor.read(carritoProvider.notifier).agregar(panDemo(), cantidad: 4);
    final pedido = await contenedor.read(checkoutProvider).confirmar(
          metodo: MetodoPago.fiado,
          direccion: 'Jr. Las Flores 45',
        );

    await contenedor
        .read(pedidosRepoProvider)
        .cambiarEstado(pedido.id, EstadoPedido.cancelado);

    final delPedido =
        almacen.movimientos.where((m) => m.pedidoId == pedido.id).toList();
    expect(delPedido, hasLength(2));
    expect(
      delPedido.where((m) => m.tipo == TipoMovimiento.abono).single.monto,
      closeTo(pedido.total, 0.001),
    );
  });

  test('el cupo de fiado se respeta aunque el carrito lo supere', () async {
    final cliente = contenedor.read(sesionProvider)!;
    almacen.limites[cliente.id] = 1;

    contenedor.read(carritoProvider.notifier).agregar(panDemo(), cantidad: 40);

    await expectLater(
      contenedor.read(checkoutProvider).confirmar(
            metodo: MetodoPago.fiado,
            direccion: 'Jr. Las Flores 45',
          ),
      throwsA(isA<Exception>()),
    );

    almacen.limites[cliente.id] = 150;
  });

  test('un pedido sin dirección no se guarda', () async {
    contenedor.read(carritoProvider.notifier).agregar(panDemo());

    await expectLater(
      contenedor.read(checkoutProvider).confirmar(
            metodo: MetodoPago.efectivo,
            direccion: '   ',
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('el carrito no deja pedir más de lo que hay en stock', () {
    final carrito = contenedor.read(carritoProvider.notifier);
    final pan = panDemo();

    carrito.agregar(pan, cantidad: pan.stock + 100);

    expect(carrito.cantidadDe(pan.id), pan.stock);
  });
}
