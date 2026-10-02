import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/estado/providers.dart';
import 'package:tienda_barrio/ui/auth/login_pantalla.dart';

void main() {
  /// [conGoogle] simula que la app ya está registrada en Google Cloud. En las
  /// pruebas no se puede tocar `Config`, que se resuelve al compilar, pero sí
  /// el provider que decide si el botón se muestra.
  Future<void> abrir(WidgetTester tester, {bool conGoogle = false}) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [
            if (conGoogle) hayGoogleProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: LoginPantalla()),
        ),
      );

  testWidgets('sin registrar en Google Cloud no se ofrece ese botón',
      (tester) async {
    await abrir(tester);

    expect(find.text('Continuar con Google'), findsNothing);
    expect(find.text('Prefiero usar mi correo'), findsNothing);

    // Y el formulario no queda escondido detrás de nada: es la única entrada.
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('No tengo cuenta, quiero registrarme'), findsOneWidget);

    // En modo demo se puede entrar sin credenciales.
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Tendero'), findsOneWidget);
  });

  testWidgets('con Google configurado el formulario pasa a segundo plano',
      (tester) async {
    await abrir(tester, conGoogle: true);

    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Correo'), findsNothing);
    expect(find.text('Entrar'), findsNothing);

    await tester.tap(find.text('Prefiero usar mi correo'));
    await tester.pumpAndSettle();

    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    // El botón de Google no desaparece al abrir el formulario.
    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}
