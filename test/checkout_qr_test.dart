import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/repos.dart';
import 'package:tienda_barrio/estado/providers.dart';
import 'package:tienda_barrio/ui/cliente/checkout_pantalla.dart';

import 'ayuda.dart';
import 'package:tienda_barrio/ui/tendero/tienda_pantalla.dart' show VistaQr;

/// PNG mínimo de 1x1: alcanza para comprobar que el QR se pinta.
const _qrDemo =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGP4DwABAQEAWk1v8QAAAABJRU5ErkJggg==';

class _TiendaFalsa implements TiendaRepo {
  _TiendaFalsa(this._tienda);

  Tienda _tienda;

  @override
  Future<Tienda> obtener() async => _tienda;

  @override
  Future<Tienda> guardar(Tienda tienda) async => _tienda = tienda;

  @override
  Future<String> subirQr({
    required MetodoPago metodo,
    required Uint8List bytes,
    required String extension,
  }) async =>
      _qrDemo;
}

Future<void> _abrirCheckout(WidgetTester tester, Tienda tienda) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tiendaRepoProvider.overrideWithValue(_TiendaFalsa(tienda)),
      ],
      child: pantalla(const CheckoutPantalla()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al elegir Yape se ve el QR que subió el tendero',
      (tester) async {
    await _abrirCheckout(
      tester,
      const Tienda(numeroYape: '999 888 777', qrYapeUrl: _qrDemo),
    );

    await tester.tap(find.text('Yape'));
    await tester.pumpAndSettle();

    expect(find.byType(VistaQr), findsOneWidget);
    expect(find.text('999 888 777'), findsOneWidget);
    expect(find.text('Código de operación'), findsOneWidget);
  });

  testWidgets('sin número ni QR, el método no se puede elegir', (tester) async {
    await _abrirCheckout(tester, const Tienda());

    expect(find.text('La tienda aún no lo tiene configurado'), findsNWidgets(2));

    await tester.tap(find.text('Yape'));
    await tester.pumpAndSettle();

    // Sigue en efectivo: no aparece el bloque de cobro.
    expect(find.byType(VistaQr), findsNothing);
  });

  testWidgets('con número pero sin QR se muestra solo el número',
      (tester) async {
    await _abrirCheckout(tester, const Tienda(numeroPlin: '955 444 333'));

    await tester.tap(find.text('Plin'));
    await tester.pumpAndSettle();

    expect(find.text('955 444 333'), findsOneWidget);
    expect(find.byType(VistaQr), findsNothing);
  });
}
