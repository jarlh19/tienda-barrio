import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/main.dart';

import 'ayuda.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester, {String idioma = 'es'}) async {
    await tester.pumpWidget(
      ProviderScope(overrides: en(idioma), child: const TiendaApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('entrar en modo demo lleva al catálogo', (tester) async {
    await abrirApp(tester);

    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Cliente'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('¿Qué necesitas hoy?'), findsOneWidget);
  });

  testWidgets('el atajo demo funciona aunque el formulario esté en registro',
      (tester) async {
    await abrirApp(tester);

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

  testWidgets('en inglés el recorrido completo también está traducido',
      (tester) async {
    await abrirApp(tester, idioma: 'en');

    await tester.tap(find.text('Shopkeeper'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Las pestañas del panel y el contenido de la primera.
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Active only'), findsOneWidget);
  });
}
