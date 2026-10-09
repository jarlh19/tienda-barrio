import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias del usuario que sobreviven al cierre de la app: tema e idioma.
///
/// El almacén se inyecta desde `main` en vez de abrirse aquí. Así los tests
/// construyen un `ProviderScope` sin preparar nada: sin almacén las
/// preferencias funcionan igual, solo que no se recuerdan.
final almacenPrefsProvider = Provider<SharedPreferences?>((ref) => null);

const _claveTema = 'tema';
const _claveIdioma = 'idioma';

/// Tema de la app. `ThemeMode.system` sigue al celular, que es lo que hacía
/// antes de que esto existiera.
class TemaNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final guardado = ref.watch(almacenPrefsProvider)?.getString(_claveTema);
    return ThemeMode.values.firstWhere(
      (m) => m.name == guardado,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> cambiar(ThemeMode modo) async {
    state = modo;
    await ref.read(almacenPrefsProvider)?.setString(_claveTema, modo.name);
  }
}

final temaProvider = NotifierProvider<TemaNotifier, ThemeMode>(TemaNotifier.new);

/// Idioma elegido a mano. `null` = seguir al celular.
class IdiomaNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final guardado = ref.watch(almacenPrefsProvider)?.getString(_claveIdioma);
    if (guardado == null || guardado.isEmpty) return null;
    return Locale(guardado);
  }

  Future<void> cambiar(Locale? idioma) async {
    state = idioma;
    final prefs = ref.read(almacenPrefsProvider);
    if (prefs == null) return;
    // Cadena vacía = automático. Borrar la clave serviría igual, pero deja
    // dudando si nunca se eligió o si se eligió automático.
    await prefs.setString(_claveIdioma, idioma?.languageCode ?? '');
  }
}

final idiomaProvider =
    NotifierProvider<IdiomaNotifier, Locale?>(IdiomaNotifier.new);
