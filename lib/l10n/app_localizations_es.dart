// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get abono => 'Abono';

  @override
  String get abonoRegistrado => 'Abono registrado';

  @override
  String get agregar => 'Agregar';

  @override
  String get agregarInsumo => 'Agregar insumo';

  @override
  String get agregarSinCodigo => 'Agregar sin código';

  @override
  String get apariencia => 'Apariencia';

  @override
  String get avisarmeCuandoBajeDe => 'Avisarme cuando baje de';

  @override
  String get avisoCarritoVacio => 'Tu carrito está vacío.';

  @override
  String get avisoClienteNoEncontrado => 'Cliente no encontrado.';

  @override
  String get avisoConfirmaCorreo =>
      'Revisa tu correo para confirmar la cuenta.';

  @override
  String get avisoCredencialesInvalidas => 'Correo o contraseña incorrectos.';

  @override
  String avisoCupoInsuficiente(String disponible, String limite) {
    return 'Tu cupo de fiado no alcanza. Disponible: $disponible de $limite.';
  }

  @override
  String avisoFaltaCodigoOperacion(String metodo) {
    return 'Ingresa el código de operación de tu $metodo.';
  }

  @override
  String get avisoFaltaDireccion =>
      'Indica a qué dirección llevamos el pedido.';

  @override
  String get avisoIndicaUnidades => 'Indica cuántas unidades salieron.';

  @override
  String avisoInsumoInsuficiente(
    String insumo,
    String quedan,
    String unidad,
    String necesitas,
  ) {
    return 'No alcanza $insumo: quedan $quedan $unidad y necesitas $necesitas.';
  }

  @override
  String get avisoInsumoNoExiste => 'Ese insumo ya no existe.';

  @override
  String get avisoOperacionFallida => 'No se pudo completar la operación.';

  @override
  String get avisoPedidoNoExiste => 'El pedido ya no existe.';

  @override
  String get avisoPerfilNoCreado => 'Tu perfil aún no está creado.';

  @override
  String get avisoSesionRequerida => 'Inicia sesión para pedir.';

  @override
  String get avisoSinConexion =>
      'No se pudo conectar con la tienda. Revisa tu internet.';

  @override
  String get avisoTarjetaNoHabilitada =>
      'El pago con tarjeta aún no está habilitado. Usa Yape, Plin, efectivo o fiado.';

  @override
  String get cajaEntro => 'Entró';

  @override
  String cajaMargen(String margen, int unidades) {
    return 'Margen $margen% · $unidades unidades vendidas';
  }

  @override
  String cajaMerma(String monto) {
    return 'Se perdió $monto en merma. No sale de la caja —ya estaba pagado— pero no vuelve.';
  }

  @override
  String get cajaNoCalculada => 'No se pudo calcular la caja';

  @override
  String get cajaQueSeVendio => 'Qué se vendió';

  @override
  String get cajaSalio => 'Salió';

  @override
  String get cajaTeQueda => 'Te queda';

  @override
  String get cajaVasPerdiendo => 'Vas perdiendo';

  @override
  String get camaraNoAbre => 'No se pudo abrir la cámara.';

  @override
  String get camaraNoSoportada => 'Este dispositivo no puede escanear códigos.';

  @override
  String get camaraSinPermiso =>
      'La app necesita permiso de cámara para leer códigos.';

  @override
  String get cambiar => 'Cambiar';

  @override
  String get cambiarCamara => 'Cambiar cámara';

  @override
  String get cambiarCupo => 'Cambiar cupo';

  @override
  String get campoCategoria => 'Categoría';

  @override
  String get campoCelular => 'Celular';

  @override
  String get campoClave => 'Contraseña';

  @override
  String get campoCorreo => 'Correo';

  @override
  String get campoCosto => 'Costo';

  @override
  String get campoDetalle => 'Detalle';

  @override
  String get campoDireccion => 'Dirección';

  @override
  String get campoDireccionEntrega => 'Dirección de entrega';

  @override
  String get campoFotoUrl => 'URL de la foto (opcional)';

  @override
  String get campoMarca => 'Marca';

  @override
  String get campoMaximo => 'Máximo';

  @override
  String get campoMeCuesta => 'Me cuesta';

  @override
  String get campoMedida => 'Medida';

  @override
  String get campoMonto => 'Monto';

  @override
  String get campoNombre => 'Nombre';

  @override
  String get campoNota => 'Nota (opcional)';

  @override
  String get campoNumero => 'Número';

  @override
  String get campoPesoVolumen => 'Peso o volumen';

  @override
  String get campoPrecio => 'Precio';

  @override
  String get campoProducto => 'Producto';

  @override
  String get campoStock => 'Stock';

  @override
  String get campoTengoAhora => 'Tengo ahora';

  @override
  String get campoTrae => 'Trae';

  @override
  String get campoTraeEjemplo => 'Ej.: 50';

  @override
  String get campoUnidad => 'Unidad';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get cantidadInvalida => 'Cantidad inválida';

  @override
  String get cantidadUnidades => 'Cantidad de unidades';

  @override
  String get cargo => 'Cargo';

  @override
  String get carritoTitulo => 'Mi pedido';

  @override
  String get carritoVaciado => 'Carrito vaciado';

  @override
  String get carritoVacioDetalle =>
      'Agrega productos del catálogo para hacer tu pedido.';

  @override
  String get carritoVacioTitulo => 'Tu carrito está vacío';

  @override
  String get catalogoBuscar => '¿Qué necesitas hoy?';

  @override
  String get catalogoSinResultados => 'Sin resultados';

  @override
  String get catalogoSinResultadosDetalle =>
      'Prueba con otro nombre o cambia de categoría.';

  @override
  String get cerrarSesion => 'Cerrar sesión';

  @override
  String get checkoutEntrega => 'Entrega';

  @override
  String get checkoutFormaPago => 'Forma de pago';

  @override
  String get checkoutNota => 'Nota para la tienda (opcional)';

  @override
  String get checkoutNotaEjemplo => 'Ej.: tocar el timbre 2 veces';

  @override
  String clientesConSaldo(int n) {
    return '$n cliente(s) con saldo pendiente';
  }

  @override
  String get codigoBarrasVacio => 'Déjalo vacío si se vende suelto';

  @override
  String get codigoOperacion => 'Código de operación';

  @override
  String get codigoOperacionEjemplo => 'Ej.: 00123456';

  @override
  String codigoYaEsDe(String nombre) {
    return 'Ese código ya es de \"$nombre\".';
  }

  @override
  String get comoMePagan => 'Cómo me pagan';

  @override
  String get comoMePaganDetalle => 'Número y QR de Yape / Plin';

  @override
  String get compraRegistrada => 'Compra registrada';

  @override
  String comprarInsumo(String insumo) {
    return 'Comprar $insumo';
  }

  @override
  String confirmarPedido(String total) {
    return 'Confirmar pedido · $total';
  }

  @override
  String get consumoRegistrado => 'Consumo registrado';

  @override
  String get continuarPago => 'Continuar con el pago';

  @override
  String get copiado => 'Copiado';

  @override
  String get copiar => 'Copiar';

  @override
  String get copiarFallo =>
      'No se pudo copiar. Mantén presionado el número para seleccionarlo.';

  @override
  String get costoDelLote => 'Costo del lote';

  @override
  String get costoHelper => 'Lo que te cuesta';

  @override
  String costoInsumos(String total, String porUnidad) {
    return 'Costo de los insumos $total$porUnidad';
  }

  @override
  String get costoInvalido => 'Costo inválido';

  @override
  String costoLoteDetalle(String total, String unitario) {
    return 'Costo del lote $total · $unitario por unidad';
  }

  @override
  String costoPorUnidad(String monto, String unidad) {
    return '$monto por $unidad';
  }

  @override
  String costoPorUnidadInsumo(
    String costo,
    String unidad,
    String presentacion,
  ) {
    return '$costo por $unidad$presentacion';
  }

  @override
  String costoUnitarioPasaDe(String unidad, String antes, String despues) {
    return 'El $unidad pasa de $antes a $despues';
  }

  @override
  String cuantasPresentaciones(String nombre) {
    return '¿Cuántos ${nombre}s?';
  }

  @override
  String cuantasUnidades(String unidad) {
    return '¿Cuántos $unidad?';
  }

  @override
  String get cuantoPagasteTotal => 'Cuánto pagaste en total';

  @override
  String cuantosLotes(String lote) {
    return '¿Cuántas ${lote}s?';
  }

  @override
  String get cupoActualizado => 'Cupo actualizado';

  @override
  String get cupoDeFiado => 'Cupo de fiado';

  @override
  String cupoYDisponible(String limite, String disponible) {
    return 'Cupo $limite · disponible $disponible';
  }

  @override
  String get darDeBaja => 'Dar de baja';

  @override
  String get darDeBajaDetalle =>
      'El producto deja de aparecer en el catálogo, pero se mantiene en los pedidos anteriores.';

  @override
  String get darDeBajaPregunta => '¿Dar de baja?';

  @override
  String get detalleAbonoEjemplo => 'Pagó en efectivo';

  @override
  String get detalleCargoEjemplo => 'Compra del día';

  @override
  String get editarInsumo => 'Editar insumo';

  @override
  String get editarProducto => 'Editar producto';

  @override
  String get eligeProducto => 'Elige el producto';

  @override
  String get enStock => 'en stock';

  @override
  String get entendido => 'Entendido';

  @override
  String entraACaja(Object monto) {
    return 'Entra $monto a la caja';
  }

  @override
  String get errorDetalle => 'Revisa tu conexión e inténtalo otra vez.';

  @override
  String get errorGenerico => 'Algo salió mal. Inténtalo otra vez.';

  @override
  String get escanear => 'Escanear';

  @override
  String get escanearAMano => 'Escribirlo a mano';

  @override
  String get escanearCodigoBarras => 'Código de barras';

  @override
  String get escanearEscribirCodigo => 'Escribir el código';

  @override
  String get escanearInstruccion => 'Apunta al código de barras del envase';

  @override
  String get escanearTitulo => 'Escanear producto';

  @override
  String get estadoPagoFallido => 'Pago rechazado';

  @override
  String get estadoPagoFiado => 'Al fiado';

  @override
  String get estadoPagoPagado => 'Pagado';

  @override
  String get estadoPagoPendiente => 'Por pagar';

  @override
  String get estadoPagoVerificando => 'Verificando pago';

  @override
  String get estadoPedidoCancelado => 'Cancelado';

  @override
  String get estadoPedidoConfirmado => 'Confirmado';

  @override
  String get estadoPedidoEntregado => 'Entregado';

  @override
  String get estadoPedidoListo => 'Listo para entregar';

  @override
  String get estadoPedidoPendiente => 'Pendiente';

  @override
  String get estadoPedidoPreparando => 'Preparando';

  @override
  String get fiadoAbono => 'Abono';

  @override
  String get fiadoConsumo => 'Consumo';

  @override
  String fiadoCupoDisponible(String disponible, String limite) {
    return 'Cupo disponible $disponible de $limite';
  }

  @override
  String get fiadoDebes => 'Debes';

  @override
  String fiadoDisponibleDe(String disponible, String limite) {
    return 'Disponible $disponible de $limite';
  }

  @override
  String fiadoNoAlcanza(String texto) {
    return '$texto — no alcanza para este pedido';
  }

  @override
  String get filtroTodo => 'Todo';

  @override
  String gananciaEstimada(String monto) {
    return 'Ganancia estimada $monto';
  }

  @override
  String get guardar => 'Guardar';

  @override
  String get guardarCambios => 'Guardar cambios';

  @override
  String get guardarNumeros => 'Guardar números';

  @override
  String get guardarReceta => 'Guardar receta';

  @override
  String get haceAhora => 'ahora';

  @override
  String get haceAyer => 'ayer';

  @override
  String haceDias(int n) {
    return 'hace $n días';
  }

  @override
  String haceHoras(int n) {
    return 'hace $n h';
  }

  @override
  String haceMinutos(int n) {
    return 'hace $n min';
  }

  @override
  String get idioma => 'Idioma';

  @override
  String get idiomaAutomatico => 'Según el celular';

  @override
  String get idiomaEspanol => 'Español';

  @override
  String get idiomaIngles => 'Inglés';

  @override
  String igualAInventario(String unidades, String unidad) {
    return '= $unidades $unidad en el inventario';
  }

  @override
  String igualAUnidadBase(String cantidad, String unidad) {
    return '= $cantidad $unidad';
  }

  @override
  String get indicaCantidad => 'Indica la cantidad';

  @override
  String get indicaCuantoEntro => 'Indica cuánto entró';

  @override
  String get insumoActualizado => 'Insumo actualizado';

  @override
  String get insumoAgregado => 'Insumo agregado';

  @override
  String get insumoNombreEjemplo => 'Harina';

  @override
  String insumosPorAcabarse(int n) {
    return '$n insumo(s) por acabarse';
  }

  @override
  String get inventarioVacio => 'Inventario vacío';

  @override
  String get inventarioVacioDetalle =>
      'Agrega tu primer producto con el botón de abajo.';

  @override
  String get linterna => 'Linterna';

  @override
  String get loginCrearCuenta => 'Crear cuenta';

  @override
  String get loginDemo => 'Modo demo — entra sin registrarte';

  @override
  String get loginEntrar => 'Entrar';

  @override
  String get loginGoogle => 'Continuar con Google';

  @override
  String get loginGoogleDetalle =>
      'Usa la cuenta que ya tienes en el celular. No llenas nada.';

  @override
  String get loginLema => 'Pide lo de siempre, sin salir de casa';

  @override
  String get loginNoTengoCuenta => 'No tengo cuenta, quiero registrarme';

  @override
  String get loginOCorreo => 'o con tu correo';

  @override
  String get loginPrefieroCorreo => 'Prefiero usar mi correo';

  @override
  String get loginYaTengoCuenta => 'Ya tengo cuenta';

  @override
  String get marcaEjemplo => 'Gloria, Costeño, Primor...';

  @override
  String marcarComo(String estado) {
    return 'Marcar $estado';
  }

  @override
  String get metodoNoConfigurado => 'La tienda aún no lo tiene configurado';

  @override
  String get metodoPagoEfectivo => 'Efectivo al recibir';

  @override
  String get metodoPagoFiado => 'Fiado (a la cuenta)';

  @override
  String get metodoPagoPlin => 'Plin';

  @override
  String get metodoPagoTarjeta => 'Tarjeta (pasarela)';

  @override
  String get metodoPagoYape => 'Yape';

  @override
  String get miCuentaTitulo => 'Mi cuenta';

  @override
  String get misPedidosTitulo => 'Mis pedidos';

  @override
  String get modoDemoBanner =>
      'Modo demo: los datos son de ejemplo y no se guardan.';

  @override
  String get montoCalculado => 'Calculado del producto; puedes corregirlo';

  @override
  String get montoCosto => 'Cuánto te costó';

  @override
  String get montoEscrito => 'Lo escribiste tú';

  @override
  String get montoInvalido => 'Monto inválido';

  @override
  String get montoMerma => 'Cuánto perdiste';

  @override
  String get montoVenta => 'Cuánto cobraste';

  @override
  String get movInsumoAjuste => 'Ajuste';

  @override
  String get movInsumoCompra => 'Compra';

  @override
  String get movInsumoConsumo => 'Consumo';

  @override
  String get movInsumoMerma => 'Merma';

  @override
  String get movInvAjuste => 'Ajuste';

  @override
  String get movInvCompra => 'Compra';

  @override
  String get movInvDevolucion => 'Devolución';

  @override
  String get movInvMerma => 'Merma';

  @override
  String get movInvProduccion => 'Producción';

  @override
  String get movInvVenta => 'Venta';

  @override
  String movLotes(String n) {
    return ' · $n lote(s)';
  }

  @override
  String movPresentaciones(String n) {
    return ' · $n presentación(es)';
  }

  @override
  String movUnidades(String n) {
    return '$n und';
  }

  @override
  String movimientoRegistrado(String tipo) {
    return '$tipo registrada';
  }

  @override
  String get movimientos => 'Movimientos';

  @override
  String get navCaja => 'Caja';

  @override
  String get navFiado => 'Fiado';

  @override
  String get navInventario => 'Inventario';

  @override
  String get navPedidos => 'Pedidos';

  @override
  String get navPerfil => 'Perfil';

  @override
  String get navTienda => 'Tienda';

  @override
  String get no => 'No';

  @override
  String get noSePudoCargar => 'No se pudo cargar';

  @override
  String get nombreDelLote => 'Nombre del lote';

  @override
  String get nombreDelLoteEjemplo => 'plancha';

  @override
  String get notaEjemplo => 'Horneada de la mañana';

  @override
  String get nuevoInsumo => 'Nuevo insumo';

  @override
  String get nuevoProducto => 'Nuevo producto';

  @override
  String numeroCopiado(String metodo) {
    return 'Número copiado. Pégalo en $metodo.';
  }

  @override
  String operacionNumero(String referencia) {
    return 'Operación $referencia';
  }

  @override
  String operacionSufijo(String referencia) {
    return ' · op. $referencia';
  }

  @override
  String pagaConMetodo(String total, String metodo) {
    return 'Paga $total con $metodo';
  }

  @override
  String get pagarTitulo => 'Pagar';

  @override
  String get pagoNoLlego => 'No llegó';

  @override
  String get pagoRecibido => 'Pago recibido';

  @override
  String pedidoEnviadoDetalle(String codigo, String total, String estadoPago) {
    return 'Tu pedido $codigo por $total llegó a la tienda.\n\n$estadoPago.';
  }

  @override
  String get pedidoEnviadoTitulo => '¡Pedido enviado!';

  @override
  String pedidoNumero(String codigo) {
    return 'Pedido $codigo';
  }

  @override
  String get pedidosSoloActivos => 'Solo activos';

  @override
  String get perfilDatosGuardados => 'Datos guardados';

  @override
  String get perfilTitulo => 'Mi perfil';

  @override
  String get periodoHoy => 'Hoy';

  @override
  String get periodoMes => 'Este mes';

  @override
  String get periodoSemana => 'Últimos 7 días';

  @override
  String piePieDemo(String tienda) {
    return '$tienda · modo demo';
  }

  @override
  String porLote(String lote) {
    return 'Por $lote';
  }

  @override
  String porPresentacion(String nombre) {
    return 'Por $nombre';
  }

  @override
  String get porUnidad => 'Por unidad';

  @override
  String porUnidadHelper(String unidad) {
    return 'por $unidad';
  }

  @override
  String porUnidadSufijo(String monto) {
    return ' · $monto por unidad';
  }

  @override
  String get precioInvalido => 'Precio inválido';

  @override
  String presentacionDe(String nombre, String cantidad, String unidad) {
    return ' · $nombre de $cantidad $unidad';
  }

  @override
  String get presentacionEjemplo => 'saco';

  @override
  String presentacionesEnStock(String n, String nombre) {
    return '$n $nombre(s)';
  }

  @override
  String produccionRegistrada(String costo) {
    return 'Producción registrada · $costo por unidad';
  }

  @override
  String produccionRegistradaDif(String diferencia, String costo) {
    return 'Registrada · $diferencia vs lo esperado · $costo c/u';
  }

  @override
  String get productoActualizado => 'Producto actualizado';

  @override
  String get productoAgotado => 'Agotado';

  @override
  String get productoAgregado => 'Producto agregado';

  @override
  String get productoBajaSufijo => ' · dado de baja';

  @override
  String productoConStock(String nombre, String stock) {
    return '$nombre · $stock en stock';
  }

  @override
  String productoMargenSufijo(String monto) {
    return ' · gana $monto';
  }

  @override
  String productoPaqueteSufijo(String unidades, String precio) {
    return ' · $unidades x $precio';
  }

  @override
  String productoResumen(
    String precio,
    String unidad,
    String paquete,
    String margen,
    String baja,
  ) {
    return '$precio · $unidad$paquete$margen$baja';
  }

  @override
  String productoYaRegistrado(String nombre, String stock) {
    return '$nombre ya está registrado · stock $stock';
  }

  @override
  String productosSinStock(int n) {
    return '$n producto(s) sin stock';
  }

  @override
  String get productosSinStockDetalle => 'Los clientes no pueden pedirlos.';

  @override
  String get proximamente => 'Próximamente';

  @override
  String qrActualizado(String metodo) {
    return 'QR de $metodo actualizado';
  }

  @override
  String get qrInstrucciones =>
      'Escanea el QR desde tu app, o guarda la imagen si estás pagando desde este mismo celular.';

  @override
  String get qrNoCarga => 'No se pudo cargar el QR';

  @override
  String get qrQuitado => 'QR quitado';

  @override
  String get queVasAGastar => 'Qué vas a gastar';

  @override
  String quedanUnidades(String n) {
    return 'Quedan $n';
  }

  @override
  String get quitar => 'Quitar';

  @override
  String get recetaBoton => 'Receta: qué insumos gasta';

  @override
  String get recetaCorrigelo =>
      'Sale de la receta; corrígelo si esta vez usaste más o menos.';

  @override
  String recetaCuantoSeGasta(String lote) {
    return 'Cuánto se gasta para hacer $lote.';
  }

  @override
  String recetaDe(String producto) {
    return 'Receta de $producto';
  }

  @override
  String get recetaGuardada => 'Receta guardada';

  @override
  String recetaLoteDe(String nombreLote, String unidades, String unidad) {
    return '1 $nombreLote ($unidades $unidad)';
  }

  @override
  String get recetaUnLote => 'un lote';

  @override
  String get registrar => 'Registrar';

  @override
  String get registrarAbono => 'Registrar abono';

  @override
  String get registrarCompra => 'Registrar compra';

  @override
  String get registrarConsumo => 'Registrar consumo';

  @override
  String get registrarMovimiento => 'Registrar movimiento';

  @override
  String get registrarProduccion => 'Registrar producción';

  @override
  String registrarTipo(String tipo) {
    return 'Registrar $tipo';
  }

  @override
  String get reintentar => 'Reintentar';

  @override
  String resumenProductos(int n) {
    return 'Resumen ($n productos)';
  }

  @override
  String rindioMas(String n, String esperado) {
    return 'Rindió $n más de lo esperado ($esperado)';
  }

  @override
  String rindioMenos(String n, String esperado) {
    return 'Rindió $n menos de lo esperado ($esperado)';
  }

  @override
  String get rolCliente => 'Cliente';

  @override
  String get rolTendero => 'Tendero';

  @override
  String saleDeCaja(Object monto) {
    return 'Sale $monto de la caja';
  }

  @override
  String get seCompraPor => 'Se compra por';

  @override
  String get seGastaEn => 'Se gasta en';

  @override
  String seMostrara(String unidades, String total) {
    return 'Se mostrará: $unidades por $total';
  }

  @override
  String get seVendeDeA => 'Se vende de a (opcional)';

  @override
  String get seVendeDeAEjemplo => 'Ej.: 4 panes por un sol → escribe 4';

  @override
  String get segInsumos => 'Insumos';

  @override
  String get segProductos => 'Productos';

  @override
  String get sinAvisoHelper => 'Déjalo vacío si no quieres aviso';

  @override
  String get sinCategoria => 'Sin categoría';

  @override
  String get sinClientes => 'Sin clientes registrados';

  @override
  String get sinClientesDetalle =>
      'Cuando alguien cree su cuenta aparecerá aquí.';

  @override
  String get sinFiadoDetalle => 'Pídele a la tienda que te habilite un cupo.';

  @override
  String get sinFiadoTitulo => 'Sin cuenta de fiado';

  @override
  String get sinInsumosDetalle => 'Agrégalos primero en Inventario → Insumos.';

  @override
  String get sinInsumosTitulo => 'No hay insumos registrados';

  @override
  String get sinInsumosTodavia => 'Sin insumos todavía';

  @override
  String get sinInsumosTodaviaDetalle =>
      'Agrega la harina, la levadura y lo que uses para producir.';

  @override
  String get sinMovimientos => 'Todavía no tienes movimientos.';

  @override
  String get sinMovimientosPeriodo => 'Sin movimientos en este periodo';

  @override
  String get sinMovimientosPeriodoDetalle =>
      'Registra una producción o espera la primera venta.';

  @override
  String get sinMovimientosPunto => 'Sin movimientos.';

  @override
  String get sinPedidosActivos => 'No hay pedidos activos';

  @override
  String get sinPedidosAun => 'Aún no hay pedidos';

  @override
  String get sinPedidosAunDetalle =>
      'Los pedidos nuevos aparecen aquí al instante.';

  @override
  String get sinPedidosDetalle =>
      'Cuando hagas tu primer pedido lo verás aquí.';

  @override
  String get sinPedidosTitulo => 'Todavía no has pedido nada';

  @override
  String get sinQr => 'Todavía no subes tu QR';

  @override
  String get stockHelperExistente =>
      'Para reponer, usa Producción o Compra en Caja';

  @override
  String get stockHelperNuevo => 'Cuánto tienes ahora';

  @override
  String stockInsuficiente(String stock, String sacas) {
    return 'Solo hay $stock en stock y estás sacando $sacas.';
  }

  @override
  String stockInsumoQueda(String antes, String despues, String unidad) {
    return 'Stock: $antes → $despues $unidad';
  }

  @override
  String get stockInvalido => 'Stock inválido';

  @override
  String stockQueda(String antes, String despues, String unidad) {
    return 'Stock: $antes → $despues $unidad';
  }

  @override
  String get subirQr => 'Subir imagen del QR';

  @override
  String get teDebenEnTotal => 'Te deben en total';

  @override
  String get temaAutomatico => 'Según el celular';

  @override
  String get temaClaro => 'Claro';

  @override
  String get temaOscuro => 'Oscuro';

  @override
  String get tiendaExplicacion =>
      'Esto es lo que ve el cliente cuando elige pagar con Yape o Plin. Si no pones número ni QR, el método no se le ofrece.';

  @override
  String get total => 'Total';

  @override
  String get unidadEjemplo => 'und, bolsa, kg...';

  @override
  String get unidadesPorLote => 'Unidades por lote';

  @override
  String get unidadesPorLoteEjemplo => 'Ej.: 30';

  @override
  String get usar => 'Usar';

  @override
  String get vaciar => 'Vaciar';

  @override
  String get validaClave => 'Mínimo 6 caracteres';

  @override
  String get validaCorreo => 'Correo no válido';

  @override
  String get validaEscribeNombre => 'Escribe el nombre';

  @override
  String get validaNombre => 'Escribe tu nombre';

  @override
  String get ventaMostrador => 'Venta en mostrador';

  @override
  String get verCatalogo => 'Ver catálogo';

  @override
  String verificaPago(String total, String metodo, String operacion) {
    return 'Verifica $total por $metodo$operacion';
  }

  @override
  String get visibleEnCatalogo => 'Visible en el catálogo';
}
