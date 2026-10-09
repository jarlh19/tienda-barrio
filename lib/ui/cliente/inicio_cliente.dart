import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../l10n/app_localizations.dart';
import '../comun/perfil_pantalla.dart';
import '../comun/widgets.dart';
import 'catalogo_pantalla.dart';
import 'mi_fiado_pantalla.dart';
import 'mis_pedidos_pantalla.dart';

/// Contenedor con la barra inferior del cliente.
/// [pestanaInicial] permite entrar directo a una sección desde una ruta.
class InicioCliente extends ConsumerStatefulWidget {
  const InicioCliente({super.key, this.pestanaInicial = 0});

  final int pestanaInicial;

  @override
  ConsumerState<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends ConsumerState<InicioCliente> {
  late int _indice = widget.pestanaInicial;

  @override
  void didUpdateWidget(InicioCliente anterior) {
    super.didUpdateWidget(anterior);
    if (widget.pestanaInicial != anterior.pestanaInicial) {
      setState(() => _indice = widget.pestanaInicial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      body: Column(
        children: [
          if (Config.modoDemo) const AvisoDemo(),
          Expanded(
            child: IndexedStack(
              index: _indice,
              children: const [
                CatalogoPantalla(),
                MisPedidosPantalla(),
                MiFiadoPantalla(),
                PerfilPantalla(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l.navTienda,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l.navPedidos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l.navFiado,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.navPerfil,
          ),
        ],
      ),
    );
  }
}
