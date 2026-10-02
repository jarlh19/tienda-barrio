import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/main.dart';

void main() {
  testWidgets('entrar en modo demo lleva al catálogo', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TiendaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Cliente'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('¿Qué necesitas hoy?'), findsOneWidget);
  });

  testWidgets('el atajo demo funciona aunque el formulario esté en registro',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TiendaApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No tengo cuenta, quiero registrarme'));
    await tester.pumpAndSettle();
    expect(find.text('Crear cuenta'), findsOneWidget);

    // En el alto del test el atajo queda fuera de pantalla al desplegarse
    // el formulario de registro.
    await tester.ensureVisible(find.text('Tendero'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tendero'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Entra al panel del tendero sin exigir los campos del registro.
    expect(find.text('Escribe tu nombre'), findsNothing);
    expect(find.text('Inventario'), findsOneWidget);
  });
}
