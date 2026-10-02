import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';

void main() {
  group('ficha del producto', () {
    test('el nombre completo junta marca, producto y contenido', () {
      const p = Producto(
        id: 'x',
        nombre: 'Leche evaporada',
        precio: 4.30,
        stock: 5,
        marca: 'Gloria',
        contenido: 395,
        medida: 'g',
      );

      expect(p.etiquetaContenido, '395 g');
      expect(p.nombreCompleto, 'Gloria Leche evaporada 395 g');
    });

    test('lo que se vende suelto no arrastra marca ni medida', () {
      const pan = Producto(id: 'x', nombre: 'Pan francés', precio: 0.4, stock: 80);

      expect(pan.etiquetaContenido, '');
      expect(pan.nombreCompleto, 'Pan francés');
    });

    test('los decimales solo aparecen cuando hacen falta', () {
      const gaseosa = Producto(
        id: 'x',
        nombre: 'Gaseosa',
        precio: 7.5,
        stock: 3,
        contenido: 1.5,
        medida: 'L',
      );
      const arroz = Producto(
        id: 'y',
        nombre: 'Arroz',
        precio: 4.5,
        stock: 3,
        contenido: 1,
        medida: 'kg',
      );

      expect(gaseosa.etiquetaContenido, '1.5 L');
      expect(arroz.etiquetaContenido, '1 kg');
    });

    test('el alta conserva marca, contenido y medida', () async {
      final repo = MemCatalogoRepo(AlmacenMemoria.instancia);

      final guardado = await repo.guardarProducto(const Producto(
        id: '',
        nombre: 'Atún',
        precio: 5.50,
        stock: 6,
        marca: 'Florida',
        contenido: 170,
        medida: 'g',
      ));

      expect(guardado.marca, 'Florida');
      expect(guardado.nombreCompleto, 'Florida Atún 170 g');
    });

    test('el cliente encuentra el producto buscando por marca', () async {
      final repo = MemCatalogoRepo(AlmacenMemoria.instancia);

      final porMarca = await repo.productos(busqueda: 'gloria');

      expect(porMarca, isNotEmpty);
      expect(porMarca.first.marca, 'Gloria');
    });
  });
}
