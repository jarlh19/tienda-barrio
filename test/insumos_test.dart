import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';
import 'package:tienda_barrio/datos/repos/repos.dart';

/// El caso que planteó el tendero: entran dos sacos de harina, se hornea y
/// salen 200 panes. Cuánto costó cada pan y si rindió lo que debía.
void main() {
  late AlmacenMemoria almacen;
  late MemInsumosRepo insumosRepo;
  late MemCatalogoRepo catalogo;
  late MemInventarioRepo inventario;

  late String harinaId;
  late Producto pan;

  setUp(() async {
    almacen = AlmacenMemoria.instancia;
    insumosRepo = MemInsumosRepo(almacen);
    catalogo = MemCatalogoRepo(almacen);
    inventario = MemInventarioRepo(almacen);

    // Insumo y producto propios en cada prueba: el almacén demo es compartido.
    final harina = await insumosRepo.guardar(const Insumo(
      id: '',
      nombre: 'Harina',
      unidad: 'kg',
      nombrePresentacion: 'saco',
      unidadesPorPresentacion: 50,
    ));
    harinaId = harina.id;

    pan = await catalogo.guardarProducto(const Producto(
      id: '',
      nombre: 'Pan francés',
      precio: 0.25,
      stock: 0,
      unidadesPorLote: 100,
      nombreLote: 'horneada',
      unidadesPorPaquete: 4,
    ));
  });

  Future<Insumo> leerHarina() async {
    final lista = await insumosRepo.insumos();
    return lista.firstWhere((i) => i.id == harinaId);
  }

  Future<void> comprarSacos(double sacos, double montoTotal) =>
      insumosRepo.registrarMovimiento(MovimientoInsumo(
        id: '',
        insumoId: harinaId,
        insumoNombre: 'Harina',
        tipo: TipoMovimientoInsumo.compra,
        cantidad: sacos * 50,
        monto: montoTotal,
        presentaciones: sacos,
        fecha: DateTime.now(),
      ));

  group('compra por saco, consumo por kilo', () {
    test('dos sacos entran como 100 kg', () async {
      await comprarSacos(2, 360);

      final harina = await leerHarina();
      expect(harina.stock, 100);
      expect(harina.costoUnitario, closeTo(3.60, 0.001));
      expect(harina.presentacionesEnStock, 2);
    });

    test('el costo del kilo es promedio ponderado, no el último precio',
        () async {
      await comprarSacos(1, 180); // 50 kg a 3.60
      await comprarSacos(1, 220); // 50 kg a 4.40

      final harina = await leerHarina();
      expect(harina.stock, 100);
      // (180 + 220) / 100 = 4.00, no 4.40.
      expect(harina.costoUnitario, closeTo(4.00, 0.001));
      expect(harina.costoPresentacion, closeTo(200, 0.01));
    });
  });

  group('producción: dos sacos dan 200 panes', () {
    setUp(() async {
      await comprarSacos(2, 360);
      await insumosRepo.guardarReceta(pan.id, [
        // Una horneada de 100 panes lleva 50 kg de harina: un saco.
        LineaReceta(
          insumoId: harinaId,
          insumoNombre: 'Harina',
          unidad: 'kg',
          cantidadPorLote: 50,
        ),
      ]);
    });

    test('gastar los dos sacos descuenta la harina y mete los panes', () async {
      final r = await insumosRepo.registrarProduccion(
        producto: pan,
        lotes: 2,
        unidadesProducidas: 200,
        consumos: [
          ConsumoInsumo(
            insumoId: harinaId,
            insumoNombre: 'Harina',
            unidad: 'kg',
            cantidad: 100,
          ),
        ],
      );

      expect((await leerHarina()).stock, 0);

      final productos = await catalogo.productos(soloActivos: false);
      final panActual = productos.firstWhere((p) => p.id == pan.id);
      expect(panActual.stock, 200);

      // 360 soles de harina entre 200 panes: 1.80 cada uno.
      expect(r.costoTotal, closeTo(360, 0.01));
      expect(r.costoUnitario, closeTo(1.80, 0.001));
      // Y ese costo queda en el producto, para que el margen sea real.
      expect(panActual.costo, closeTo(1.80, 0.001));
    });

    test('avisa cuánto rindió de menos', () async {
      final r = await insumosRepo.registrarProduccion(
        producto: pan,
        lotes: 2,
        unidadesProducidas: 180,
        consumos: [
          ConsumoInsumo(
            insumoId: harinaId,
            insumoNombre: 'Harina',
            unidad: 'kg',
            cantidad: 100,
          ),
        ],
      );

      expect(r.unidadesEsperadas, 200);
      expect(r.diferencia, -20);
      expect(r.rindioMenos, isTrue);
      expect(r.rendimiento, closeTo(90, 0.1));
      // Menos panes con la misma harina: cada uno sale más caro.
      expect(r.costoUnitario, closeTo(2.00, 0.001));
    });

    test('no deja producir si no alcanza la harina', () async {
      expect(
        () => insumosRepo.registrarProduccion(
          producto: pan,
          lotes: 4,
          unidadesProducidas: 400,
          consumos: [
            ConsumoInsumo(
              insumoId: harinaId,
              insumoNombre: 'Harina',
              unidad: 'kg',
              cantidad: 200,
            ),
          ],
        ),
        throwsA(isA<ErrorApp>()),
      );

      // Y no dejó el almacén a medio descontar.
      expect((await leerHarina()).stock, 100);
    });

    test('la receta propone el consumo con el costo de hoy', () async {
      final receta = await insumosRepo.receta(pan.id);

      expect(receta, hasLength(1));
      expect(receta.first.cantidadPorLote, 50);
      expect(receta.first.costoUnitario, closeTo(3.60, 0.001));
      expect(receta.first.costoPorLotes(2), closeTo(360, 0.01));
    });
  });

  group('la caja no cuenta dos veces', () {
    test('la harina sale al comprarla, no al hornear', () async {
      await comprarSacos(2, 360);
      await insumosRepo.guardarReceta(pan.id, [
        LineaReceta(
          insumoId: harinaId,
          insumoNombre: 'Harina',
          unidad: 'kg',
          cantidadPorLote: 50,
        ),
      ]);
      await insumosRepo.registrarProduccion(
        producto: pan,
        lotes: 2,
        unidadesProducidas: 200,
        consumos: [
          ConsumoInsumo(
            insumoId: harinaId,
            insumoNombre: 'Harina',
            unidad: 'kg',
            cantidad: 100,
          ),
        ],
      );
      // Se vendieron 100 panes a 0.25.
      await inventario.registrar(MovimientoInventario(
        id: '',
        productoId: pan.id,
        productoNombre: 'Pan francés',
        tipo: TipoMovimientoInventario.venta,
        unidades: 100,
        monto: 25,
        fecha: DateTime.now(),
      ));

      final desde = DateTime.now().subtract(const Duration(hours: 1));
      final hasta = DateTime.now().add(const Duration(minutes: 1));
      final resumen = ResumenCaja.desde(
        await inventario.movimientos(productoId: pan.id),
        movimientosInsumo: await insumosRepo.movimientos(insumoId: harinaId),
        desde: desde,
        hasta: hasta,
      );

      expect(resumen.ingresos, closeTo(25, 0.01));
      // Solo los 360 de la compra: la producción no vuelve a restar.
      expect(resumen.egresos, closeTo(360, 0.01));
      expect(resumen.utilidad, closeTo(-335, 0.01));
    });
  });
}
