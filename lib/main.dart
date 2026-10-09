import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/router.dart';
import 'core/tema.dart';
import 'estado/preferencias.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Los nombres de meses y días de ambos idiomas, que `intl` carga aparte.
  await initializeDateFormatting();

  // Sin credenciales la app corre en modo demo con datos en memoria.
  if (Config.hayBackend) {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      publishableKey: Config.supabaseAnonKey,
    );
  }

  // Se leen antes de dibujar: si el tema guardado llegara después, la app
  // arrancaría en claro y saltaría a oscuro delante del usuario.
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [almacenPrefsProvider.overrideWithValue(prefs)],
    child: const TiendaApp(),
  ));
}

class TiendaApp extends ConsumerWidget {
  const TiendaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: Config.nombreTienda,
      debugShowCheckedModeBanner: false,
      theme: Tema.claro(),
      darkTheme: Tema.oscuro(),
      themeMode: ref.watch(temaProvider),
      routerConfig: ref.watch(routerProvider),
      // `null` deja que Flutter elija según el idioma del celular.
      locale: ref.watch(idiomaProvider),
      supportedLocales: L.supportedLocales,
      localizationsDelegates: L.localizationsDelegates,
    );
  }
}
