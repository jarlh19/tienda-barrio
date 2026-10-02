import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/estado/carrito.dart';

const _arroz = Producto(
  id: 'p1',
  nombre: 'Arroz 1 kg',
  precio: 4.50,
  stock: 3,
  unidad: 'bolsa',
);

void main() {
  late ProviderContainer contenedor;
  late CarritoNotifier carrito;

  setUp(() {
    contenedor = ProviderContainer();
    carrito = contenedor.read(carritoProvider.notifier);
  });

  tearDown(() => contenedor.dispose());

  test('suma cantidades del mismo producto en una sola línea', () {
    carrito.agregar(_arroz);
    carrito.agregar(_arroz);

    expect(contenedor.read(carritoProvider).length, 1);
    expect(carrito.cantidadDe('p1'), 2);
    expect(contenedor.read(totalCarritoProvider), 9.0);
  });

  test('nunca deja pedir más unidades de las que hay en stock', () {
    carrito.agregar(_arroz, cantidad: 10);

    expect(carrito.cantidadDe('p1'), _arroz.stock);
  });

  test('bajar a cero quita el producto del carrito', () {
    carrito.agregar(_arroz);
    carrito.ajustar('p1', -1);

    expect(contenedor.read(carritoProvider), isEmpty);
  });
}
