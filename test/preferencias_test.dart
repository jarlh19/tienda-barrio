import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tienda_barrio/estado/preferencias.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences almacen;

  ProviderContainer conAlmacen() => ProviderContainer(
        overrides: [almacenPrefsProvider.overrideWithValue(almacen)],
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    almacen = await SharedPreferences.getInstance();
  });

  test('sin elegir nada, el tema y el idioma los pone el celular', () {
    final c = conAlmacen();
    addTearDown(c.dispose);

    expect(c.read(temaProvider), ThemeMode.system);
    expect(c.read(idiomaProvider), isNull);
  });

  test('el tema elegido sobrevive a cerrar la app', () async {
    final c = conAlmacen();
    await c.read(temaProvider.notifier).cambiar(ThemeMode.dark);
    expect(c.read(temaProvider), ThemeMode.dark);
    c.dispose();

    // Otra sesión, el mismo almacén: es lo que pasa al volver a abrir.
    final otra = conAlmacen();
    addTearDown(otra.dispose);
    expect(otra.read(temaProvider), ThemeMode.dark);
  });

  test('el idioma elegido sobrevive, y volver a automático también', () async {
    final c = conAlmacen();
    await c.read(idiomaProvider.notifier).cambiar(const Locale('en'));
    c.dispose();

    final segunda = conAlmacen();
    expect(segunda.read(idiomaProvider)?.languageCode, 'en');
    await segunda.read(idiomaProvider.notifier).cambiar(null);
    segunda.dispose();

    final tercera = conAlmacen();
    addTearDown(tercera.dispose);
    expect(tercera.read(idiomaProvider), isNull,
        reason: 'volver a automático tiene que borrar la elección anterior');
  });

  test('sin almacén la app sigue funcionando, solo que no recuerda', () async {
    // Es el caso de los tests y de cualquier arranque donde no haya disco.
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(temaProvider), ThemeMode.system);
    await c.read(temaProvider.notifier).cambiar(ThemeMode.light);
    expect(c.read(temaProvider), ThemeMode.light);
  });
}
