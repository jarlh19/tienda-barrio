import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';
import 'package:tienda_barrio/datos/repos/repos.dart';
import 'package:tienda_barrio/main.dart';
import 'package:tienda_barrio/ui/comun/perfil_pantalla.dart';

import 'ayuda.dart';

/// Borrar la cuenta desde Perfil, con las reglas de `borrar_mi_cuenta` en
/// schema.sql: si debe fiado o tiene un pedido en curso no se borra nada; si
/// no, lo personal se va y las ventas quedan para la tienda, sin nombre.
void main() {
  final a = AlmacenMemoria.instancia;

  Future<Aviso?> avisoAlBorrar(MemAuthRepo auth) async {
    try {
      await auth.borrarCuenta();
      return null;
    } on ErrorApp catch (e) {
      return e.aviso;
    }
  }

  test('el tendero no borra su cuenta desde la app', () async {
    final auth = MemAuthRepo(a);
    await auth.iniciarSesion(email: 'tendero@demo.pe', clave: 'x');
    expect(await avisoAlBorrar(auth), Aviso.tenderoNoSeBorra);
    expect(a.perfiles.where((p) => p.rol == Rol.tendero), isNotEmpty);
  });

  test('con pedido en curso o fiado pendiente no se borra; saldado, sí', () async {
    final auth = MemAuthRepo(a);
    final carla = await auth.registrar(
        nombre: 'Carla', email: 'carla@x.pe', clave: 'x', direccion: 'Jr. Dos 456');
    a.pedidos.add(Pedido(
      id: 'p-carla',
      clienteId: carla.id,
      clienteNombre: 'Carla',
      items: const [],
      creadoEn: DateTime(2026, 11, 6),
      metodoPago: MetodoPago.fiado,
      direccion: 'Jr. Dos 456',
      notas: 'tocar el timbre',
    ));
    a.movimientos.add(MovimientoFiado(
      id: 'f-carla',
      clienteId: carla.id,
      tipo: TipoMovimiento.cargo,
      monto: 12.5,
      fecha: DateTime(2026, 11, 6),
      descripcion: 'Pedido P-CARLA',
    ));

    expect(await avisoAlBorrar(auth), Aviso.pedidosEnCurso);

    final i = a.pedidos.indexWhere((p) => p.id == 'p-carla');
    final p = a.pedidos[i];
    a.pedidos[i] = Pedido(
      id: p.id,
      clienteId: p.clienteId,
      clienteNombre: p.clienteNombre,
      items: p.items,
      creadoEn: p.creadoEn,
      estado: EstadoPedido.entregado,
      metodoPago: p.metodoPago,
      direccion: p.direccion,
      notas: p.notas,
    );
    try {
      await auth.borrarCuenta();
      fail('debía frenar por la deuda');
    } on ErrorApp catch (e) {
      expect(e.aviso, Aviso.deudaAlBorrar);
      expect(e.datos['deuda'], 12.5);
    }

    a.movimientos.add(MovimientoFiado(
      id: 'f-carla-abono',
      clienteId: carla.id,
      tipo: TipoMovimiento.abono,
      monto: 12.5,
      fecha: DateTime(2026, 11, 7),
      descripcion: 'Pago en tienda',
    ));
    await auth.borrarCuenta();

    expect(auth.perfilActual, isNull);
    expect(a.perfiles.where((x) => x.id == carla.id), isEmpty);
    final venta = a.pedidos.firstWhere((x) => x.id == 'p-carla');
    expect(venta.clienteId, '');
    expect(venta.clienteNombre, 'Cuenta borrada');
    expect(venta.direccion, '');
    expect(venta.notas, '');
    expect(a.movimientos.where((m) => m.id.startsWith('f-carla')).map((m) => m.clienteId), ['', '']);
    expect(a.movimientos.where((m) => m.clienteId == carla.id), isEmpty);
  });

  testWidgets('desde Perfil: confirmar borra la cuenta y vuelve a la entrada', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(overrides: en('es'), child: const TiendaApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cliente'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Borrar mi cuenta'), 300,
        scrollable: find
            .descendant(of: find.byType(PerfilPantalla), matching: find.byType(Scrollable))
            .first);
    await tester.tap(find.text('Borrar mi cuenta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No se puede deshacer'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(a.perfiles.where((p) => p.id == 'u-cliente'), isNotEmpty);

    await tester.tap(find.text('Borrar mi cuenta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(a.perfiles.where((p) => p.id == 'u-cliente'), isEmpty);
    expect(find.text('Entrar'), findsOneWidget);

    // En la demo, volver a entrar como cliente no termina en el panel del
    // tendero: el vecino de ejemplo vuelve a nacer, limpio.
    await tester.tap(find.text('Cliente'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('¿Qué necesitas hoy?'), findsOneWidget);
  });
}
