import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/estado/carrito.dart';
import 'package:tienda_barrio/estado/checkout.dart';
import 'package:tienda_barrio/estado/providers.dart';

/// El botón de Google está escondido hasta que la app se registre en Google
/// Cloud, pero el camino existe y estas pruebas lo mantienen vivo: el día que se
/// active no debería descubrirse ahí un problema viejo.
///
/// Entrar con Google trae nombre y correo, pero nunca celular ni dirección: eso
/// Google no lo tiene. Lo que se fija aquí es que la app no quede coja por eso.
void main() {
  late ProviderContainer c;

  setUp(() => c = ProviderContainer());
  tearDown(() => c.dispose());

  test('entrar con Google deja una sesión utilizable', () async {
    expect(c.read(sesionProvider), isNull);

    await c.read(sesionProvider.notifier).entrarConGoogle();

    final perfil = c.read(sesionProvider);
    expect(perfil, isNotNull);
    expect(perfil!.nombre, isNotEmpty);
    // Entra como vecino, nunca como dueño de la tienda.
    expect(perfil.esTendero, isFalse);
  });

  test('la dirección del primer pedido queda guardada en el perfil', () async {
    await c.read(sesionProvider.notifier).entrarConGoogle();
    await c.read(sesionProvider.notifier).guardar(
          c.read(sesionProvider)!.copiar(direccion: ''),
        );
    expect(c.read(sesionProvider)!.direccion, isEmpty);

    final productos = await c.read(catalogoRepoProvider).productos();
    c.read(carritoProvider.notifier).agregar(productos.first);

    await c.read(checkoutProvider).confirmar(
          metodo: MetodoPago.efectivo,
          direccion: 'Jr. Zapallal 123',
        );

    // El siguiente pedido ya sale con la dirección puesta.
    expect(c.read(sesionProvider)!.direccion, 'Jr. Zapallal 123');
  });
}
