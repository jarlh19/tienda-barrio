// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get abono => 'Payment';

  @override
  String get abonoRegistrado => 'Payment recorded';

  @override
  String get agregar => 'Add';

  @override
  String get agregarInsumo => 'Add ingredient';

  @override
  String get agregarSinCodigo => 'Add without a barcode';

  @override
  String get apariencia => 'Appearance';

  @override
  String get avisarmeCuandoBajeDe => 'Warn me when it drops below';

  @override
  String get avisoCarritoVacio => 'Your cart is empty.';

  @override
  String get avisoClienteNoEncontrado => 'Customer not found.';

  @override
  String get avisoConfirmaCorreo => 'Check your email to confirm the account.';

  @override
  String get avisoCredencialesInvalidas => 'Wrong email or password.';

  @override
  String avisoCupoInsuficiente(String disponible, String limite) {
    return 'Your store credit is not enough. Available: $disponible of $limite.';
  }

  @override
  String avisoFaltaCodigoOperacion(String metodo) {
    return 'Enter the operation code from your $metodo.';
  }

  @override
  String get avisoFaltaDireccion => 'Tell us where to deliver the order.';

  @override
  String get avisoIndicaUnidades => 'Enter how many units came out.';

  @override
  String avisoInsumoInsuficiente(
    String insumo,
    String quedan,
    String unidad,
    String necesitas,
  ) {
    return 'Not enough $insumo: $quedan $unidad left and you need $necesitas.';
  }

  @override
  String get avisoInsumoNoExiste => 'That ingredient no longer exists.';

  @override
  String get avisoOperacionFallida => 'The operation could not be completed.';

  @override
  String get avisoPedidoNoExiste => 'That order no longer exists.';

  @override
  String get avisoPerfilNoCreado => 'Your profile has not been created yet.';

  @override
  String get avisoSesionRequerida => 'Sign in to place an order.';

  @override
  String get avisoSinConexion =>
      'Could not reach the store. Check your internet.';

  @override
  String get avisoTarjetaNoHabilitada =>
      'Card payments are not enabled yet. Use Yape, Plin, cash or store credit.';

  @override
  String get cajaEntro => 'In';

  @override
  String cajaMargen(String margen, int unidades) {
    return '$margen% margin · $unidades units sold';
  }

  @override
  String cajaMerma(String monto) {
    return '$monto lost to waste. It does not leave the cash —it was already paid for— but it never comes back.';
  }

  @override
  String get cajaNoCalculada => 'Could not work out the cash';

  @override
  String get cajaQueSeVendio => 'What sold';

  @override
  String get cajaSalio => 'Out';

  @override
  String get cajaTeQueda => 'You keep';

  @override
  String get cajaVasPerdiendo => 'You are losing';

  @override
  String get camaraNoAbre => 'The camera could not be opened.';

  @override
  String get camaraNoSoportada => 'This device cannot scan barcodes.';

  @override
  String get camaraSinPermiso =>
      'The app needs camera permission to read barcodes.';

  @override
  String get cambiar => 'Change';

  @override
  String get cambiarCamara => 'Switch camera';

  @override
  String get cambiarCupo => 'Change limit';

  @override
  String get campoCategoria => 'Category';

  @override
  String get campoCelular => 'Phone';

  @override
  String get campoClave => 'Password';

  @override
  String get campoCorreo => 'Email';

  @override
  String get campoCosto => 'Cost';

  @override
  String get campoDetalle => 'Detail';

  @override
  String get campoDireccion => 'Address';

  @override
  String get campoDireccionEntrega => 'Delivery address';

  @override
  String get campoFotoUrl => 'Photo URL (optional)';

  @override
  String get campoMarca => 'Brand';

  @override
  String get campoMaximo => 'Maximum';

  @override
  String get campoMeCuesta => 'Costs me';

  @override
  String get campoMedida => 'Measure';

  @override
  String get campoMonto => 'Amount';

  @override
  String get campoNombre => 'Name';

  @override
  String get campoNota => 'Note (optional)';

  @override
  String get campoNumero => 'Number';

  @override
  String get campoPesoVolumen => 'Weight or volume';

  @override
  String get campoPrecio => 'Price';

  @override
  String get campoProducto => 'Product';

  @override
  String get campoStock => 'Stock';

  @override
  String get campoTengoAhora => 'I have now';

  @override
  String get campoTrae => 'Contains';

  @override
  String get campoTraeEjemplo => 'E.g. 50';

  @override
  String get campoUnidad => 'Unit';

  @override
  String get cancelar => 'Cancel';

  @override
  String get cantidadInvalida => 'Invalid amount';

  @override
  String get cantidadUnidades => 'Number of units';

  @override
  String get cargo => 'Charge';

  @override
  String get carritoTitulo => 'My order';

  @override
  String get carritoVaciado => 'Cart emptied';

  @override
  String get carritoVacioDetalle =>
      'Add products from the catalog to place your order.';

  @override
  String get carritoVacioTitulo => 'Your cart is empty';

  @override
  String get catalogoBuscar => 'What do you need today?';

  @override
  String get catalogoSinResultados => 'No results';

  @override
  String get catalogoSinResultadosDetalle =>
      'Try another name or pick a different category.';

  @override
  String get cerrarSesion => 'Sign out';

  @override
  String get checkoutEntrega => 'Delivery';

  @override
  String get checkoutFormaPago => 'Payment method';

  @override
  String get checkoutNota => 'Note for the store (optional)';

  @override
  String get checkoutNotaEjemplo => 'E.g. ring the bell twice';

  @override
  String clientesConSaldo(int n) {
    return '$n customer(s) with an open balance';
  }

  @override
  String get codigoBarrasVacio => 'Leave it empty if it is sold loose';

  @override
  String get codigoOperacion => 'Operation code';

  @override
  String get codigoOperacionEjemplo => 'E.g. 00123456';

  @override
  String codigoYaEsDe(String nombre) {
    return 'That barcode already belongs to \"$nombre\".';
  }

  @override
  String get comoMePagan => 'How I get paid';

  @override
  String get comoMePaganDetalle => 'Yape / Plin number and QR code';

  @override
  String get compraRegistrada => 'Purchase recorded';

  @override
  String comprarInsumo(String insumo) {
    return 'Buy $insumo';
  }

  @override
  String confirmarPedido(String total) {
    return 'Place order · $total';
  }

  @override
  String get consumoRegistrado => 'Charge recorded';

  @override
  String get continuarPago => 'Continue to payment';

  @override
  String get copiado => 'Copied';

  @override
  String get copiar => 'Copy';

  @override
  String get copiarFallo =>
      'Could not copy. Press and hold the number to select it.';

  @override
  String get costoDelLote => 'Batch cost';

  @override
  String get costoHelper => 'What it costs you';

  @override
  String costoInsumos(String total, String porUnidad) {
    return 'Ingredient cost $total$porUnidad';
  }

  @override
  String get costoInvalido => 'Invalid cost';

  @override
  String costoLoteDetalle(String total, String unitario) {
    return 'Batch cost $total · $unitario per unit';
  }

  @override
  String costoPorUnidad(String monto, String unidad) {
    return '$monto per $unidad';
  }

  @override
  String costoPorUnidadInsumo(
    String costo,
    String unidad,
    String presentacion,
  ) {
    return '$costo per $unidad$presentacion';
  }

  @override
  String costoUnitarioPasaDe(String unidad, String antes, String despues) {
    return 'The $unidad goes from $antes to $despues';
  }

  @override
  String cuantasPresentaciones(String nombre) {
    return 'How many ${nombre}s?';
  }

  @override
  String cuantasUnidades(String unidad) {
    return 'How many $unidad?';
  }

  @override
  String get cuantoPagasteTotal => 'How much you paid in total';

  @override
  String cuantosLotes(String lote) {
    return 'How many ${lote}s?';
  }

  @override
  String get cupoActualizado => 'Limit updated';

  @override
  String get cupoDeFiado => 'Credit limit';

  @override
  String cupoYDisponible(String limite, String disponible) {
    return 'Limit $limite · $disponible available';
  }

  @override
  String get darDeBaja => 'Retire';

  @override
  String get darDeBajaDetalle =>
      'The product stops showing in the catalog, but stays on past orders.';

  @override
  String get darDeBajaPregunta => 'Retire it?';

  @override
  String get detalleAbonoEjemplo => 'Paid in cash';

  @override
  String get detalleCargoEjemplo => 'Today\'s purchase';

  @override
  String get editarInsumo => 'Edit ingredient';

  @override
  String get editarProducto => 'Edit product';

  @override
  String get eligeProducto => 'Pick the product';

  @override
  String get enStock => 'in stock';

  @override
  String get entendido => 'Got it';

  @override
  String entraACaja(Object monto) {
    return '$monto comes into the cash';
  }

  @override
  String get errorDetalle => 'Check your connection and try again.';

  @override
  String get errorGenerico => 'Something went wrong. Try again.';

  @override
  String get escanear => 'Scan';

  @override
  String get escanearAMano => 'Type it by hand';

  @override
  String get escanearCodigoBarras => 'Barcode';

  @override
  String get escanearEscribirCodigo => 'Type the code';

  @override
  String get escanearInstruccion => 'Point at the barcode on the package';

  @override
  String get escanearTitulo => 'Scan product';

  @override
  String get estadoPagoFallido => 'Payment rejected';

  @override
  String get estadoPagoFiado => 'On credit';

  @override
  String get estadoPagoPagado => 'Paid';

  @override
  String get estadoPagoPendiente => 'Unpaid';

  @override
  String get estadoPagoVerificando => 'Checking payment';

  @override
  String get estadoPedidoCancelado => 'Cancelled';

  @override
  String get estadoPedidoConfirmado => 'Confirmed';

  @override
  String get estadoPedidoEntregado => 'Delivered';

  @override
  String get estadoPedidoListo => 'Ready for delivery';

  @override
  String get estadoPedidoPendiente => 'Pending';

  @override
  String get estadoPedidoPreparando => 'Preparing';

  @override
  String get fiadoAbono => 'Payment';

  @override
  String get fiadoConsumo => 'Charge';

  @override
  String fiadoCupoDisponible(String disponible, String limite) {
    return '$disponible available of $limite';
  }

  @override
  String get fiadoDebes => 'You owe';

  @override
  String fiadoDisponibleDe(String disponible, String limite) {
    return '$disponible available of $limite';
  }

  @override
  String fiadoNoAlcanza(String texto) {
    return '$texto — not enough for this order';
  }

  @override
  String get filtroTodo => 'All';

  @override
  String gananciaEstimada(String monto) {
    return 'Estimated profit $monto';
  }

  @override
  String get guardar => 'Save';

  @override
  String get guardarCambios => 'Save changes';

  @override
  String get guardarNumeros => 'Save numbers';

  @override
  String get guardarReceta => 'Save recipe';

  @override
  String get haceAhora => 'just now';

  @override
  String get haceAyer => 'yesterday';

  @override
  String haceDias(int n) {
    return '$n days ago';
  }

  @override
  String haceHoras(int n) {
    return '$n h ago';
  }

  @override
  String haceMinutos(int n) {
    return '$n min ago';
  }

  @override
  String get idioma => 'Language';

  @override
  String get idiomaAutomatico => 'Match the phone';

  @override
  String get idiomaEspanol => 'Spanish';

  @override
  String get idiomaIngles => 'English';

  @override
  String igualAInventario(String unidades, String unidad) {
    return '= $unidades $unidad in inventory';
  }

  @override
  String igualAUnidadBase(String cantidad, String unidad) {
    return '= $cantidad $unidad';
  }

  @override
  String get indicaCantidad => 'Enter the quantity';

  @override
  String get indicaCuantoEntro => 'Enter how much came in';

  @override
  String get insumoActualizado => 'Ingredient updated';

  @override
  String get insumoAgregado => 'Ingredient added';

  @override
  String get insumoNombreEjemplo => 'Flour';

  @override
  String insumosPorAcabarse(int n) {
    return '$n ingredient(s) running out';
  }

  @override
  String get inventarioVacio => 'Empty inventory';

  @override
  String get inventarioVacioDetalle =>
      'Add your first product with the button below.';

  @override
  String get linterna => 'Torch';

  @override
  String get loginCrearCuenta => 'Create account';

  @override
  String get loginDemo => 'Demo mode — get in without signing up';

  @override
  String get loginEntrar => 'Sign in';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginGoogleDetalle =>
      'Use the account already on your phone. Nothing to fill in.';

  @override
  String get loginLema => 'Order what you always do, without leaving home';

  @override
  String get loginNoTengoCuenta => 'I don\'t have an account, sign me up';

  @override
  String get loginOCorreo => 'or with your email';

  @override
  String get loginPrefieroCorreo => 'I\'d rather use my email';

  @override
  String get loginYaTengoCuenta => 'I already have an account';

  @override
  String get marcaEjemplo => 'Gloria, Costeño, Primor...';

  @override
  String marcarComo(String estado) {
    return 'Mark as $estado';
  }

  @override
  String get metodoNoConfigurado => 'The store has not set this up yet';

  @override
  String get metodoPagoEfectivo => 'Cash on delivery';

  @override
  String get metodoPagoFiado => 'Store credit';

  @override
  String get metodoPagoPlin => 'Plin';

  @override
  String get metodoPagoTarjeta => 'Card (gateway)';

  @override
  String get metodoPagoYape => 'Yape';

  @override
  String get miCuentaTitulo => 'My account';

  @override
  String get misPedidosTitulo => 'My orders';

  @override
  String get modoDemoBanner =>
      'Demo mode: the data is sample data and is not saved.';

  @override
  String get montoCalculado => 'Worked out from the product; you can change it';

  @override
  String get montoCosto => 'How much it cost you';

  @override
  String get montoEscrito => 'You typed this';

  @override
  String get montoInvalido => 'Invalid amount';

  @override
  String get montoMerma => 'How much you lost';

  @override
  String get montoVenta => 'How much you charged';

  @override
  String get movInsumoAjuste => 'Adjustment';

  @override
  String get movInsumoCompra => 'Purchase';

  @override
  String get movInsumoConsumo => 'Usage';

  @override
  String get movInsumoMerma => 'Waste';

  @override
  String get movInvAjuste => 'Adjustment';

  @override
  String get movInvCompra => 'Purchase';

  @override
  String get movInvDevolucion => 'Return';

  @override
  String get movInvMerma => 'Waste';

  @override
  String get movInvProduccion => 'Production';

  @override
  String get movInvVenta => 'Sale';

  @override
  String movLotes(String n) {
    return ' · $n batch(es)';
  }

  @override
  String movPresentaciones(String n) {
    return ' · $n package(s)';
  }

  @override
  String movUnidades(String n) {
    return '$n units';
  }

  @override
  String movimientoRegistrado(String tipo) {
    return '$tipo recorded';
  }

  @override
  String get movimientos => 'Activity';

  @override
  String get navCaja => 'Cash';

  @override
  String get navFiado => 'Credit';

  @override
  String get navInventario => 'Inventory';

  @override
  String get navPedidos => 'Orders';

  @override
  String get navPerfil => 'Profile';

  @override
  String get navTienda => 'Store';

  @override
  String get no => 'No';

  @override
  String get noSePudoCargar => 'Could not load';

  @override
  String get nombreDelLote => 'Batch name';

  @override
  String get nombreDelLoteEjemplo => 'tray';

  @override
  String get notaEjemplo => 'Morning bake';

  @override
  String get nuevoInsumo => 'New ingredient';

  @override
  String get nuevoProducto => 'New product';

  @override
  String numeroCopiado(String metodo) {
    return 'Number copied. Paste it into $metodo.';
  }

  @override
  String operacionNumero(String referencia) {
    return 'Operation $referencia';
  }

  @override
  String operacionSufijo(String referencia) {
    return ' · op. $referencia';
  }

  @override
  String pagaConMetodo(String total, String metodo) {
    return 'Pay $total with $metodo';
  }

  @override
  String get pagarTitulo => 'Checkout';

  @override
  String get pagoNoLlego => 'Never arrived';

  @override
  String get pagoRecibido => 'Payment received';

  @override
  String pedidoEnviadoDetalle(String codigo, String total, String estadoPago) {
    return 'Your order $codigo for $total reached the store.\n\n$estadoPago.';
  }

  @override
  String get pedidoEnviadoTitulo => 'Order sent!';

  @override
  String pedidoNumero(String codigo) {
    return 'Order $codigo';
  }

  @override
  String get pedidosSoloActivos => 'Active only';

  @override
  String get perfilDatosGuardados => 'Details saved';

  @override
  String get perfilTitulo => 'My profile';

  @override
  String get periodoHoy => 'Today';

  @override
  String get periodoMes => 'This month';

  @override
  String get periodoSemana => 'Last 7 days';

  @override
  String piePieDemo(String tienda) {
    return '$tienda · demo mode';
  }

  @override
  String porLote(String lote) {
    return 'By $lote';
  }

  @override
  String porPresentacion(String nombre) {
    return 'By $nombre';
  }

  @override
  String get porUnidad => 'By unit';

  @override
  String porUnidadHelper(String unidad) {
    return 'per $unidad';
  }

  @override
  String porUnidadSufijo(String monto) {
    return ' · $monto per unit';
  }

  @override
  String get precioInvalido => 'Invalid price';

  @override
  String presentacionDe(String nombre, String cantidad, String unidad) {
    return ' · $nombre of $cantidad $unidad';
  }

  @override
  String get presentacionEjemplo => 'sack';

  @override
  String presentacionesEnStock(String n, String nombre) {
    return '$n $nombre(s)';
  }

  @override
  String produccionRegistrada(String costo) {
    return 'Production recorded · $costo per unit';
  }

  @override
  String produccionRegistradaDif(String diferencia, String costo) {
    return 'Recorded · $diferencia vs expected · $costo each';
  }

  @override
  String get productoActualizado => 'Product updated';

  @override
  String get productoAgotado => 'Out of stock';

  @override
  String get productoAgregado => 'Product added';

  @override
  String get productoBajaSufijo => ' · retired';

  @override
  String productoConStock(String nombre, String stock) {
    return '$nombre · $stock in stock';
  }

  @override
  String productoMargenSufijo(String monto) {
    return ' · earns $monto';
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
    return '$nombre is already registered · stock $stock';
  }

  @override
  String productosSinStock(int n) {
    return '$n product(s) out of stock';
  }

  @override
  String get productosSinStockDetalle => 'Customers cannot order them.';

  @override
  String get proximamente => 'Coming soon';

  @override
  String qrActualizado(String metodo) {
    return '$metodo QR code updated';
  }

  @override
  String get qrInstrucciones =>
      'Scan the QR code from your app, or save the image if you are paying from this same phone.';

  @override
  String get qrNoCarga => 'The QR code could not be loaded';

  @override
  String get qrQuitado => 'QR code removed';

  @override
  String get queVasAGastar => 'What you will use';

  @override
  String quedanUnidades(String n) {
    return '$n left';
  }

  @override
  String get quitar => 'Remove';

  @override
  String get recetaBoton => 'Recipe: which ingredients it uses';

  @override
  String get recetaCorrigelo =>
      'Taken from the recipe; change it if this time you used more or less.';

  @override
  String recetaCuantoSeGasta(String lote) {
    return 'How much it takes to make $lote.';
  }

  @override
  String recetaDe(String producto) {
    return 'Recipe for $producto';
  }

  @override
  String get recetaGuardada => 'Recipe saved';

  @override
  String recetaLoteDe(String nombreLote, String unidades, String unidad) {
    return '1 $nombreLote ($unidades $unidad)';
  }

  @override
  String get recetaUnLote => 'one batch';

  @override
  String get registrar => 'Record';

  @override
  String get registrarAbono => 'Record a payment';

  @override
  String get registrarCompra => 'Record a purchase';

  @override
  String get registrarConsumo => 'Record a charge';

  @override
  String get registrarMovimiento => 'Record a movement';

  @override
  String get registrarProduccion => 'Record production';

  @override
  String registrarTipo(String tipo) {
    return 'Record $tipo';
  }

  @override
  String get reintentar => 'Try again';

  @override
  String resumenProductos(int n) {
    return 'Summary ($n products)';
  }

  @override
  String rindioMas(String n, String esperado) {
    return 'Yielded $n more than expected ($esperado)';
  }

  @override
  String rindioMenos(String n, String esperado) {
    return 'Yielded $n fewer than expected ($esperado)';
  }

  @override
  String get rolCliente => 'Customer';

  @override
  String get rolTendero => 'Shopkeeper';

  @override
  String saleDeCaja(Object monto) {
    return '$monto leaves the cash';
  }

  @override
  String get seCompraPor => 'Bought by';

  @override
  String get seGastaEn => 'Used in';

  @override
  String seMostrara(String unidades, String total) {
    return 'Will show as: $unidades for $total';
  }

  @override
  String get seVendeDeA => 'Sold in packs of (optional)';

  @override
  String get seVendeDeAEjemplo => 'E.g. 4 rolls for one sol → type 4';

  @override
  String get segInsumos => 'Ingredients';

  @override
  String get segProductos => 'Products';

  @override
  String get sinAvisoHelper => 'Leave it empty for no warning';

  @override
  String get sinCategoria => 'No category';

  @override
  String get sinClientes => 'No customers yet';

  @override
  String get sinClientesDetalle =>
      'They will show up here once someone signs up.';

  @override
  String get sinFiadoDetalle => 'Ask the store to set you a credit limit.';

  @override
  String get sinFiadoTitulo => 'No store credit yet';

  @override
  String get sinInsumosDetalle => 'Add them first in Inventory → Ingredients.';

  @override
  String get sinInsumosTitulo => 'No ingredients registered';

  @override
  String get sinInsumosTodavia => 'No ingredients yet';

  @override
  String get sinInsumosTodaviaDetalle =>
      'Add the flour, the yeast and whatever else you produce with.';

  @override
  String get sinMovimientos => 'No activity yet.';

  @override
  String get sinMovimientosPeriodo => 'No activity in this period';

  @override
  String get sinMovimientosPeriodoDetalle =>
      'Record a production run or wait for the first sale.';

  @override
  String get sinMovimientosPunto => 'No activity.';

  @override
  String get sinPedidosActivos => 'No active orders';

  @override
  String get sinPedidosAun => 'No orders yet';

  @override
  String get sinPedidosAunDetalle => 'New orders show up here instantly.';

  @override
  String get sinPedidosDetalle => 'Your first order will show up here.';

  @override
  String get sinPedidosTitulo => 'You haven\'t ordered anything yet';

  @override
  String get sinQr => 'You have not uploaded your QR code yet';

  @override
  String get stockHelperExistente =>
      'To restock, use Production or Purchase in Cash';

  @override
  String get stockHelperNuevo => 'How much you have now';

  @override
  String stockInsuficiente(String stock, String sacas) {
    return 'Only $stock in stock and you are taking out $sacas.';
  }

  @override
  String stockInsumoQueda(String antes, String despues, String unidad) {
    return 'Stock: $antes → $despues $unidad';
  }

  @override
  String get stockInvalido => 'Invalid stock';

  @override
  String stockQueda(String antes, String despues, String unidad) {
    return 'Stock: $antes → $despues $unidad';
  }

  @override
  String get subirQr => 'Upload QR image';

  @override
  String get teDebenEnTotal => 'Owed to you in total';

  @override
  String get temaAutomatico => 'Match the phone';

  @override
  String get temaClaro => 'Light';

  @override
  String get temaOscuro => 'Dark';

  @override
  String get tiendaExplicacion =>
      'This is what the customer sees when they choose Yape or Plin. Without a number or a QR code, the method is not offered.';

  @override
  String get total => 'Total';

  @override
  String get unidadEjemplo => 'unit, bag, kg...';

  @override
  String get unidadesPorLote => 'Units per batch';

  @override
  String get unidadesPorLoteEjemplo => 'E.g. 30';

  @override
  String get usar => 'Use';

  @override
  String get vaciar => 'Empty';

  @override
  String get validaClave => 'At least 6 characters';

  @override
  String get validaCorreo => 'Invalid email';

  @override
  String get validaEscribeNombre => 'Enter the name';

  @override
  String get validaNombre => 'Enter your name';

  @override
  String get ventaMostrador => 'Counter sale';

  @override
  String get verCatalogo => 'Browse the catalog';

  @override
  String verificaPago(String total, String metodo, String operacion) {
    return 'Check $total via $metodo$operacion';
  }

  @override
  String get visibleEnCatalogo => 'Visible in the catalog';
}
