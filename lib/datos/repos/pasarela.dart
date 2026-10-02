import '../modelos/modelos.dart';
import 'repos.dart';

class ResultadoPago {
  const ResultadoPago({
    required this.estado,
    this.referencia = '',
    this.mensaje = '',
  });

  final EstadoPago estado;
  final String referencia;
  final String mensaje;
}

/// Punto único por donde pasa todo cobro.
///
/// Hoy solo existe [PagoLocal] (efectivo, Yape/Plin con código de operación y
/// fiado). Para conectar una pasarela real —Mercado Pago, Culqi, Izipay— se
/// implementa esta misma interfaz y se cambia el provider en `providers.dart`;
/// ninguna pantalla necesita cambiar.
abstract class PasarelaPago {
  Future<ResultadoPago> cobrar({
    required Pedido pedido,
    required MetodoPago metodo,
    String referencia = '',
  });
}

/// Cobros que no requieren integración externa.
class PagoLocal implements PasarelaPago {
  const PagoLocal();

  @override
  Future<ResultadoPago> cobrar({
    required Pedido pedido,
    required MetodoPago metodo,
    String referencia = '',
  }) async {
    switch (metodo) {
      case MetodoPago.efectivo:
        return const ResultadoPago(
          estado: EstadoPago.pendiente,
          mensaje: 'Pagas en efectivo cuando recibas tu pedido.',
        );

      case MetodoPago.yape:
      case MetodoPago.plin:
        if (referencia.trim().length < 4) {
          throw ErrorApp(
              'Ingresa el código de operación de tu ${metodo.etiqueta}.');
        }
        return ResultadoPago(
          estado: EstadoPago.verificando,
          referencia: referencia.trim(),
          mensaje: 'La tienda verificará tu pago en unos minutos.',
        );

      case MetodoPago.fiado:
        return const ResultadoPago(
          estado: EstadoPago.fiado,
          mensaje: 'El monto se cargó a tu cuenta de fiado.',
        );

      case MetodoPago.tarjeta:
        throw ErrorApp(
          'El pago con tarjeta aún no está habilitado. '
          'Usa Yape, Plin, efectivo o fiado.',
        );
    }
  }
}
