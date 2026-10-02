import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datos/modelos/modelos.dart';
import '../datos/repos/repos.dart';
import 'carrito.dart';
import 'providers.dart';

/// Orquesta el cierre de un pedido: valida, cobra, guarda y —si es fiado—
/// carga la deuda a la cuenta del cliente. Las pantallas solo llaman a
/// [confirmar]; toda la regla de negocio vive aquí.
class Checkout {
  Checkout(this._ref);

  final Ref _ref;

  Future<Pedido> confirmar({
    required MetodoPago metodo,
    required String direccion,
    String referencia = '',
    String notas = '',
  }) async {
    final perfil = _ref.read(sesionProvider);
    if (perfil == null) throw ErrorApp('Inicia sesión para pedir.');

    final items = _ref.read(carritoProvider);
    if (items.isEmpty) throw ErrorApp('Tu carrito está vacío.');

    if (direccion.trim().isEmpty) {
      throw ErrorApp('Indica a qué dirección llevamos el pedido.');
    }

    final total = items.fold<double>(0, (s, i) => s + i.subtotal);

    // El fiado se valida antes de cobrar: si no alcanza el cupo, no hay pedido.
    if (metodo == MetodoPago.fiado) {
      final cuenta = await _ref.read(fiadoRepoProvider).cuenta(perfil.id);
      if (!cuenta.alcanzaPara(total)) {
        throw ErrorApp(
          'Tu cupo de fiado no alcanza. Disponible: '
          'S/ ${cuenta.disponible.toStringAsFixed(2)} de S/ '
          '${cuenta.limite.toStringAsFixed(2)}.',
        );
      }
    }

    final borrador = Pedido(
      id: '',
      clienteId: perfil.id,
      clienteNombre: perfil.nombre,
      items: items,
      creadoEn: DateTime.now(),
      metodoPago: metodo,
      direccion: direccion.trim(),
      notas: notas.trim(),
    );

    final cobro = await _ref.read(pasarelaProvider).cobrar(
          pedido: borrador,
          metodo: metodo,
          referencia: referencia,
        );

    final pedido = await _ref.read(pedidosRepoProvider).crear(
          Pedido(
            id: '',
            clienteId: borrador.clienteId,
            clienteNombre: borrador.clienteNombre,
            items: borrador.items,
            creadoEn: borrador.creadoEn,
            estado: EstadoPedido.pendiente,
            metodoPago: metodo,
            estadoPago: cobro.estado,
            referenciaPago: cobro.referencia,
            direccion: borrador.direccion,
            notas: borrador.notas,
          ),
        );

    // El cargo al fiado lo escribe quien guarda el pedido —el trigger en
    // Supabase, el repo en modo demo— y no esta pantalla: en producción la
    // política solo deja escribir la deuda al tendero, y el cliente jamás
    // debería poder anotar la suya.

    // Quien entra con Google llega sin direccion: la escribe aqui la primera
    // vez y se queda guardada, para que el siguiente pedido salga ya lleno.
    // Si falla no se toca el pedido, que ya esta hecho.
    if (pedido.direccion.isNotEmpty && pedido.direccion != perfil.direccion) {
      try {
        await _ref
            .read(sesionProvider.notifier)
            .guardar(perfil.copiar(direccion: pedido.direccion));
      } catch (_) {
        // Recordar la direccion es comodidad, no parte del pedido.
      }
    }

    _ref.read(carritoProvider.notifier).limpiar();
    refrescarTodoDesdeProvider(_ref);
    return pedido;
  }
}

final checkoutProvider = Provider<Checkout>(Checkout.new);
