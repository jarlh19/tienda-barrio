import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';

/// El caso de la panadería, de punta a punta: horneo una plancha, la vendo
/// de a cuatro panes por un sol y quiero saber cuánto me quedó.
void main() {
  const panFrances = Producto(
    id: 'p13',
    nombre: 'Pan francés',
    precio: 0.25,
    stock: 0,
    costo: 0.12,
    unidadesPorLote: 30,
    nombreLote: 'plancha',
    unidadesPorPaquete: 4,
  );

  group('pan francés: producción y precio por paquete', () {
    test('una plancha da 30 panes', () {
      expect(panFrances.seProduce, isTrue);
      expect(panFrances.unidadesPorLote, 30);
      expect(panFrances.costoLote, closeTo(3.60, 0.001));
    });

    test('4 panes por un sol sale de un precio unitario de 0.25', () {
      expect(panFrances.seVendePorPaquete, isTrue);
      expect(panFrances.precioPaquete, closeTo(1.00, 0.001));
      expect(panFrances.margenUnitario, closeTo(0.13, 0.001));
    });

    test('el stock se cuenta en planchas cuando el tendero lo pide así', () {
      expect(panFrances.copiar(stock: 45).lotesEnStock, 1.5);
    });
  });

  group('kardex y caja', () {
    late MemInventarioRepo inventario;
    late MemCatalogoRepo catalogo;

    // Cada prueba parte del almacén compartido, así que se usa un producto
    // propio para no depender de lo que hayan hecho las otras.
    late String productoId;

    setUp(() async {
      final almacen = AlmacenMemoria.instancia;
      inventario = MemInventarioRepo(almacen);
      catalogo = MemCatalogoRepo(almacen);
      // id vacío = alta nueva: cada prueba estrena producto y no hereda los
      // movimientos de la anterior.
      final creado = await catalogo.guardarProducto(const Producto(
        id: '',
        nombre: 'Pan francés',
        precio: 0.25,
        stock: 0,
        costo: 0.12,
        unidadesPorLote: 30,
        nombreLote: 'plancha',
        unidadesPorPaquete: 4,
      ));
      productoId = creado.id;
    });

    Future<void> registrar(
      TipoMovimientoInventario tipo,
      int unidades,
      double monto, {
      double lotes = 0,
    }) =>
        inventario.registrar(MovimientoInventario(
          id: '',
          productoId: productoId,
          productoNombre: 'Pan francés',
          tipo: tipo,
          unidades: unidades,
          monto: monto,
          lotes: lotes,
          fecha: DateTime.now(),
        ));

    Future<Producto> leerProducto() async {
      final lista = await catalogo.productos(soloActivos: false);
      return lista.firstWhere((p) => p.id == productoId);
    }

    test('hornear 2 planchas mete 60 panes al inventario', () async {
      await registrar(TipoMovimientoInventario.produccion, 60, 7.20, lotes: 2);

      expect((await leerProducto()).stock, 60);
    });

    test('vender descuenta del stock y suma a la caja', () async {
      await registrar(TipoMovimientoInventario.produccion, 30, 3.60, lotes: 1);
      await registrar(TipoMovimientoInventario.venta, 8, 2.00);

      expect((await leerProducto()).stock, 22);

      final movs = await inventario.movimientos(productoId: productoId);
      final resumen = ResumenCaja.desde(
        movs,
        desde: DateTime.now().subtract(const Duration(hours: 1)),
        hasta: DateTime.now().add(const Duration(minutes: 1)),
      );

      expect(resumen.ingresos, closeTo(2.00, 0.001));
      expect(resumen.egresos, closeTo(3.60, 0.001));
      // Horneó 30 y solo vendió 8: todavía va perdiendo.
      expect(resumen.utilidad, closeTo(-1.60, 0.001));
      expect(resumen.enGanancia, isFalse);
      expect(resumen.unidadesVendidas, 8);
    });

    test('vendida la plancha entera, la ganancia es la esperada', () async {
      await registrar(TipoMovimientoInventario.produccion, 30, 3.60, lotes: 1);
      // 30 panes a 0.25 = 7.50, es decir 7 paquetes de 4 y 2 sueltos.
      await registrar(TipoMovimientoInventario.venta, 30, 7.50);

      final movs = await inventario.movimientos(productoId: productoId);
      final resumen = ResumenCaja.desde(
        movs,
        desde: DateTime.now().subtract(const Duration(hours: 1)),
        hasta: DateTime.now().add(const Duration(minutes: 1)),
      );

      expect(resumen.utilidad, closeTo(3.90, 0.001));
      expect(resumen.enGanancia, isTrue);
      expect(resumen.margen, closeTo(52, 1));
      expect((await leerProducto()).stock, 0);
    });

    test('la merma quema stock y se muestra aparte, no como egreso', () async {
      await registrar(TipoMovimientoInventario.produccion, 30, 3.60, lotes: 1);
      await registrar(TipoMovimientoInventario.merma, 5, 0.60);

      expect((await leerProducto()).stock, 25);

      final movs = await inventario.movimientos(productoId: productoId);
      final resumen = ResumenCaja.desde(
        movs,
        desde: DateTime.now().subtract(const Duration(hours: 1)),
        hasta: DateTime.now().add(const Duration(minutes: 1)),
      );
      // La plata salió cuando se compró/produjo; la merma no vuelve a restar
      // de la caja, pero sí se reporta como pérdida.
      expect(resumen.egresos, closeTo(3.60, 0.001));
      expect(resumen.perdidas, closeTo(0.60, 0.001));
      expect(resumen.ingresos, 0);
    });

    test('el ajuste corrige el conteo sin tocar la plata', () async {
      await registrar(TipoMovimientoInventario.produccion, 30, 3.60, lotes: 1);
      await registrar(TipoMovimientoInventario.ajuste, 2, 0);

      expect((await leerProducto()).stock, 32);

      final movs = await inventario.movimientos(productoId: productoId);
      final ajuste = movs.firstWhere(
          (m) => m.tipo == TipoMovimientoInventario.ajuste);
      expect(ajuste.ingreso, 0);
      expect(ajuste.egreso, 0);
    });

    test('el resumen deja fuera lo que pasó antes del periodo', () async {
      await registrar(TipoMovimientoInventario.venta, 4, 1.00);

      final movs = await inventario.movimientos(productoId: productoId);
      final manana = DateTime.now().add(const Duration(days: 1));
      final resumen = ResumenCaja.desde(movs, desde: manana, hasta: manana);

      expect(resumen.ingresos, 0);
      expect(resumen.unidadesVendidas, 0);
    });
  });
}
