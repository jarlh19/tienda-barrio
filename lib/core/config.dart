/// Configuración de entorno.
///
/// Las credenciales de Supabase entran por `--dart-define` para no quedar
/// escritas en el repositorio:
///
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Si faltan, la app arranca en **modo demo** con datos en memoria: sirve para
/// probar la interfaz completa sin backend, pero nada se guarda al cerrar.
class Config {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hayBackend =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// ID de cliente **web** de Google, aunque la app corra en Android.
  ///
  /// Android tiene su propio ID de cliente (el que lleva la huella SHA-1), pero
  /// ese solo sirve para que Google reconozca al APK. El token que Android
  /// devuelve va dirigido a quien lo va a leer —Supabase—, y esa audiencia se
  /// declara con el ID de cliente web. Poner aquí el de Android hace que
  /// Supabase rechace el token sin decir por qué.
  static const googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// ID de cliente de iOS. En iPhone sí es el suyo propio.
  static const googleClientIdIos =
      String.fromEnvironment('GOOGLE_CLIENT_ID_IOS');

  /// Mientras la app no esté registrada en Google Cloud no hay a quién pedirle
  /// el token, así que el botón ni siquiera se muestra: es preferible una
  /// pantalla con una sola forma de entrar a una con un botón que falla.
  ///
  /// El día que se registre, basta pasar el ID de cliente por `--dart-define`
  /// y el botón aparece solo; el código de entrada ya está escrito.
  static bool get hayGoogle =>
      googleServerClientId.isNotEmpty || googleClientIdIos.isNotEmpty;

  static bool get modoDemo => !hayBackend;

  /// Nombre por defecto; los datos de cobro (numero y QR de Yape/Plin) los
  /// configura el tendero desde la app y viven en la base, no aqui.
  static const nombreTienda = 'Tienda de Barrio';
  static const simboloMoneda = 'S/';
}
