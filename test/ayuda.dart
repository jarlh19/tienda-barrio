import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tienda_barrio/estado/preferencias.dart';
import 'package:tienda_barrio/l10n/app_localizations.dart';

/// Utilidades para las pruebas de interfaz.
///
/// Desde que la app sigue el idioma del celular, una prueba que busque texto
/// en español tiene que decir en qué idioma está mirando: el entorno de
/// pruebas arranca en inglés y, sin fijarlo, las búsquedas fallarían por un
/// motivo que no tiene nada que ver con lo que se está probando.

class _IdiomaFijo extends IdiomaNotifier {
  _IdiomaFijo(this._idioma);

  final Locale _idioma;

  @override
  Locale? build() => _idioma;
}

/// Overrides para que la app corra en [idioma].
List<Override> en(String idioma) =>
    [idiomaProvider.overrideWith(() => _IdiomaFijo(Locale(idioma)))];

/// Una pantalla suelta, con las traducciones cargadas.
Widget pantalla(Widget hija, {String idioma = 'es'}) => MaterialApp(
      locale: Locale(idioma),
      supportedLocales: L.supportedLocales,
      localizationsDelegates: L.localizationsDelegates,
      home: hija,
    );
