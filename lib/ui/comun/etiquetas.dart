import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../datos/repos/repos.dart';
import '../../core/formato.dart';
import '../../l10n/app_localizations.dart';

/// Cómo se nombra cada valor del dominio en pantalla.
///
/// Vive en la capa de UI, no en los modelos: `EstadoPedido.listo` significa lo
/// mismo en cualquier idioma, y "Listo para entregar" es solo una de sus
/// formas de decirlo. Mientras el texto estuvo dentro del modelo, traducir la
/// app obligaba a meter el idioma en el dominio.

extension EstadoPedidoTexto on EstadoPedido {
  String texto(L l) => switch (this) {
        EstadoPedido.pendiente => l.estadoPedidoPendiente,
        EstadoPedido.confirmado => l.estadoPedidoConfirmado,
        EstadoPedido.preparando => l.estadoPedidoPreparando,
        EstadoPedido.listo => l.estadoPedidoListo,
        EstadoPedido.entregado => l.estadoPedidoEntregado,
        EstadoPedido.cancelado => l.estadoPedidoCancelado,
      };
}

extension MetodoPagoTexto on MetodoPago {
  String texto(L l) => switch (this) {
        MetodoPago.efectivo => l.metodoPagoEfectivo,
        MetodoPago.yape => l.metodoPagoYape,
        MetodoPago.plin => l.metodoPagoPlin,
        MetodoPago.tarjeta => l.metodoPagoTarjeta,
        MetodoPago.fiado => l.metodoPagoFiado,
      };
}

extension EstadoPagoTexto on EstadoPago {
  String texto(L l) => switch (this) {
        EstadoPago.pendiente => l.estadoPagoPendiente,
        EstadoPago.verificando => l.estadoPagoVerificando,
        EstadoPago.pagado => l.estadoPagoPagado,
        EstadoPago.fiado => l.estadoPagoFiado,
        EstadoPago.fallido => l.estadoPagoFallido,
      };
}

extension TipoMovimientoInventarioTexto on TipoMovimientoInventario {
  String texto(L l) => switch (this) {
        TipoMovimientoInventario.produccion => l.movInvProduccion,
        TipoMovimientoInventario.compra => l.movInvCompra,
        TipoMovimientoInventario.venta => l.movInvVenta,
        TipoMovimientoInventario.merma => l.movInvMerma,
        TipoMovimientoInventario.ajuste => l.movInvAjuste,
        TipoMovimientoInventario.devolucion => l.movInvDevolucion,
      };
}

extension PeriodoTexto on Periodo {
  String texto(L l) => switch (this) {
        Periodo.hoy => l.periodoHoy,
        Periodo.semana => l.periodoSemana,
        Periodo.mes => l.periodoMes,
      };
}

extension TipoMovimientoInsumoTexto on TipoMovimientoInsumo {
  String texto(L l) => switch (this) {
        TipoMovimientoInsumo.compra => l.movInsumoCompra,
        TipoMovimientoInsumo.consumo => l.movInsumoConsumo,
        TipoMovimientoInsumo.merma => l.movInsumoMerma,
        TipoMovimientoInsumo.ajuste => l.movInsumoAjuste,
      };
}

/// Traduce un error que subió desde la capa de datos.
///
/// Sin [Aviso] el texto vino del servidor y se enseña tal cual: traducirlo
/// exigiría adivinar, y un mensaje raro es mejor que uno inventado.
///
/// [generico] cambia qué decir cuando el error no es nuestro; al cargar una
/// pantalla suele ser la conexión, y conviene decirlo así.
String textoDeError(L l, Object error, {String? generico}) {
  if (error is! ErrorApp) return generico ?? l.errorGenerico;
  final d = error.datos;
  return switch (error.aviso) {
    null => error.mensaje,
    Aviso.pedidoNoExiste => l.avisoPedidoNoExiste,
    Aviso.clienteNoEncontrado => l.avisoClienteNoEncontrado,
    Aviso.indicaUnidades => l.avisoIndicaUnidades,
    Aviso.insumoNoExiste => l.avisoInsumoNoExiste,
    Aviso.insumoInsuficiente => l.avisoInsumoInsuficiente(
        '${d['insumo']}',
        Formato.cantidad(d['quedan'] as num? ?? 0),
        '${d['unidad']}',
        Formato.cantidad(d['necesitas'] as num? ?? 0),
      ),
    Aviso.sinConexion => l.avisoSinConexion,
    Aviso.operacionFallida => l.avisoOperacionFallida,
    Aviso.perfilNoCreado => l.avisoPerfilNoCreado,
    Aviso.credencialesInvalidas => l.avisoCredencialesInvalidas,
    Aviso.confirmaCorreo => l.avisoConfirmaCorreo,
    Aviso.faltaCodigoOperacion =>
      l.avisoFaltaCodigoOperacion((d['metodo'] as MetodoPago).texto(l)),
    Aviso.tarjetaNoHabilitada => l.avisoTarjetaNoHabilitada,
    Aviso.sesionRequerida => l.avisoSesionRequerida,
    Aviso.carritoVacio => l.avisoCarritoVacio,
    Aviso.faltaDireccion => l.avisoFaltaDireccion,
    Aviso.cupoInsuficiente => l.avisoCupoInsuficiente(
        Formato.soles(d['disponible'] as num? ?? 0),
        Formato.soles(d['limite'] as num? ?? 0),
      ),
  };
}
