import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';

void main() {
  final repo = MemCatalogoRepo(AlmacenMemoria.instancia);

  test('encuentra el producto por el código del envase', () async {
    final p = await repo.porCodigoBarras('7750243011408');

    expect(p, isNotNull);
    expect(p!.nombreCompleto, 'Costeño Arroz extra 1 kg');
  });

  test('un código desconocido no devuelve nada', () async {
    expect(await repo.porCodigoBarras('0000000000000'), isNull);
  });

  test('un código vacío no engancha con lo que se vende suelto', () async {
    // El pan no tiene etiqueta: buscar '' no debe devolverlo.
    expect(await repo.porCodigoBarras(''), isNull);
    expect(await repo.porCodigoBarras('   '), isNull);
  });

  test('el código sobrevive al alta del producto', () async {
    final guardado = await repo.guardarProducto(const Producto(
      id: '',
      nombre: 'Atún Florida',
      precio: 5.50,
      stock: 6,
      codigoBarras: '7751234500019',
    ));

    expect(guardado.codigoBarras, '7751234500019');
    expect((await repo.porCodigoBarras('7751234500019'))?.id, guardado.id);
  });

  test('el JSON manda NULL cuando no hay etiqueta', () {
    const suelto = Producto(id: 'x', nombre: 'Pan', precio: 0.4, stock: 10);

    expect(suelto.aJson()['codigo_barras'], isNull);
    expect(
      suelto.copiar(codigoBarras: '7750000000001').aJson()['codigo_barras'],
      '7750000000001',
    );
  });
}
