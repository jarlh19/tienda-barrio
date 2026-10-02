import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../datos/modelos/modelos.dart';
import '../estado/providers.dart';
import '../ui/auth/login_pantalla.dart';
import '../ui/cliente/carrito_pantalla.dart';
import '../ui/cliente/checkout_pantalla.dart';
import '../ui/cliente/inicio_cliente.dart';
import '../ui/tendero/inicio_tendero.dart';

/// Puente entre Riverpod y go_router: cada cambio de sesión reevalúa el
/// `redirect`, así entrar o salir mueve la app sola a la pantalla correcta.
class _RefrescoSesion extends ChangeNotifier {
  _RefrescoSesion(Ref ref) {
    ref.listen<Perfil?>(sesionProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresco = _RefrescoSesion(ref);
  ref.onDispose(refresco.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresco,
    redirect: (context, estado) {
      final perfil = ref.read(sesionProvider);
      final ruta = estado.matchedLocation;
      final enLogin = ruta == '/login';

      if (perfil == null) return enLogin ? null : '/login';

      final zonaTendero = ruta.startsWith('/tienda');
      if (perfil.esTendero) return zonaTendero ? null : '/tienda';
      if (enLogin || zonaTendero) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginPantalla(),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => const InicioCliente(),
        routes: [
          GoRoute(
            path: 'carrito',
            builder: (_, _) => const CarritoPantalla(),
          ),
          GoRoute(
            path: 'checkout',
            builder: (_, _) => const CheckoutPantalla(),
          ),
        ],
      ),
      GoRoute(
        path: '/pedidos',
        builder: (_, _) => const InicioCliente(pestanaInicial: 1),
      ),
      GoRoute(
        path: '/fiado',
        builder: (_, _) => const InicioCliente(pestanaInicial: 2),
      ),
      GoRoute(
        path: '/tienda',
        builder: (_, _) => const InicioTendero(),
      ),
    ],
  );
});
