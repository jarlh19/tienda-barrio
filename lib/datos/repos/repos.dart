import 'dart:typed_data';

import '../modelos/modelos.dart';

/// Contratos de datos. La app solo conoce estas interfaces; detrás puede estar
/// Supabase (producción) o el almacén en memoria (modo demo).

/// Avisos que nacen dentro de la app.
///
/// Van como clave y no como texto porque aquí abajo no se sabe en qué idioma
/// está mirando el usuario: quien los muestra en pantalla es quien los
/// traduce. Lo que llega del servidor no entra en esta lista; ese texto se
/// enseña tal cual, en el idioma en que venga.
enum Aviso {
  pedidoNoExiste,
  clienteNoEncontrado,
  indicaUnidades,
  insumoNoExiste,

  /// Datos: `insumo`, `quedan`, `unidad`, `necesitas`.
  insumoInsuficiente,
  sinConexion,
  operacionFallida,
  perfilNoCreado,
  credencialesInvalidas,
  confirmaCorreo,

  /// Datos: `metodo` (un [MetodoPago]).
  faltaCodigoOperacion,
  tarjetaNoHabilitada,
  sesionRequerida,
  carritoVacio,
  faltaDireccion,

  /// Datos: `disponible`, `limite`.
  cupoInsuficiente,
}

class ErrorApp implements Exception {
  /// [mensaje] es lo que se enseña cuando no hay [aviso]: el texto que vino del
  /// servidor. Con [aviso], la pantalla lo traduce y [mensaje] queda de
  /// respaldo y para los registros.
  ErrorApp(this.mensaje, {this.aviso, this.datos = const {}});

  final String mensaje;
  final Aviso? aviso;
  final Map<String, Object?> datos;

  @override
  String toString() => mensaje;
}

abstract class AuthRepo {
  /// Emite el perfil cada vez que cambia la sesión (`null` = sin sesión).
  Stream<Perfil?> get cambios;

  Perfil? get perfilActual;

  Future<Perfil> iniciarSesion({required String email, required String clave});

  /// `true` si en esta plataforma se puede entrar con la cuenta de Google del
  /// dispositivo. Falso, por ejemplo, si falta configurar el ID de cliente.
  bool get hayGoogle;

  /// Entra con la cuenta de Google del dispositivo: el nombre y el correo
  /// salen de ahí y el usuario no escribe nada.
  ///
  /// Devuelve `null` cuando no hay perfil que entregar todavía, que son dos
  /// casos: el usuario cerró el selector de cuentas, o la plataforma termina
  /// la entrada por redirección (web) y el perfil llegará por [cambios].
  Future<Perfil?> entrarConGoogle();

  Future<Perfil> registrar({
    required String nombre,
    required String email,
    required String clave,
    String telefono = '',
    String direccion = '',
    Rol rol = Rol.cliente,
  });

  Future<void> cerrarSesion();

  Future<Perfil> guardarPerfil(Perfil perfil);

  /// Solo para el tendero: lista de clientes registrados.
  Future<List<Perfil>> clientes();
}

abstract class CatalogoRepo {
  Future<List<Categoria>> categorias();

  Future<List<Producto>> productos({
    String? categoriaId,
    String busqueda = '',
    bool soloActivos = true,
  });

  /// Busca por el código impreso en el envase. `null` si no está registrado.
  /// Incluye los productos dados de baja: si el tendero vuelve a comprar algo
  /// que descontinuó, lo reactiva en vez de duplicarlo.
  Future<Producto?> porCodigoBarras(String codigo);

  Future<Producto> guardarProducto(Producto producto);

  Future<void> eliminarProducto(String id);
}

abstract class PedidosRepo {
  Future<Pedido> crear(Pedido pedido);

  Future<List<Pedido>> deCliente(String clienteId);

  Future<List<Pedido>> todos();

  /// Pedidos en vivo para el panel del tendero.
  Stream<List<Pedido>> flujoTodos();

  Future<Pedido> cambiarEstado(String pedidoId, EstadoPedido estado);

  Future<Pedido> cambiarEstadoPago(
    String pedidoId,
    EstadoPago estado, {
    String? referencia,
  });
}

abstract class InventarioRepo {
  /// Registra el movimiento y mueve el stock del producto en el mismo paso.
  /// Todo lo que entra o sale del inventario pasa por aquí.
  Future<MovimientoInventario> registrar(MovimientoInventario movimiento);

  /// [limite] existe para que la pantalla de Caja no se traiga el kardex
  /// entero de un año cuando el tendero elija "este mes".
  Future<List<MovimientoInventario>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? productoId,
    int limite = 500,
  });
}

abstract class InsumosRepo {
  Future<List<Insumo>> insumos({bool soloActivos = true});

  Future<Insumo> guardar(Insumo insumo);

  /// Baja lógica: el histórico de consumos sigue nombrando al insumo.
  Future<void> darDeBaja(String insumoId);

  Future<MovimientoInsumo> registrarMovimiento(MovimientoInsumo movimiento);

  Future<List<MovimientoInsumo>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? insumoId,
    int limite = 500,
  });

  /// Receta del producto: cuánto de cada insumo lleva un lote.
  Future<List<LineaReceta>> receta(String productoId);

  Future<void> guardarReceta(String productoId, List<LineaReceta> lineas);

  /// Registra una horneada completa en un solo paso: descuenta los insumos,
  /// mete las unidades al inventario y devuelve el costo real y el rendimiento.
  ///
  /// Es una sola operación a propósito: producir sin descontar la harina, o
  /// descontarla sin que entre el pan, dejaría los números mintiendo.
  Future<ResultadoProduccion> registrarProduccion({
    required Producto producto,
    required double lotes,
    required int unidadesProducidas,
    required List<ConsumoInsumo> consumos,
    String nota = '',
  });
}

abstract class TiendaRepo {
  Future<Tienda> obtener();

  Future<Tienda> guardar(Tienda tienda);

  /// Sube el QR que el tendero exportó de su app de banco y devuelve la URL
  /// pública que se le muestra al cliente al pagar.
  Future<String> subirQr({
    required MetodoPago metodo,
    required Uint8List bytes,
    required String extension,
  });
}

abstract class FiadoRepo {
  Future<CuentaFiado> cuenta(String clienteId);

  Future<List<CuentaFiado>> cuentas();

  Future<void> registrarMovimiento(MovimientoFiado movimiento);

  Future<void> cambiarLimite(String clienteId, double limite);
}
