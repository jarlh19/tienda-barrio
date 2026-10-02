import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Caja',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Fiado',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
