import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';
import 'package:tienda_barrio/ui/tendero/inventario_pantalla.dart';

/// Lo que hace el escáner cuando lee un código que no está registrado:
/// abrir el alta con ese código puesto, para que el tendero solo ponga
/// nombre, precio y cantidad.
void main() {
  testWidgets('un código nuevo abre el alta con el código ya escrito',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    abrirAltaConCodigo(context, ref, '7751234567890'),
                child: const Text('simular escaneo'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('simular escaneo'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('7751234567890'), findsOneWidget);
  });

  test('el catálogo demo no conoce ese código todavía', () async {
    final repo = MemCatalogoRepo(AlmacenMemoria.instancia);
    expect(await repo.porCodigoBarras('7751234567890'), isNull);
  });
}
