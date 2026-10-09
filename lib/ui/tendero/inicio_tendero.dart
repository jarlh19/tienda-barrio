import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../l10n/app_localizations.dart';
import '../comun/perfil_pantalla.dart';
import '../comun/widgets.dart';
import 'caja_pantalla.dart';
import 'fiado_admin_pantalla.dart';
import 'inventario_pantalla.dart';
import 'pedidos_admin_pantalla.dart';

/// Panel del tendero: pedidos que entran, inventario y cuentas de fiado.
class InicioTendero extends ConsumerStatefulWidget {
  const InicioTendero({super.key});

  @override
  ConsumerState<InicioTendero> createState() => _InicioTenderoState();
}

class _InicioTenderoState extends ConsumerState<InicioTendero> {
  int _indice = 0;

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
                PedidosAdminPantalla(),
                InventarioPantalla(),
                CajaPantalla(),
                FiadoAdminPantalla(),
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
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l.navPedidos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l.navInventario,
          ),
          NavigationDestination(
            icon: const Icon(Icons.point_of_sale_outlined),
            selectedIcon: const Icon(Icons.point_of_sale),
            label: l.navCaja,
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
