import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/core/config.dart';

/// Entrar con Google sale de la app al navegador y vuelve por un enlace. Sin
/// decir a dónde volver, Supabase manda a la "Site URL" del proyecto, una
/// página web: el celular nunca recibe la sesión. El enlace propio tiene que
/// estar en tres lugares a la vez —el código, Android e iOS— y además en las
/// "Redirect URLs" de Supabase, que eso ya no se puede probar desde aquí.
void main() {
  const url = 'com.jorge.tiendabarrio://login-callback';

  test('en el celular vuelve a la app por su enlace propio; en la web, a la página', () {
    expect(Config.volverDeGoogle(web: false), url);
    expect(Config.volverDeGoogle(web: true), isNull);
  });

  test('el esquema es válido y no es web: sin guion bajo ni http', () {
    final esquema = Uri.parse(url).scheme;
    expect(esquema, matches(RegExp(r'^[a-z][a-z0-9+.\-]*$')));
    expect(esquema, isNot(startsWith('http')));
  });

  test('la entrada con Google le dice a Supabase a dónde volver', () {
    final repo = File('lib/datos/repos/supabase_repos.dart').readAsStringSync();
    expect(repo, contains('redirectTo: Config.volverDeGoogle(web: kIsWeb)'));
  });

  test('Android abre la app con ese enlace', () {
    final manifiesto = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifiesto, contains('android.intent.action.VIEW'));
    expect(manifiesto, contains('android.intent.category.BROWSABLE'));
    expect(manifiesto, contains('android:scheme="com.jorge.tiendabarrio"'));
    expect(manifiesto, contains('android:host="login-callback"'));
    // Lo atiende Supabase; si Flutter también lo tomara, go_router buscaría
    // una pantalla "/login-callback" que no existe.
    expect(
      manifiesto,
      contains('android:name="flutter_deeplinking_enabled" android:value="false"'),
    );
  });

  test('iOS también', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('CFBundleURLSchemes'));
    expect(plist, contains('<string>com.jorge.tiendabarrio</string>'));
    expect(
      plist,
      matches(RegExp(r'<key>FlutterDeepLinkingEnabled</key>\s*<false/>')),
    );
  });
}
