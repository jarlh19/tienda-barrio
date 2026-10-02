import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/ui/comun/widgets.dart';

void main() {
  late List<MethodCall> llamadas;

  setUp(() {
    llamadas = [];
    // El portapapeles es del sistema operativo: en un test no existe, así que
    // se intercepta el canal para ver qué se le pidió copiar.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (llamada) async {
      llamadas.add(llamada);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('copia el número tal cual y lo avisa', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BotonCopiar(texto: '999888777', aviso: 'Número copiado'),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    final copiar = llamadas.firstWhere((c) => c.method == 'Clipboard.setData');
    expect(copiar.arguments['text'], '999888777');

    expect(find.text('Número copiado'), findsOneWidget);
  });

  testWidgets('si el portapapeles se niega, lo dice en vez de no hacer nada',
      (tester) async {
    // Es lo que hace el navegador cuando el permiso está denegado.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (llamada) async {
      if (llamada.method == 'Clipboard.setData') {
        throw PlatformException(code: 'denied');
      }
      return null;
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BotonCopiar(texto: '999888777')),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('No se pudo copiar'), findsOneWidget);
  });
}
