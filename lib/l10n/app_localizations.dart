import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @abono.
  ///
  /// In es, this message translates to:
  /// **'Abono'**
  String get abono;

  /// No description provided for @abonoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Abono registrado'**
  String get abonoRegistrado;

  /// No description provided for @agregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get agregar;

  /// No description provided for @agregarInsumo.
  ///
  /// In es, this message translates to:
  /// **'Agregar insumo'**
  String get agregarInsumo;

  /// No description provided for @agregarSinCodigo.
  ///
  /// In es, this message translates to:
  /// **'Agregar sin código'**
  String get agregarSinCodigo;

  /// No description provided for @apariencia.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get apariencia;

  /// No description provided for @avisarmeCuandoBajeDe.
  ///
  /// In es, this message translates to:
  /// **'Avisarme cuando baje de'**
  String get avisarmeCuandoBajeDe;

  /// No description provided for @avisoCarritoVacio.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío.'**
  String get avisoCarritoVacio;

  /// No description provided for @avisoClienteNoEncontrado.
  ///
  /// In es, this message translates to:
  /// **'Cliente no encontrado.'**
  String get avisoClienteNoEncontrado;

  /// No description provided for @avisoConfirmaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo para confirmar la cuenta.'**
  String get avisoConfirmaCorreo;

  /// No description provided for @avisoCredencialesInvalidas.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get avisoCredencialesInvalidas;

  /// No description provided for @avisoCupoInsuficiente.
  ///
  /// In es, this message translates to:
  /// **'Tu cupo de fiado no alcanza. Disponible: {disponible} de {limite}.'**
  String avisoCupoInsuficiente(String disponible, String limite);

  /// No description provided for @avisoFaltaCodigoOperacion.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de operación de tu {metodo}.'**
  String avisoFaltaCodigoOperacion(String metodo);

  /// No description provided for @avisoFaltaDireccion.
  ///
  /// In es, this message translates to:
  /// **'Indica a qué dirección llevamos el pedido.'**
  String get avisoFaltaDireccion;

  /// No description provided for @avisoIndicaUnidades.
  ///
  /// In es, this message translates to:
  /// **'Indica cuántas unidades salieron.'**
  String get avisoIndicaUnidades;

  /// No description provided for @avisoInsumoInsuficiente.
  ///
  /// In es, this message translates to:
  /// **'No alcanza {insumo}: quedan {quedan} {unidad} y necesitas {necesitas}.'**
  String avisoInsumoInsuficiente(
    String insumo,
    String quedan,
    String unidad,
    String necesitas,
  );

  /// No description provided for @avisoInsumoNoExiste.
  ///
  /// In es, this message translates to:
  /// **'Ese insumo ya no existe.'**
  String get avisoInsumoNoExiste;

  /// No description provided for @avisoOperacionFallida.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar la operación.'**
  String get avisoOperacionFallida;

  /// No description provided for @avisoPedidoNoExiste.
  ///
  /// In es, this message translates to:
  /// **'El pedido ya no existe.'**
  String get avisoPedidoNoExiste;

  /// No description provided for @avisoPerfilNoCreado.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil aún no está creado.'**
  String get avisoPerfilNoCreado;

  /// No description provided for @avisoSesionRequerida.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para pedir.'**
  String get avisoSesionRequerida;

  /// No description provided for @avisoSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar con la tienda. Revisa tu internet.'**
  String get avisoSinConexion;

  /// No description provided for @avisoTarjetaNoHabilitada.
  ///
  /// In es, this message translates to:
  /// **'El pago con tarjeta aún no está habilitado. Usa Yape, Plin, efectivo o fiado.'**
  String get avisoTarjetaNoHabilitada;

  /// No description provided for @cajaEntro.
  ///
  /// In es, this message translates to:
  /// **'Entró'**
  String get cajaEntro;

  /// No description provided for @cajaMargen.
  ///
  /// In es, this message translates to:
  /// **'Margen {margen}% · {unidades} unidades vendidas'**
  String cajaMargen(String margen, int unidades);

  /// No description provided for @cajaMerma.
  ///
  /// In es, this message translates to:
  /// **'Se perdió {monto} en merma. No sale de la caja —ya estaba pagado— pero no vuelve.'**
  String cajaMerma(String monto);

  /// No description provided for @cajaNoCalculada.
  ///
  /// In es, this message translates to:
  /// **'No se pudo calcular la caja'**
  String get cajaNoCalculada;

  /// No description provided for @cajaQueSeVendio.
  ///
  /// In es, this message translates to:
  /// **'Qué se vendió'**
  String get cajaQueSeVendio;

  /// No description provided for @cajaSalio.
  ///
  /// In es, this message translates to:
  /// **'Salió'**
  String get cajaSalio;

  /// No description provided for @cajaTeQueda.
  ///
  /// In es, this message translates to:
  /// **'Te queda'**
  String get cajaTeQueda;

  /// No description provided for @cajaVasPerdiendo.
  ///
  /// In es, this message translates to:
  /// **'Vas perdiendo'**
  String get cajaVasPerdiendo;

  /// No description provided for @camaraNoAbre.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir la cámara.'**
  String get camaraNoAbre;

  /// No description provided for @camaraNoSoportada.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no puede escanear códigos.'**
  String get camaraNoSoportada;

  /// No description provided for @camaraSinPermiso.
  ///
  /// In es, this message translates to:
  /// **'La app necesita permiso de cámara para leer códigos.'**
  String get camaraSinPermiso;

  /// No description provided for @cambiar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get cambiar;

  /// No description provided for @cambiarCamara.
  ///
  /// In es, this message translates to:
  /// **'Cambiar cámara'**
  String get cambiarCamara;

  /// No description provided for @cambiarCupo.
  ///
  /// In es, this message translates to:
  /// **'Cambiar cupo'**
  String get cambiarCupo;

  /// No description provided for @campoCategoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get campoCategoria;

  /// No description provided for @campoCelular.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get campoCelular;

  /// No description provided for @campoClave.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get campoClave;

  /// No description provided for @campoCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get campoCorreo;

  /// No description provided for @campoCosto.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get campoCosto;

  /// No description provided for @campoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get campoDetalle;

  /// No description provided for @campoDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get campoDireccion;

  /// No description provided for @campoDireccionEntrega.
  ///
  /// In es, this message translates to:
  /// **'Dirección de entrega'**
  String get campoDireccionEntrega;

  /// No description provided for @campoFotoUrl.
  ///
  /// In es, this message translates to:
  /// **'URL de la foto (opcional)'**
  String get campoFotoUrl;

  /// No description provided for @campoMarca.
  ///
  /// In es, this message translates to:
  /// **'Marca'**
  String get campoMarca;

  /// No description provided for @campoMaximo.
  ///
  /// In es, this message translates to:
  /// **'Máximo'**
  String get campoMaximo;

  /// No description provided for @campoMeCuesta.
  ///
  /// In es, this message translates to:
  /// **'Me cuesta'**
  String get campoMeCuesta;

  /// No description provided for @campoMedida.
  ///
  /// In es, this message translates to:
  /// **'Medida'**
  String get campoMedida;

  /// No description provided for @campoMonto.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get campoMonto;

  /// No description provided for @campoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get campoNombre;

  /// No description provided for @campoNota.
  ///
  /// In es, this message translates to:
  /// **'Nota (opcional)'**
  String get campoNota;

  /// No description provided for @campoNumero.
  ///
  /// In es, this message translates to:
  /// **'Número'**
  String get campoNumero;

  /// No description provided for @campoPesoVolumen.
  ///
  /// In es, this message translates to:
  /// **'Peso o volumen'**
  String get campoPesoVolumen;

  /// No description provided for @campoPrecio.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get campoPrecio;

  /// No description provided for @campoProducto.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get campoProducto;

  /// No description provided for @campoStock.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get campoStock;

  /// No description provided for @campoTengoAhora.
  ///
  /// In es, this message translates to:
  /// **'Tengo ahora'**
  String get campoTengoAhora;

  /// No description provided for @campoTrae.
  ///
  /// In es, this message translates to:
  /// **'Trae'**
  String get campoTrae;

  /// No description provided for @campoTraeEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 50'**
  String get campoTraeEjemplo;

  /// No description provided for @campoUnidad.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get campoUnidad;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @cantidadInvalida.
  ///
  /// In es, this message translates to:
  /// **'Cantidad inválida'**
  String get cantidadInvalida;

  /// No description provided for @cantidadUnidades.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de unidades'**
  String get cantidadUnidades;

  /// No description provided for @cargo.
  ///
  /// In es, this message translates to:
  /// **'Cargo'**
  String get cargo;

  /// No description provided for @carritoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi pedido'**
  String get carritoTitulo;

  /// No description provided for @carritoVaciado.
  ///
  /// In es, this message translates to:
  /// **'Carrito vaciado'**
  String get carritoVaciado;

  /// No description provided for @carritoVacioDetalle.
  ///
  /// In es, this message translates to:
  /// **'Agrega productos del catálogo para hacer tu pedido.'**
  String get carritoVacioDetalle;

  /// No description provided for @carritoVacioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu carrito está vacío'**
  String get carritoVacioTitulo;

  /// No description provided for @catalogoBuscar.
  ///
  /// In es, this message translates to:
  /// **'¿Qué necesitas hoy?'**
  String get catalogoBuscar;

  /// No description provided for @catalogoSinResultados.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get catalogoSinResultados;

  /// No description provided for @catalogoSinResultadosDetalle.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre o cambia de categoría.'**
  String get catalogoSinResultadosDetalle;

  /// No description provided for @cerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cerrarSesion;

  /// No description provided for @checkoutEntrega.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get checkoutEntrega;

  /// No description provided for @checkoutFormaPago.
  ///
  /// In es, this message translates to:
  /// **'Forma de pago'**
  String get checkoutFormaPago;

  /// No description provided for @checkoutNota.
  ///
  /// In es, this message translates to:
  /// **'Nota para la tienda (opcional)'**
  String get checkoutNota;

  /// No description provided for @checkoutNotaEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: tocar el timbre 2 veces'**
  String get checkoutNotaEjemplo;

  /// No description provided for @clientesConSaldo.
  ///
  /// In es, this message translates to:
  /// **'{n} cliente(s) con saldo pendiente'**
  String clientesConSaldo(int n);

  /// No description provided for @codigoBarrasVacio.
  ///
  /// In es, this message translates to:
  /// **'Déjalo vacío si se vende suelto'**
  String get codigoBarrasVacio;

  /// No description provided for @codigoOperacion.
  ///
  /// In es, this message translates to:
  /// **'Código de operación'**
  String get codigoOperacion;

  /// No description provided for @codigoOperacionEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 00123456'**
  String get codigoOperacionEjemplo;

  /// No description provided for @codigoYaEsDe.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya es de \"{nombre}\".'**
  String codigoYaEsDe(String nombre);

  /// No description provided for @comoMePagan.
  ///
  /// In es, this message translates to:
  /// **'Cómo me pagan'**
  String get comoMePagan;

  /// No description provided for @comoMePaganDetalle.
  ///
  /// In es, this message translates to:
  /// **'Número y QR de Yape / Plin'**
  String get comoMePaganDetalle;

  /// No description provided for @compraRegistrada.
  ///
  /// In es, this message translates to:
  /// **'Compra registrada'**
  String get compraRegistrada;

  /// No description provided for @comprarInsumo.
  ///
  /// In es, this message translates to:
  /// **'Comprar {insumo}'**
  String comprarInsumo(String insumo);

  /// No description provided for @confirmarPedido.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pedido · {total}'**
  String confirmarPedido(String total);

  /// No description provided for @consumoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'Consumo registrado'**
  String get consumoRegistrado;

  /// No description provided for @continuarPago.
  ///
  /// In es, this message translates to:
  /// **'Continuar con el pago'**
  String get continuarPago;

  /// No description provided for @copiado.
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get copiado;

  /// No description provided for @copiar.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copiar;

  /// No description provided for @copiarFallo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo copiar. Mantén presionado el número para seleccionarlo.'**
  String get copiarFallo;

  /// No description provided for @costoDelLote.
  ///
  /// In es, this message translates to:
  /// **'Costo del lote'**
  String get costoDelLote;

  /// No description provided for @costoHelper.
  ///
  /// In es, this message translates to:
  /// **'Lo que te cuesta'**
  String get costoHelper;

  /// No description provided for @costoInsumos.
  ///
  /// In es, this message translates to:
  /// **'Costo de los insumos {total}{porUnidad}'**
  String costoInsumos(String total, String porUnidad);

  /// No description provided for @costoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Costo inválido'**
  String get costoInvalido;

  /// No description provided for @costoLoteDetalle.
  ///
  /// In es, this message translates to:
  /// **'Costo del lote {total} · {unitario} por unidad'**
  String costoLoteDetalle(String total, String unitario);

  /// No description provided for @costoPorUnidad.
  ///
  /// In es, this message translates to:
  /// **'{monto} por {unidad}'**
  String costoPorUnidad(String monto, String unidad);

  /// No description provided for @costoPorUnidadInsumo.
  ///
  /// In es, this message translates to:
  /// **'{costo} por {unidad}{presentacion}'**
  String costoPorUnidadInsumo(String costo, String unidad, String presentacion);

  /// No description provided for @costoUnitarioPasaDe.
  ///
  /// In es, this message translates to:
  /// **'El {unidad} pasa de {antes} a {despues}'**
  String costoUnitarioPasaDe(String unidad, String antes, String despues);

  /// No description provided for @cuantasPresentaciones.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántos {nombre}s?'**
  String cuantasPresentaciones(String nombre);

  /// No description provided for @cuantasUnidades.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántos {unidad}?'**
  String cuantasUnidades(String unidad);

  /// No description provided for @cuantoPagasteTotal.
  ///
  /// In es, this message translates to:
  /// **'Cuánto pagaste en total'**
  String get cuantoPagasteTotal;

  /// No description provided for @cuantosLotes.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántas {lote}s?'**
  String cuantosLotes(String lote);

  /// No description provided for @cupoActualizado.
  ///
  /// In es, this message translates to:
  /// **'Cupo actualizado'**
  String get cupoActualizado;

  /// No description provided for @cupoDeFiado.
  ///
  /// In es, this message translates to:
  /// **'Cupo de fiado'**
  String get cupoDeFiado;

  /// No description provided for @cupoYDisponible.
  ///
  /// In es, this message translates to:
  /// **'Cupo {limite} · disponible {disponible}'**
  String cupoYDisponible(String limite, String disponible);

  /// No description provided for @darDeBaja.
  ///
  /// In es, this message translates to:
  /// **'Dar de baja'**
  String get darDeBaja;

  /// No description provided for @darDeBajaDetalle.
  ///
  /// In es, this message translates to:
  /// **'El producto deja de aparecer en el catálogo, pero se mantiene en los pedidos anteriores.'**
  String get darDeBajaDetalle;

  /// No description provided for @darDeBajaPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿Dar de baja?'**
  String get darDeBajaPregunta;

  /// No description provided for @detalleAbonoEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Pagó en efectivo'**
  String get detalleAbonoEjemplo;

  /// No description provided for @detalleCargoEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Compra del día'**
  String get detalleCargoEjemplo;

  /// No description provided for @editarInsumo.
  ///
  /// In es, this message translates to:
  /// **'Editar insumo'**
  String get editarInsumo;

  /// No description provided for @editarProducto.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get editarProducto;

  /// No description provided for @eligeProducto.
  ///
  /// In es, this message translates to:
  /// **'Elige el producto'**
  String get eligeProducto;

  /// No description provided for @enStock.
  ///
  /// In es, this message translates to:
  /// **'en stock'**
  String get enStock;

  /// No description provided for @entendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// No description provided for @entraACaja.
  ///
  /// In es, this message translates to:
  /// **'Entra {monto} a la caja'**
  String entraACaja(Object monto);

  /// No description provided for @errorDetalle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo otra vez.'**
  String get errorDetalle;

  /// No description provided for @errorGenerico.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo otra vez.'**
  String get errorGenerico;

  /// No description provided for @escanear.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get escanear;

  /// No description provided for @escanearAMano.
  ///
  /// In es, this message translates to:
  /// **'Escribirlo a mano'**
  String get escanearAMano;

  /// No description provided for @escanearCodigoBarras.
  ///
  /// In es, this message translates to:
  /// **'Código de barras'**
  String get escanearCodigoBarras;

  /// No description provided for @escanearEscribirCodigo.
  ///
  /// In es, this message translates to:
  /// **'Escribir el código'**
  String get escanearEscribirCodigo;

  /// No description provided for @escanearInstruccion.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras del envase'**
  String get escanearInstruccion;

  /// No description provided for @escanearTitulo.
  ///
  /// In es, this message translates to:
  /// **'Escanear producto'**
  String get escanearTitulo;

  /// No description provided for @estadoPagoFallido.
  ///
  /// In es, this message translates to:
  /// **'Pago rechazado'**
  String get estadoPagoFallido;

  /// No description provided for @estadoPagoFiado.
  ///
  /// In es, this message translates to:
  /// **'Al fiado'**
  String get estadoPagoFiado;

  /// No description provided for @estadoPagoPagado.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get estadoPagoPagado;

  /// No description provided for @estadoPagoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Por pagar'**
  String get estadoPagoPendiente;

  /// No description provided for @estadoPagoVerificando.
  ///
  /// In es, this message translates to:
  /// **'Verificando pago'**
  String get estadoPagoVerificando;

  /// No description provided for @estadoPedidoCancelado.
  ///
  /// In es, this message translates to:
  /// **'Cancelado'**
  String get estadoPedidoCancelado;

  /// No description provided for @estadoPedidoConfirmado.
  ///
  /// In es, this message translates to:
  /// **'Confirmado'**
  String get estadoPedidoConfirmado;

  /// No description provided for @estadoPedidoEntregado.
  ///
  /// In es, this message translates to:
  /// **'Entregado'**
  String get estadoPedidoEntregado;

  /// No description provided for @estadoPedidoListo.
  ///
  /// In es, this message translates to:
  /// **'Listo para entregar'**
  String get estadoPedidoListo;

  /// No description provided for @estadoPedidoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get estadoPedidoPendiente;

  /// No description provided for @estadoPedidoPreparando.
  ///
  /// In es, this message translates to:
  /// **'Preparando'**
  String get estadoPedidoPreparando;

  /// No description provided for @fiadoAbono.
  ///
  /// In es, this message translates to:
  /// **'Abono'**
  String get fiadoAbono;

  /// No description provided for @fiadoConsumo.
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get fiadoConsumo;

  /// No description provided for @fiadoCupoDisponible.
  ///
  /// In es, this message translates to:
  /// **'Cupo disponible {disponible} de {limite}'**
  String fiadoCupoDisponible(String disponible, String limite);

  /// No description provided for @fiadoDebes.
  ///
  /// In es, this message translates to:
  /// **'Debes'**
  String get fiadoDebes;

  /// No description provided for @fiadoDisponibleDe.
  ///
  /// In es, this message translates to:
  /// **'Disponible {disponible} de {limite}'**
  String fiadoDisponibleDe(String disponible, String limite);

  /// No description provided for @fiadoNoAlcanza.
  ///
  /// In es, this message translates to:
  /// **'{texto} — no alcanza para este pedido'**
  String fiadoNoAlcanza(String texto);

  /// No description provided for @filtroTodo.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get filtroTodo;

  /// No description provided for @gananciaEstimada.
  ///
  /// In es, this message translates to:
  /// **'Ganancia estimada {monto}'**
  String gananciaEstimada(String monto);

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @guardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get guardarCambios;

  /// No description provided for @guardarNumeros.
  ///
  /// In es, this message translates to:
  /// **'Guardar números'**
  String get guardarNumeros;

  /// No description provided for @guardarReceta.
  ///
  /// In es, this message translates to:
  /// **'Guardar receta'**
  String get guardarReceta;

  /// No description provided for @haceAhora.
  ///
  /// In es, this message translates to:
  /// **'ahora'**
  String get haceAhora;

  /// No description provided for @haceAyer.
  ///
  /// In es, this message translates to:
  /// **'ayer'**
  String get haceAyer;

  /// No description provided for @haceDias.
  ///
  /// In es, this message translates to:
  /// **'hace {n} días'**
  String haceDias(int n);

  /// No description provided for @haceHoras.
  ///
  /// In es, this message translates to:
  /// **'hace {n} h'**
  String haceHoras(int n);

  /// No description provided for @haceMinutos.
  ///
  /// In es, this message translates to:
  /// **'hace {n} min'**
  String haceMinutos(int n);

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @idiomaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Según el celular'**
  String get idiomaAutomatico;

  /// No description provided for @idiomaEspanol.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get idiomaEspanol;

  /// No description provided for @idiomaIngles.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get idiomaIngles;

  /// No description provided for @igualAInventario.
  ///
  /// In es, this message translates to:
  /// **'= {unidades} {unidad} en el inventario'**
  String igualAInventario(String unidades, String unidad);

  /// No description provided for @igualAUnidadBase.
  ///
  /// In es, this message translates to:
  /// **'= {cantidad} {unidad}'**
  String igualAUnidadBase(String cantidad, String unidad);

  /// No description provided for @indicaCantidad.
  ///
  /// In es, this message translates to:
  /// **'Indica la cantidad'**
  String get indicaCantidad;

  /// No description provided for @indicaCuantoEntro.
  ///
  /// In es, this message translates to:
  /// **'Indica cuánto entró'**
  String get indicaCuantoEntro;

  /// No description provided for @insumoActualizado.
  ///
  /// In es, this message translates to:
  /// **'Insumo actualizado'**
  String get insumoActualizado;

  /// No description provided for @insumoAgregado.
  ///
  /// In es, this message translates to:
  /// **'Insumo agregado'**
  String get insumoAgregado;

  /// No description provided for @insumoNombreEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Harina'**
  String get insumoNombreEjemplo;

  /// No description provided for @insumosPorAcabarse.
  ///
  /// In es, this message translates to:
  /// **'{n} insumo(s) por acabarse'**
  String insumosPorAcabarse(int n);

  /// No description provided for @inventarioVacio.
  ///
  /// In es, this message translates to:
  /// **'Inventario vacío'**
  String get inventarioVacio;

  /// No description provided for @inventarioVacioDetalle.
  ///
  /// In es, this message translates to:
  /// **'Agrega tu primer producto con el botón de abajo.'**
  String get inventarioVacioDetalle;

  /// No description provided for @linterna.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get linterna;

  /// No description provided for @loginCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get loginCrearCuenta;

  /// No description provided for @loginDemo.
  ///
  /// In es, this message translates to:
  /// **'Modo demo — entra sin registrarte'**
  String get loginDemo;

  /// No description provided for @loginEntrar.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get loginEntrar;

  /// No description provided for @loginGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginGoogle;

  /// No description provided for @loginGoogleDetalle.
  ///
  /// In es, this message translates to:
  /// **'Usa la cuenta que ya tienes en el celular. No llenas nada.'**
  String get loginGoogleDetalle;

  /// No description provided for @loginLema.
  ///
  /// In es, this message translates to:
  /// **'Pide lo de siempre, sin salir de casa'**
  String get loginLema;

  /// No description provided for @loginNoTengoCuenta.
  ///
  /// In es, this message translates to:
  /// **'No tengo cuenta, quiero registrarme'**
  String get loginNoTengoCuenta;

  /// No description provided for @loginOCorreo.
  ///
  /// In es, this message translates to:
  /// **'o con tu correo'**
  String get loginOCorreo;

  /// No description provided for @loginPrefieroCorreo.
  ///
  /// In es, this message translates to:
  /// **'Prefiero usar mi correo'**
  String get loginPrefieroCorreo;

  /// No description provided for @loginYaTengoCuenta.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta'**
  String get loginYaTengoCuenta;

  /// No description provided for @marcaEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Gloria, Costeño, Primor...'**
  String get marcaEjemplo;

  /// No description provided for @marcarComo.
  ///
  /// In es, this message translates to:
  /// **'Marcar {estado}'**
  String marcarComo(String estado);

  /// No description provided for @metodoNoConfigurado.
  ///
  /// In es, this message translates to:
  /// **'La tienda aún no lo tiene configurado'**
  String get metodoNoConfigurado;

  /// No description provided for @metodoPagoEfectivo.
  ///
  /// In es, this message translates to:
  /// **'Efectivo al recibir'**
  String get metodoPagoEfectivo;

  /// No description provided for @metodoPagoFiado.
  ///
  /// In es, this message translates to:
  /// **'Fiado (a la cuenta)'**
  String get metodoPagoFiado;

  /// No description provided for @metodoPagoPlin.
  ///
  /// In es, this message translates to:
  /// **'Plin'**
  String get metodoPagoPlin;

  /// No description provided for @metodoPagoTarjeta.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta (pasarela)'**
  String get metodoPagoTarjeta;

  /// No description provided for @metodoPagoYape.
  ///
  /// In es, this message translates to:
  /// **'Yape'**
  String get metodoPagoYape;

  /// No description provided for @miCuentaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get miCuentaTitulo;

  /// No description provided for @misPedidosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get misPedidosTitulo;

  /// No description provided for @modoDemoBanner.
  ///
  /// In es, this message translates to:
  /// **'Modo demo: los datos son de ejemplo y no se guardan.'**
  String get modoDemoBanner;

  /// No description provided for @montoCalculado.
  ///
  /// In es, this message translates to:
  /// **'Calculado del producto; puedes corregirlo'**
  String get montoCalculado;

  /// No description provided for @montoCosto.
  ///
  /// In es, this message translates to:
  /// **'Cuánto te costó'**
  String get montoCosto;

  /// No description provided for @montoEscrito.
  ///
  /// In es, this message translates to:
  /// **'Lo escribiste tú'**
  String get montoEscrito;

  /// No description provided for @montoInvalido.
  ///
  /// In es, this message translates to:
  /// **'Monto inválido'**
  String get montoInvalido;

  /// No description provided for @montoMerma.
  ///
  /// In es, this message translates to:
  /// **'Cuánto perdiste'**
  String get montoMerma;

  /// No description provided for @montoVenta.
  ///
  /// In es, this message translates to:
  /// **'Cuánto cobraste'**
  String get montoVenta;

  /// No description provided for @movInsumoAjuste.
  ///
  /// In es, this message translates to:
  /// **'Ajuste'**
  String get movInsumoAjuste;

  /// No description provided for @movInsumoCompra.
  ///
  /// In es, this message translates to:
  /// **'Compra'**
  String get movInsumoCompra;

  /// No description provided for @movInsumoConsumo.
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get movInsumoConsumo;

  /// No description provided for @movInsumoMerma.
  ///
  /// In es, this message translates to:
  /// **'Merma'**
  String get movInsumoMerma;

  /// No description provided for @movInvAjuste.
  ///
  /// In es, this message translates to:
  /// **'Ajuste'**
  String get movInvAjuste;

  /// No description provided for @movInvCompra.
  ///
  /// In es, this message translates to:
  /// **'Compra'**
  String get movInvCompra;

  /// No description provided for @movInvDevolucion.
  ///
  /// In es, this message translates to:
  /// **'Devolución'**
  String get movInvDevolucion;

  /// No description provided for @movInvMerma.
  ///
  /// In es, this message translates to:
  /// **'Merma'**
  String get movInvMerma;

  /// No description provided for @movInvProduccion.
  ///
  /// In es, this message translates to:
  /// **'Producción'**
  String get movInvProduccion;

  /// No description provided for @movInvVenta.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get movInvVenta;

  /// No description provided for @movLotes.
  ///
  /// In es, this message translates to:
  /// **' · {n} lote(s)'**
  String movLotes(String n);

  /// No description provided for @movPresentaciones.
  ///
  /// In es, this message translates to:
  /// **' · {n} presentación(es)'**
  String movPresentaciones(String n);

  /// No description provided for @movUnidades.
  ///
  /// In es, this message translates to:
  /// **'{n} und'**
  String movUnidades(String n);

  /// No description provided for @movimientoRegistrado.
  ///
  /// In es, this message translates to:
  /// **'{tipo} registrada'**
  String movimientoRegistrado(String tipo);

  /// No description provided for @movimientos.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get movimientos;

  /// No description provided for @navCaja.
  ///
  /// In es, this message translates to:
  /// **'Caja'**
  String get navCaja;

  /// No description provided for @navFiado.
  ///
  /// In es, this message translates to:
  /// **'Fiado'**
  String get navFiado;

  /// No description provided for @navInventario.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get navInventario;

  /// No description provided for @navPedidos.
  ///
  /// In es, this message translates to:
  /// **'Pedidos'**
  String get navPedidos;

  /// No description provided for @navPerfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navPerfil;

  /// No description provided for @navTienda.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get navTienda;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noSePudoCargar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar'**
  String get noSePudoCargar;

  /// No description provided for @nombreDelLote.
  ///
  /// In es, this message translates to:
  /// **'Nombre del lote'**
  String get nombreDelLote;

  /// No description provided for @nombreDelLoteEjemplo.
  ///
  /// In es, this message translates to:
  /// **'plancha'**
  String get nombreDelLoteEjemplo;

  /// No description provided for @notaEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Horneada de la mañana'**
  String get notaEjemplo;

  /// No description provided for @nuevoInsumo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo insumo'**
  String get nuevoInsumo;

  /// No description provided for @nuevoProducto.
  ///
  /// In es, this message translates to:
  /// **'Nuevo producto'**
  String get nuevoProducto;

  /// No description provided for @numeroCopiado.
  ///
  /// In es, this message translates to:
  /// **'Número copiado. Pégalo en {metodo}.'**
  String numeroCopiado(String metodo);

  /// No description provided for @operacionNumero.
  ///
  /// In es, this message translates to:
  /// **'Operación {referencia}'**
  String operacionNumero(String referencia);

  /// No description provided for @operacionSufijo.
  ///
  /// In es, this message translates to:
  /// **' · op. {referencia}'**
  String operacionSufijo(String referencia);

  /// No description provided for @pagaConMetodo.
  ///
  /// In es, this message translates to:
  /// **'Paga {total} con {metodo}'**
  String pagaConMetodo(String total, String metodo);

  /// No description provided for @pagarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get pagarTitulo;

  /// No description provided for @pagoNoLlego.
  ///
  /// In es, this message translates to:
  /// **'No llegó'**
  String get pagoNoLlego;

  /// No description provided for @pagoRecibido.
  ///
  /// In es, this message translates to:
  /// **'Pago recibido'**
  String get pagoRecibido;

  /// No description provided for @pedidoEnviadoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Tu pedido {codigo} por {total} llegó a la tienda.\n\n{estadoPago}.'**
  String pedidoEnviadoDetalle(String codigo, String total, String estadoPago);

  /// No description provided for @pedidoEnviadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¡Pedido enviado!'**
  String get pedidoEnviadoTitulo;

  /// No description provided for @pedidoNumero.
  ///
  /// In es, this message translates to:
  /// **'Pedido {codigo}'**
  String pedidoNumero(String codigo);

  /// No description provided for @pedidosSoloActivos.
  ///
  /// In es, this message translates to:
  /// **'Solo activos'**
  String get pedidosSoloActivos;

  /// No description provided for @perfilDatosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Datos guardados'**
  String get perfilDatosGuardados;

  /// No description provided for @perfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get perfilTitulo;

  /// No description provided for @periodoHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get periodoHoy;

  /// No description provided for @periodoMes.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get periodoMes;

  /// No description provided for @periodoSemana.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get periodoSemana;

  /// No description provided for @piePieDemo.
  ///
  /// In es, this message translates to:
  /// **'{tienda} · modo demo'**
  String piePieDemo(String tienda);

  /// No description provided for @porLote.
  ///
  /// In es, this message translates to:
  /// **'Por {lote}'**
  String porLote(String lote);

  /// No description provided for @porPresentacion.
  ///
  /// In es, this message translates to:
  /// **'Por {nombre}'**
  String porPresentacion(String nombre);

  /// No description provided for @porUnidad.
  ///
  /// In es, this message translates to:
  /// **'Por unidad'**
  String get porUnidad;

  /// No description provided for @porUnidadHelper.
  ///
  /// In es, this message translates to:
  /// **'por {unidad}'**
  String porUnidadHelper(String unidad);

  /// No description provided for @porUnidadSufijo.
  ///
  /// In es, this message translates to:
  /// **' · {monto} por unidad'**
  String porUnidadSufijo(String monto);

  /// No description provided for @precioInvalido.
  ///
  /// In es, this message translates to:
  /// **'Precio inválido'**
  String get precioInvalido;

  /// No description provided for @presentacionDe.
  ///
  /// In es, this message translates to:
  /// **' · {nombre} de {cantidad} {unidad}'**
  String presentacionDe(String nombre, String cantidad, String unidad);

  /// No description provided for @presentacionEjemplo.
  ///
  /// In es, this message translates to:
  /// **'saco'**
  String get presentacionEjemplo;

  /// No description provided for @presentacionesEnStock.
  ///
  /// In es, this message translates to:
  /// **'{n} {nombre}(s)'**
  String presentacionesEnStock(String n, String nombre);

  /// No description provided for @produccionRegistrada.
  ///
  /// In es, this message translates to:
  /// **'Producción registrada · {costo} por unidad'**
  String produccionRegistrada(String costo);

  /// No description provided for @produccionRegistradaDif.
  ///
  /// In es, this message translates to:
  /// **'Registrada · {diferencia} vs lo esperado · {costo} c/u'**
  String produccionRegistradaDif(String diferencia, String costo);

  /// No description provided for @productoActualizado.
  ///
  /// In es, this message translates to:
  /// **'Producto actualizado'**
  String get productoActualizado;

  /// No description provided for @productoAgotado.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get productoAgotado;

  /// No description provided for @productoAgregado.
  ///
  /// In es, this message translates to:
  /// **'Producto agregado'**
  String get productoAgregado;

  /// No description provided for @productoBajaSufijo.
  ///
  /// In es, this message translates to:
  /// **' · dado de baja'**
  String get productoBajaSufijo;

  /// No description provided for @productoConStock.
  ///
  /// In es, this message translates to:
  /// **'{nombre} · {stock} en stock'**
  String productoConStock(String nombre, String stock);

  /// No description provided for @productoMargenSufijo.
  ///
  /// In es, this message translates to:
  /// **' · gana {monto}'**
  String productoMargenSufijo(String monto);

  /// No description provided for @productoPaqueteSufijo.
  ///
  /// In es, this message translates to:
  /// **' · {unidades} x {precio}'**
  String productoPaqueteSufijo(String unidades, String precio);

  /// No description provided for @productoResumen.
  ///
  /// In es, this message translates to:
  /// **'{precio} · {unidad}{paquete}{margen}{baja}'**
  String productoResumen(
    String precio,
    String unidad,
    String paquete,
    String margen,
    String baja,
  );

  /// No description provided for @productoYaRegistrado.
  ///
  /// In es, this message translates to:
  /// **'{nombre} ya está registrado · stock {stock}'**
  String productoYaRegistrado(String nombre, String stock);

  /// No description provided for @productosSinStock.
  ///
  /// In es, this message translates to:
  /// **'{n} producto(s) sin stock'**
  String productosSinStock(int n);

  /// No description provided for @productosSinStockDetalle.
  ///
  /// In es, this message translates to:
  /// **'Los clientes no pueden pedirlos.'**
  String get productosSinStockDetalle;

  /// No description provided for @proximamente.
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get proximamente;

  /// No description provided for @qrActualizado.
  ///
  /// In es, this message translates to:
  /// **'QR de {metodo} actualizado'**
  String qrActualizado(String metodo);

  /// No description provided for @qrInstrucciones.
  ///
  /// In es, this message translates to:
  /// **'Escanea el QR desde tu app, o guarda la imagen si estás pagando desde este mismo celular.'**
  String get qrInstrucciones;

  /// No description provided for @qrNoCarga.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el QR'**
  String get qrNoCarga;

  /// No description provided for @qrQuitado.
  ///
  /// In es, this message translates to:
  /// **'QR quitado'**
  String get qrQuitado;

  /// No description provided for @queVasAGastar.
  ///
  /// In es, this message translates to:
  /// **'Qué vas a gastar'**
  String get queVasAGastar;

  /// No description provided for @quedanUnidades.
  ///
  /// In es, this message translates to:
  /// **'Quedan {n}'**
  String quedanUnidades(String n);

  /// No description provided for @quitar.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get quitar;

  /// No description provided for @recetaBoton.
  ///
  /// In es, this message translates to:
  /// **'Receta: qué insumos gasta'**
  String get recetaBoton;

  /// No description provided for @recetaCorrigelo.
  ///
  /// In es, this message translates to:
  /// **'Sale de la receta; corrígelo si esta vez usaste más o menos.'**
  String get recetaCorrigelo;

  /// No description provided for @recetaCuantoSeGasta.
  ///
  /// In es, this message translates to:
  /// **'Cuánto se gasta para hacer {lote}.'**
  String recetaCuantoSeGasta(String lote);

  /// No description provided for @recetaDe.
  ///
  /// In es, this message translates to:
  /// **'Receta de {producto}'**
  String recetaDe(String producto);

  /// No description provided for @recetaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Receta guardada'**
  String get recetaGuardada;

  /// No description provided for @recetaLoteDe.
  ///
  /// In es, this message translates to:
  /// **'1 {nombreLote} ({unidades} {unidad})'**
  String recetaLoteDe(String nombreLote, String unidades, String unidad);

  /// No description provided for @recetaUnLote.
  ///
  /// In es, this message translates to:
  /// **'un lote'**
  String get recetaUnLote;

  /// No description provided for @registrar.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get registrar;

  /// No description provided for @registrarAbono.
  ///
  /// In es, this message translates to:
  /// **'Registrar abono'**
  String get registrarAbono;

  /// No description provided for @registrarCompra.
  ///
  /// In es, this message translates to:
  /// **'Registrar compra'**
  String get registrarCompra;

  /// No description provided for @registrarConsumo.
  ///
  /// In es, this message translates to:
  /// **'Registrar consumo'**
  String get registrarConsumo;

  /// No description provided for @registrarMovimiento.
  ///
  /// In es, this message translates to:
  /// **'Registrar movimiento'**
  String get registrarMovimiento;

  /// No description provided for @registrarProduccion.
  ///
  /// In es, this message translates to:
  /// **'Registrar producción'**
  String get registrarProduccion;

  /// No description provided for @registrarTipo.
  ///
  /// In es, this message translates to:
  /// **'Registrar {tipo}'**
  String registrarTipo(String tipo);

  /// No description provided for @reintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// No description provided for @resumenProductos.
  ///
  /// In es, this message translates to:
  /// **'Resumen ({n} productos)'**
  String resumenProductos(int n);

  /// No description provided for @rindioMas.
  ///
  /// In es, this message translates to:
  /// **'Rindió {n} más de lo esperado ({esperado})'**
  String rindioMas(String n, String esperado);

  /// No description provided for @rindioMenos.
  ///
  /// In es, this message translates to:
  /// **'Rindió {n} menos de lo esperado ({esperado})'**
  String rindioMenos(String n, String esperado);

  /// No description provided for @rolCliente.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get rolCliente;

  /// No description provided for @rolTendero.
  ///
  /// In es, this message translates to:
  /// **'Tendero'**
  String get rolTendero;

  /// No description provided for @saleDeCaja.
  ///
  /// In es, this message translates to:
  /// **'Sale {monto} de la caja'**
  String saleDeCaja(Object monto);

  /// No description provided for @seCompraPor.
  ///
  /// In es, this message translates to:
  /// **'Se compra por'**
  String get seCompraPor;

  /// No description provided for @seGastaEn.
  ///
  /// In es, this message translates to:
  /// **'Se gasta en'**
  String get seGastaEn;

  /// No description provided for @seMostrara.
  ///
  /// In es, this message translates to:
  /// **'Se mostrará: {unidades} por {total}'**
  String seMostrara(String unidades, String total);

  /// No description provided for @seVendeDeA.
  ///
  /// In es, this message translates to:
  /// **'Se vende de a (opcional)'**
  String get seVendeDeA;

  /// No description provided for @seVendeDeAEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 4 panes por un sol → escribe 4'**
  String get seVendeDeAEjemplo;

  /// No description provided for @segInsumos.
  ///
  /// In es, this message translates to:
  /// **'Insumos'**
  String get segInsumos;

  /// No description provided for @segProductos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get segProductos;

  /// No description provided for @sinAvisoHelper.
  ///
  /// In es, this message translates to:
  /// **'Déjalo vacío si no quieres aviso'**
  String get sinAvisoHelper;

  /// No description provided for @sinCategoria.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get sinCategoria;

  /// No description provided for @sinClientes.
  ///
  /// In es, this message translates to:
  /// **'Sin clientes registrados'**
  String get sinClientes;

  /// No description provided for @sinClientesDetalle.
  ///
  /// In es, this message translates to:
  /// **'Cuando alguien cree su cuenta aparecerá aquí.'**
  String get sinClientesDetalle;

  /// No description provided for @sinFiadoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Pídele a la tienda que te habilite un cupo.'**
  String get sinFiadoDetalle;

  /// No description provided for @sinFiadoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin cuenta de fiado'**
  String get sinFiadoTitulo;

  /// No description provided for @sinInsumosDetalle.
  ///
  /// In es, this message translates to:
  /// **'Agrégalos primero en Inventario → Insumos.'**
  String get sinInsumosDetalle;

  /// No description provided for @sinInsumosTitulo.
  ///
  /// In es, this message translates to:
  /// **'No hay insumos registrados'**
  String get sinInsumosTitulo;

  /// No description provided for @sinInsumosTodavia.
  ///
  /// In es, this message translates to:
  /// **'Sin insumos todavía'**
  String get sinInsumosTodavia;

  /// No description provided for @sinInsumosTodaviaDetalle.
  ///
  /// In es, this message translates to:
  /// **'Agrega la harina, la levadura y lo que uses para producir.'**
  String get sinInsumosTodaviaDetalle;

  /// No description provided for @sinMovimientos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes movimientos.'**
  String get sinMovimientos;

  /// No description provided for @sinMovimientosPeriodo.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos en este periodo'**
  String get sinMovimientosPeriodo;

  /// No description provided for @sinMovimientosPeriodoDetalle.
  ///
  /// In es, this message translates to:
  /// **'Registra una producción o espera la primera venta.'**
  String get sinMovimientosPeriodoDetalle;

  /// No description provided for @sinMovimientosPunto.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos.'**
  String get sinMovimientosPunto;

  /// No description provided for @sinPedidosActivos.
  ///
  /// In es, this message translates to:
  /// **'No hay pedidos activos'**
  String get sinPedidosActivos;

  /// No description provided for @sinPedidosAun.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay pedidos'**
  String get sinPedidosAun;

  /// No description provided for @sinPedidosAunDetalle.
  ///
  /// In es, this message translates to:
  /// **'Los pedidos nuevos aparecen aquí al instante.'**
  String get sinPedidosAunDetalle;

  /// No description provided for @sinPedidosDetalle.
  ///
  /// In es, this message translates to:
  /// **'Cuando hagas tu primer pedido lo verás aquí.'**
  String get sinPedidosDetalle;

  /// No description provided for @sinPedidosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has pedido nada'**
  String get sinPedidosTitulo;

  /// No description provided for @sinQr.
  ///
  /// In es, this message translates to:
  /// **'Todavía no subes tu QR'**
  String get sinQr;

  /// No description provided for @stockHelperExistente.
  ///
  /// In es, this message translates to:
  /// **'Para reponer, usa Producción o Compra en Caja'**
  String get stockHelperExistente;

  /// No description provided for @stockHelperNuevo.
  ///
  /// In es, this message translates to:
  /// **'Cuánto tienes ahora'**
  String get stockHelperNuevo;

  /// No description provided for @stockInsuficiente.
  ///
  /// In es, this message translates to:
  /// **'Solo hay {stock} en stock y estás sacando {sacas}.'**
  String stockInsuficiente(String stock, String sacas);

  /// No description provided for @stockInsumoQueda.
  ///
  /// In es, this message translates to:
  /// **'Stock: {antes} → {despues} {unidad}'**
  String stockInsumoQueda(String antes, String despues, String unidad);

  /// No description provided for @stockInvalido.
  ///
  /// In es, this message translates to:
  /// **'Stock inválido'**
  String get stockInvalido;

  /// No description provided for @stockQueda.
  ///
  /// In es, this message translates to:
  /// **'Stock: {antes} → {despues} {unidad}'**
  String stockQueda(String antes, String despues, String unidad);

  /// No description provided for @subirQr.
  ///
  /// In es, this message translates to:
  /// **'Subir imagen del QR'**
  String get subirQr;

  /// No description provided for @teDebenEnTotal.
  ///
  /// In es, this message translates to:
  /// **'Te deben en total'**
  String get teDebenEnTotal;

  /// No description provided for @temaAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Según el celular'**
  String get temaAutomatico;

  /// No description provided for @temaClaro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get temaClaro;

  /// No description provided for @temaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get temaOscuro;

  /// No description provided for @tiendaExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Esto es lo que ve el cliente cuando elige pagar con Yape o Plin. Si no pones número ni QR, el método no se le ofrece.'**
  String get tiendaExplicacion;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @unidadEjemplo.
  ///
  /// In es, this message translates to:
  /// **'und, bolsa, kg...'**
  String get unidadEjemplo;

  /// No description provided for @unidadesPorLote.
  ///
  /// In es, this message translates to:
  /// **'Unidades por lote'**
  String get unidadesPorLote;

  /// No description provided for @unidadesPorLoteEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 30'**
  String get unidadesPorLoteEjemplo;

  /// No description provided for @usar.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get usar;

  /// No description provided for @vaciar.
  ///
  /// In es, this message translates to:
  /// **'Vaciar'**
  String get vaciar;

  /// No description provided for @validaClave.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get validaClave;

  /// No description provided for @validaCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido'**
  String get validaCorreo;

  /// No description provided for @validaEscribeNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre'**
  String get validaEscribeNombre;

  /// No description provided for @validaNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre'**
  String get validaNombre;

  /// No description provided for @ventaMostrador.
  ///
  /// In es, this message translates to:
  /// **'Venta en mostrador'**
  String get ventaMostrador;

  /// No description provided for @verCatalogo.
  ///
  /// In es, this message translates to:
  /// **'Ver catálogo'**
  String get verCatalogo;

  /// No description provided for @verificaPago.
  ///
  /// In es, this message translates to:
  /// **'Verifica {total} por {metodo}{operacion}'**
  String verificaPago(String total, String metodo, String operacion);

  /// No description provided for @visibleEnCatalogo.
  ///
  /// In es, this message translates to:
  /// **'Visible en el catálogo'**
  String get visibleEnCatalogo;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LEn();
    case 'es':
      return LEs();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
