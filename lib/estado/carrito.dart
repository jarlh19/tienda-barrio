import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/modelos/modelos.dart';

/// Carrito del cliente. Vive en memoria mientras la app está abierta.
class CarritoNotifier extends Notifier<List<ItemPedido>> {
  @override
  List<ItemPedido> build() => const [];

  int cantidadDe(String productoId) {
    for (final i in state) {
      if (i.productoId == productoId) return i.cantidad;
    }
    return 0;
  }

  double get total => state.fold(0, (s, i) => s + i.subtotal);
  int get unidades => state.fold(0, (s, i) => s + i.cantidad);
  bool get vacio => state.isEmpty;

  void agregar(Producto producto, {int cantidad = 1}) {
    final actual = cantidadDe(producto.id);
    final nueva = actual + cantidad;
    // Nunca dejamos pedir más de lo que hay en el mostrador.
    cambiarCantidad(
      producto,
      nueva > producto.stock ? producto.stock : nueva,
    );
  }

  void cambiarCantidad(Producto producto, int cantidad) {
    if (cantidad <= 0) {
      quitar(producto.id);
      return;
    }
    final idx = state.indexWhere((i) => i.productoId == producto.id);
    final item = ItemPedido(
      productoId: producto.id,
      // Se guarda el nombre completo: el pedido debe seguir legible aunque
      // el tendero cambie la marca o el envase después.
      nombre: producto.nombreCompleto,
      precioUnitario: producto.precio,
      cantidad: cantidad,
      unidad: producto.unidad,
    );
    if (idx >= 0) {
      final copia = [...state];
      copia[idx] = item;
      state = copia;
    } else {
      state = [...state, item];
    }
  }

  void ajustar(String productoId, int delta) {
    final idx = state.indexWhere((i) => i.productoId == productoId);
    if (idx < 0) return;
    final nueva = state[idx].cantidad + delta;
    if (nueva <= 0) {
      quitar(productoId);
      return;
    }
    final copia = [...state];
    copia[idx] = state[idx].conCantidad(nueva);
    state = copia;
  }

  void quitar(String productoId) {
    state = state.where((i) => i.productoId != productoId).toList();
  }

  void limpiar() => state = const [];
}

final carritoProvider =
    NotifierProvider<CarritoNotifier, List<ItemPedido>>(CarritoNotifier.new);

/// Total del carrito, para que los widgets no recalculen a mano.
final totalCarritoProvider = Provider<double>((ref) {
  final items = ref.watch(carritoProvider);
  return items.fold<double>(0, (s, i) => s + i.subtotal);
});

final unidadesCarritoProvider = Provider<int>((ref) {
  final items = ref.watch(carritoProvider);
  return items.fold<int>(0, (s, i) => s + i.cantidad);
});
