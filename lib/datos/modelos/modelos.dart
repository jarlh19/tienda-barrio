// Modelos de dominio de la tienda.
// Todos se serializan a/desde el JSON que devuelve Supabase (snake_case).

enum Rol { cliente, tendero }

Rol rolDesde(String? v) => v == 'tendero' ? Rol.tendero : Rol.cliente;

class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.rol,
    this.telefono = '',
    this.direccion = '',
  });

  final String id;
  final String nombre;
  final Rol rol;
  final String telefono;
  final String direccion;

  bool get esTendero => rol == Rol.tendero;

  factory Perfil.desdeJson(Map<String, dynamic> j) => Perfil(
        id: j['id'] as String,
        nombre: (j['nombre'] ?? '') as String,
        rol: rolDesde(j['rol'] as String?),
        telefono: (j['telefono'] ?? '') as String,
        direccion: (j['direccion'] ?? '') as String,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'rol': rol.name,
        'telefono': telefono,
        'direccion': direccion,
      };

  Perfil copiar({String? nombre, String? telefono, String? direccion}) => Perfil(
        id: id,
        nombre: nombre ?? this.nombre,
        rol: rol,
        telefono: telefono ?? this.telefono,
        direccion: direccion ?? this.direccion,
      );
}

class Categoria {
  const Categoria({required this.id, required this.nombre, this.emoji = ''});

  final String id;
  final String nombre;
  final String emoji;

  factory Categoria.desdeJson(Map<String, dynamic> j) => Categoria(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        emoji: (j['emoji'] ?? '') as String,
      );

  Map<String, dynamic> aJson() => {'id': id, 'nombre': nombre, 'emoji': emoji};
}

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    this.categoriaId = '',
    this.marca = '',
    this.descripcion = '',
    this.imagenUrl = '',
    this.unidad = 'und',
    this.contenido = 0,
    this.medida = '',
    this.codigoBarras = '',
    this.costo = 0,
    this.unidadesPorLote = 0,
    this.nombreLote = '',
    this.unidadesPorPaquete = 0,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final double precio;
  final int stock;
  final String categoriaId;

  /// Marca del envase: Gloria, Primor, Costeño...
  final String marca;

  final String descripcion;
  final String imagenUrl;

  /// Presentación en que se despacha: botella, bolsa, lata, und.
  final String unidad;

  /// Peso o volumen del envase. 0 cuando no aplica (pan, verduras a granel).
  final double contenido;

  /// Unidad de [contenido]: g, kg, ml, L.
  final String medida;

  /// Lo que le cuesta al tendero cada unidad. Es la mitad que falta para
  /// saber si el negocio gana: sin costo solo se ve cuanto entra.
  final double costo;

  /// Cuantas unidades salen de un lote de produccion. 30 panes por plancha.
  /// 0 cuando el producto se compra hecho y no se produce.
  final int unidadesPorLote;

  /// Como llama el tendero a ese lote: plancha, bandeja, saco.
  final String nombreLote;

  /// Presentacion de venta: 4 panes por 1 sol. 0 o 1 = se vende por unidad.
  final int unidadesPorPaquete;

  /// EAN-13 / UPC impreso en el envase. Vacío para lo que se vende suelto
  /// (pan, verduras) o para productos sin etiqueta.
  final String codigoBarras;

  final bool activo;

  bool get hayStock => stock > 0;
  bool get stockBajo => stock > 0 && stock <= 5;

  bool get seProduce => unidadesPorLote > 0;
  bool get seVendePorPaquete => unidadesPorPaquete > 1;

  /// Lo que paga el cliente por el paquete completo: 4 x S/ 0.25 = S/ 1.00.
  double get precioPaquete => precio * unidadesPorPaquete;

  /// Ganancia por unidad vendida. Negativa si el precio quedo bajo el costo.
  double get margenUnitario => precio - costo;

  /// Lo que cuesta producir un lote entero, segun el costo unitario.
  double get costoLote => costo * unidadesPorLote;

  /// Cuantos lotes completos hay en el stock actual (2.5 planchas).
  double get lotesEnStock => seProduce ? stock / unidadesPorLote : 0;

  /// "900 ml", "1 kg". Vacío si el producto no declara peso ni volumen.
  String get etiquetaContenido {
    if (contenido <= 0 || medida.isEmpty) return '';
    final n = contenido == contenido.roundToDouble()
        ? contenido.toStringAsFixed(0)
        : contenido.toString();
    return '$n $medida';
  }

  /// Cómo se nombra el producto en la estantería: marca + nombre + contenido.
  String get nombreCompleto => [
        if (marca.isNotEmpty) marca,
        nombre,
        if (etiquetaContenido.isNotEmpty) etiquetaContenido,
      ].join(' ');

  factory Producto.desdeJson(Map<String, dynamic> j) => Producto(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        precio: (j['precio'] as num).toDouble(),
        stock: (j['stock'] as num?)?.toInt() ?? 0,
        categoriaId: (j['categoria_id'] ?? '') as String,
        marca: (j['marca'] ?? '') as String,
        descripcion: (j['descripcion'] ?? '') as String,
        imagenUrl: (j['imagen_url'] ?? '') as String,
        unidad: (j['unidad'] ?? 'und') as String,
        contenido: ((j['contenido'] as num?) ?? 0).toDouble(),
        medida: (j['medida'] ?? '') as String,
        costo: ((j['costo'] as num?) ?? 0).toDouble(),
        unidadesPorLote: ((j['unidades_por_lote'] as num?) ?? 0).toInt(),
        nombreLote: (j['nombre_lote'] ?? '') as String,
        unidadesPorPaquete: ((j['unidades_por_paquete'] as num?) ?? 0).toInt(),
        codigoBarras: (j['codigo_barras'] ?? '') as String,
        activo: (j['activo'] ?? true) as bool,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'categoria_id': categoriaId.isEmpty ? null : categoriaId,
        'marca': marca,
        'descripcion': descripcion,
        'imagen_url': imagenUrl,
        'unidad': unidad,
        'contenido': contenido,
        'medida': medida,
        'costo': costo,
        'unidades_por_lote': unidadesPorLote,
        'nombre_lote': nombreLote,
        'unidades_por_paquete': unidadesPorPaquete,
        // NULL y no '' para que el índice único de la base tolere varios
        // productos sin etiqueta.
        'codigo_barras': codigoBarras.isEmpty ? null : codigoBarras,
        'activo': activo,
      };

  /// Copia con otro id. Se usa al dar de alta: enumerar los campos a mano
  /// hacía que cada campo nuevo se perdiera en silencio al crear.
  Producto conId(String nuevoId) => Producto(
        id: nuevoId,
        nombre: nombre,
        precio: precio,
        stock: stock,
        categoriaId: categoriaId,
        marca: marca,
        descripcion: descripcion,
        imagenUrl: imagenUrl,
        unidad: unidad,
        contenido: contenido,
        medida: medida,
        codigoBarras: codigoBarras,
        costo: costo,
        unidadesPorLote: unidadesPorLote,
        nombreLote: nombreLote,
        unidadesPorPaquete: unidadesPorPaquete,
        activo: activo,
      );

  Producto copiar({
    String? nombre,
    double? precio,
    int? stock,
    String? categoriaId,
    String? marca,
    String? descripcion,
    String? imagenUrl,
    String? unidad,
    double? contenido,
    String? medida,
    String? codigoBarras,
    double? costo,
    int? unidadesPorLote,
    String? nombreLote,
    int? unidadesPorPaquete,
    bool? activo,
  }) =>
      Producto(
        id: id,
        nombre: nombre ?? this.nombre,
        precio: precio ?? this.precio,
        stock: stock ?? this.stock,
        categoriaId: categoriaId ?? this.categoriaId,
        marca: marca ?? this.marca,
        descripcion: descripcion ?? this.descripcion,
        imagenUrl: imagenUrl ?? this.imagenUrl,
        unidad: unidad ?? this.unidad,
        contenido: contenido ?? this.contenido,
        medida: medida ?? this.medida,
        costo: costo ?? this.costo,
        unidadesPorLote: unidadesPorLote ?? this.unidadesPorLote,
        nombreLote: nombreLote ?? this.nombreLote,
        unidadesPorPaquete: unidadesPorPaquete ?? this.unidadesPorPaquete,
        codigoBarras: codigoBarras ?? this.codigoBarras,
        activo: activo ?? this.activo,
      );
}

class ItemPedido {
  const ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    this.unidad = 'und',
  });

  final String productoId;
  final String nombre;
  final double precioUnitario;
  final int cantidad;
  final String unidad;

  double get subtotal => precioUnitario * cantidad;

  factory ItemPedido.desdeJson(Map<String, dynamic> j) => ItemPedido(
        productoId: j['producto_id'] as String,
        nombre: j['nombre'] as String,
        precioUnitario: (j['precio_unitario'] as num).toDouble(),
        cantidad: (j['cantidad'] as num).toInt(),
        unidad: (j['unidad'] ?? 'und') as String,
      );

  Map<String, dynamic> aJson() => {
        'producto_id': productoId,
        'nombre': nombre,
        'precio_unitario': precioUnitario,
        'cantidad': cantidad,
        'unidad': unidad,
      };

  ItemPedido conCantidad(int c) => ItemPedido(
        productoId: productoId,
        nombre: nombre,
        precioUnitario: precioUnitario,
        cantidad: c,
        unidad: unidad,
      );
}

enum EstadoPedido { pendiente, confirmado, preparando, listo, entregado, cancelado }

extension EstadoPedidoX on EstadoPedido {
  /// Estado al que puede avanzar el tendero desde este. `null` = fin del flujo.
  EstadoPedido? get siguiente => switch (this) {
        EstadoPedido.pendiente => EstadoPedido.confirmado,
        EstadoPedido.confirmado => EstadoPedido.preparando,
        EstadoPedido.preparando => EstadoPedido.listo,
        EstadoPedido.listo => EstadoPedido.entregado,
        _ => null,
      };

  bool get abierto =>
      this != EstadoPedido.entregado && this != EstadoPedido.cancelado;
}

enum MetodoPago { efectivo, yape, plin, tarjeta, fiado }

extension MetodoPagoX on MetodoPago {
  /// Métodos donde el cliente informa un código de operación que el tendero verifica.
  bool get requiereComprobante =>
      this == MetodoPago.yape || this == MetodoPago.plin;
}

enum EstadoPago { pendiente, verificando, pagado, fiado, fallido }

T _enumDesde<T extends Enum>(List<T> valores, String? v, T porDefecto) {
  for (final e in valores) {
    if (e.name == v) return e;
  }
  return porDefecto;
}

class Pedido {
  const Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.items,
    required this.creadoEn,
    this.estado = EstadoPedido.pendiente,
    this.metodoPago = MetodoPago.efectivo,
    this.estadoPago = EstadoPago.pendiente,
    this.referenciaPago = '',
    this.direccion = '',
    this.notas = '',
  });

  final String id;
  final String clienteId;
  final String clienteNombre;
  final List<ItemPedido> items;
  final DateTime creadoEn;
  final EstadoPedido estado;
  final MetodoPago metodoPago;
  final EstadoPago estadoPago;
  final String referenciaPago;
  final String direccion;
  final String notas;

  double get total => items.fold(0, (s, i) => s + i.subtotal);
  int get unidades => items.fold(0, (s, i) => s + i.cantidad);
  String get codigo =>
      id.length <= 6 ? id.toUpperCase() : id.substring(0, 6).toUpperCase();

  factory Pedido.desdeJson(Map<String, dynamic> j) => Pedido(
        id: j['id'] as String,
        clienteId: j['cliente_id'] as String,
        clienteNombre: (j['cliente_nombre'] ?? '') as String,
        items: ((j['items'] ?? []) as List)
            .map((e) => ItemPedido.desdeJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        creadoEn: DateTime.parse(j['creado_en'] as String).toLocal(),
        estado: _enumDesde(
            EstadoPedido.values, j['estado'] as String?, EstadoPedido.pendiente),
        metodoPago: _enumDesde(
            MetodoPago.values, j['metodo_pago'] as String?, MetodoPago.efectivo),
        estadoPago: _enumDesde(
            EstadoPago.values, j['estado_pago'] as String?, EstadoPago.pendiente),
        referenciaPago: (j['referencia_pago'] ?? '') as String,
        direccion: (j['direccion'] ?? '') as String,
        notas: (j['notas'] ?? '') as String,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'cliente_id': clienteId,
        'cliente_nombre': clienteNombre,
        'items': items.map((e) => e.aJson()).toList(),
        'creado_en': creadoEn.toUtc().toIso8601String(),
        'estado': estado.name,
        'metodo_pago': metodoPago.name,
        'estado_pago': estadoPago.name,
        'referencia_pago': referenciaPago,
        'direccion': direccion,
        'notas': notas,
        'total': total,
      };

  Pedido copiar({
    EstadoPedido? estado,
    EstadoPago? estadoPago,
    String? referenciaPago,
  }) =>
      Pedido(
        id: id,
        clienteId: clienteId,
        clienteNombre: clienteNombre,
        items: items,
        creadoEn: creadoEn,
        estado: estado ?? this.estado,
        metodoPago: metodoPago,
        estadoPago: estadoPago ?? this.estadoPago,
        referenciaPago: referenciaPago ?? this.referenciaPago,
        direccion: direccion,
        notas: notas,
      );
}

enum TipoMovimiento { cargo, abono }

class MovimientoFiado {
  const MovimientoFiado({
    required this.id,
    required this.clienteId,
    required this.tipo,
    required this.monto,
    required this.fecha,
    this.descripcion = '',
    this.pedidoId,
  });

  final String id;
  final String clienteId;
  final TipoMovimiento tipo;
  final double monto;
  final DateTime fecha;
  final String descripcion;
  final String? pedidoId;

  /// Efecto sobre el saldo: un cargo suma deuda, un abono la reduce.
  double get efecto => tipo == TipoMovimiento.cargo ? monto : -monto;

  factory MovimientoFiado.desdeJson(Map<String, dynamic> j) => MovimientoFiado(
        id: j['id'] as String,
        clienteId: j['cliente_id'] as String,
        tipo: _enumDesde(
            TipoMovimiento.values, j['tipo'] as String?, TipoMovimiento.cargo),
        monto: (j['monto'] as num).toDouble(),
        fecha: DateTime.parse(j['fecha'] as String).toLocal(),
        descripcion: (j['descripcion'] ?? '') as String,
        pedidoId: j['pedido_id'] as String?,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'cliente_id': clienteId,
        'tipo': tipo.name,
        'monto': monto,
        'fecha': fecha.toUtc().toIso8601String(),
        'descripcion': descripcion,
        'pedido_id': pedidoId,
      };
}

class CuentaFiado {
  const CuentaFiado({
    required this.clienteId,
    required this.clienteNombre,
    required this.saldo,
    this.limite = 100,
    this.movimientos = const [],
  });

  final String clienteId;
  final String clienteNombre;

  /// Deuda pendiente. Positivo = el cliente debe.
  final double saldo;
  final double limite;
  final List<MovimientoFiado> movimientos;

  double get disponible {
    final d = limite - saldo;
    return d < 0 ? 0 : d;
  }

  bool alcanzaPara(double monto) => monto <= disponible;
}

/// Datos de cobro de la tienda: el número al que se yapea o plinea y el QR
/// que el tendero sube desde su app de banco. Uno solo por tienda.
class Tienda {
  const Tienda({
    this.nombre = 'Tienda de Barrio',
    this.numeroYape = '',
    this.numeroPlin = '',
    this.qrYapeUrl = '',
    this.qrPlinUrl = '',
  });

  final String nombre;
  final String numeroYape;
  final String numeroPlin;
  final String qrYapeUrl;
  final String qrPlinUrl;

  String numeroDe(MetodoPago metodo) =>
      metodo == MetodoPago.plin ? numeroPlin : numeroYape;

  String qrDe(MetodoPago metodo) =>
      metodo == MetodoPago.plin ? qrPlinUrl : qrYapeUrl;

  /// Un método solo se ofrece al cliente si hay a dónde pagarle: número o QR.
  bool aceptaPagoCon(MetodoPago metodo) =>
      numeroDe(metodo).isNotEmpty || qrDe(metodo).isNotEmpty;

  factory Tienda.desdeJson(Map<String, dynamic> j) => Tienda(
        nombre: (j['nombre'] ?? 'Tienda de Barrio') as String,
        numeroYape: (j['numero_yape'] ?? '') as String,
        numeroPlin: (j['numero_plin'] ?? '') as String,
        qrYapeUrl: (j['qr_yape_url'] ?? '') as String,
        qrPlinUrl: (j['qr_plin_url'] ?? '') as String,
      );

  Map<String, dynamic> aJson() => {
        'nombre': nombre,
        'numero_yape': numeroYape,
        'numero_plin': numeroPlin,
        'qr_yape_url': qrYapeUrl,
        'qr_plin_url': qrPlinUrl,
      };

  Tienda copiar({
    String? nombre,
    String? numeroYape,
    String? numeroPlin,
    String? qrYapeUrl,
    String? qrPlinUrl,
  }) =>
      Tienda(
        nombre: nombre ?? this.nombre,
        numeroYape: numeroYape ?? this.numeroYape,
        numeroPlin: numeroPlin ?? this.numeroPlin,
        qrYapeUrl: qrYapeUrl ?? this.qrYapeUrl,
        qrPlinUrl: qrPlinUrl ?? this.qrPlinUrl,
      );
}

/// Cada vez que entra o sale mercadería queda una fila aquí. El stock del
/// producto es el saldo de estos movimientos, y la caja es su suma en soles.
enum TipoMovimientoInventario {
  /// El tendero horneó / preparó: entran unidades y sale plata (el costo).
  produccion,

  /// Compró mercadería hecha a un proveedor.
  compra,

  /// Se vendió: salen unidades y entra plata.
  venta,

  /// Se malogró, se quemó o se venció: salen unidades y se pierde el costo.
  merma,

  /// Corrección de conteo. No mueve plata.
  ajuste,

  /// Pedido cancelado: vuelven las unidades y se descuenta el ingreso.
  devolucion,
}

extension TipoMovimientoInventarioX on TipoMovimientoInventario {
  /// Si suma o resta unidades al stock.
  bool get sumaStock =>
      this == TipoMovimientoInventario.produccion ||
      this == TipoMovimientoInventario.compra ||
      this == TipoMovimientoInventario.devolucion ||
      this == TipoMovimientoInventario.ajuste;
}

class MovimientoInventario {
  const MovimientoInventario({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.tipo,
    required this.unidades,
    required this.fecha,
    this.monto = 0,
    this.lotes = 0,
    this.nota = '',
    this.pedidoId,
    this.desdeInsumos = false,
  });

  final String id;
  final String productoId;

  /// Nombre congelado al momento del movimiento: el histórico no debe cambiar
  /// si mañana el tendero renombra el producto.
  final String productoNombre;

  final TipoMovimientoInventario tipo;

  /// Siempre positivo; el signo lo pone [tipo].
  final int unidades;

  /// Plata que movió: el ingreso si fue venta, el costo si fue producción,
  /// compra o merma. Un ajuste no mueve plata.
  final double monto;

  /// Lotes producidos, cuando el tendero contó en planchas y no en panes.
  final double lotes;

  final String nota;
  final DateTime fecha;
  final String? pedidoId;

  /// La producción se hizo gastando insumos ya comprados. En ese caso [monto]
  /// vale el lote pero no vuelve a salir de la caja: la plata salió cuando se
  /// compró la harina.
  final bool desdeInsumos;

  MovimientoInventario conId(String nuevoId) => MovimientoInventario(
        id: nuevoId,
        productoId: productoId,
        productoNombre: productoNombre,
        tipo: tipo,
        unidades: unidades,
        monto: monto,
        lotes: lotes,
        nota: nota,
        fecha: fecha,
        pedidoId: pedidoId,
        desdeInsumos: desdeInsumos,
      );

  /// Cuánto cambia el stock: +30 panes horneados, −4 vendidos.
  int get deltaStock => tipo.sumaStock ? unidades : -unidades;

  /// Plata que entró a la caja. La devolución la resta.
  double get ingreso => switch (tipo) {
        TipoMovimientoInventario.venta => monto,
        TipoMovimientoInventario.devolucion => -monto,
        _ => 0,
      };

  /// Plata que sale del bolsillo. Comprar mercadería hecha, sí. Producir con
  /// insumos que ya se pagaron, no: se contaría dos veces.
  double get egreso => switch (tipo) {
        TipoMovimientoInventario.compra => monto,
        TipoMovimientoInventario.produccion => desdeInsumos ? 0 : monto,
        _ => 0,
      };

  /// Valor de lo que se echó a perder. No es plata que sale, pero es plata
  /// que ya no vuelve.
  double get perdida =>
      tipo == TipoMovimientoInventario.merma ? monto : 0;

  factory MovimientoInventario.desdeJson(Map<String, dynamic> j) =>
      MovimientoInventario(
        id: j['id'] as String,
        productoId: (j['producto_id'] ?? '') as String,
        productoNombre: (j['producto_nombre'] ?? '') as String,
        tipo: _enumDesde(TipoMovimientoInventario.values, j['tipo'] as String?,
            TipoMovimientoInventario.ajuste),
        unidades: ((j['unidades'] as num?) ?? 0).toInt(),
        monto: ((j['monto'] as num?) ?? 0).toDouble(),
        lotes: ((j['lotes'] as num?) ?? 0).toDouble(),
        nota: (j['nota'] ?? '') as String,
        fecha: DateTime.parse(j['fecha'] as String).toLocal(),
        pedidoId: j['pedido_id'] as String?,
        desdeInsumos: (j['desde_insumos'] ?? false) as bool,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'producto_id': productoId,
        'producto_nombre': productoNombre,
        'tipo': tipo.name,
        'unidades': unidades,
        'monto': monto,
        'lotes': lotes,
        'nota': nota,
        'fecha': fecha.toUtc().toIso8601String(),
        'pedido_id': pedidoId,
        'desde_insumos': desdeInsumos,
      };
}

/// Lo vendido de un producto en el periodo consultado.
class LineaProducto {
  const LineaProducto({
    required this.productoNombre,
    required this.unidades,
    required this.ingreso,
  });

  final String productoNombre;
  final int unidades;
  final double ingreso;
}

/// Cuánto entró, cuánto salió y con qué se quedó el tendero en un periodo.
class ResumenCaja {
  const ResumenCaja({
    required this.desde,
    required this.hasta,
    required this.ingresos,
    required this.egresos,
    required this.unidadesVendidas,
    this.perdidas = 0,
    this.porProducto = const [],
  });

  final DateTime desde;
  final DateTime hasta;
  final double ingresos;
  final double egresos;
  final int unidadesVendidas;

  /// Valor de lo que se malogró. No sale de la caja —ya estaba pagado— pero
  /// se muestra aparte para que no pase desapercibido.
  final double perdidas;

  final List<LineaProducto> porProducto;

  double get utilidad => ingresos - egresos;
  bool get enGanancia => utilidad >= 0;

  /// Qué porcentaje de lo que entró se quedó como ganancia.
  double get margen => ingresos <= 0 ? 0 : (utilidad / ingresos) * 100;

  /// Arma el resumen a partir de los dos kardex: el de productos y el de
  /// insumos. Vive aquí, y no en cada repo, para que Supabase y el modo demo
  /// den exactamente el mismo número.
  factory ResumenCaja.desde(
    List<MovimientoInventario> movimientos, {
    required DateTime desde,
    required DateTime hasta,
    List<MovimientoInsumo> movimientosInsumo = const [],
  }) {
    var ingresos = 0.0;
    var egresos = 0.0;
    var perdidas = 0.0;
    var unidades = 0;
    final porProducto = <String, LineaProducto>{};

    for (final m in movimientosInsumo) {
      if (m.fecha.isBefore(desde) || m.fecha.isAfter(hasta)) continue;
      egresos += m.egreso;
      perdidas += m.perdida;
    }

    for (final m in movimientos) {
      if (m.fecha.isBefore(desde) || m.fecha.isAfter(hasta)) continue;
      ingresos += m.ingreso;
      egresos += m.egreso;
      perdidas += m.perdida;

      if (m.tipo == TipoMovimientoInventario.venta) {
        unidades += m.unidades;
        final previo = porProducto[m.productoNombre];
        porProducto[m.productoNombre] = LineaProducto(
          productoNombre: m.productoNombre,
          unidades: (previo?.unidades ?? 0) + m.unidades,
          ingreso: (previo?.ingreso ?? 0) + m.monto,
        );
      }
    }

    final lineas = porProducto.values.toList()
      ..sort((a, b) => b.ingreso.compareTo(a.ingreso));

    return ResumenCaja(
      desde: desde,
      hasta: hasta,
      ingresos: ingresos,
      egresos: egresos,
      unidadesVendidas: unidades,
      perdidas: perdidas,
      porProducto: lineas,
    );
  }
}

/// Materia prima que se consume para producir: harina, levadura, manteca.
/// No se vende al cliente, por eso vive aparte del catálogo.
///
/// Se compra en presentación (saco de 50 kg) pero se gasta en la unidad base
/// (kg). El stock y el costo siempre están en la unidad base.
class Insumo {
  const Insumo({
    required this.id,
    required this.nombre,
    required this.unidad,
    this.marca = '',
    this.stock = 0,
    this.costoUnitario = 0,
    this.nombrePresentacion = '',
    this.unidadesPorPresentacion = 0,
    this.stockMinimo = 0,
    this.activo = true,
  });

  final String id;
  final String nombre;
  final String marca;

  /// Unidad en la que se mide y se gasta: kg, g, L, ml, und.
  final String unidad;

  /// Cuánto queda, en [unidad].
  final double stock;

  /// Cuánto vale cada [unidad]. Es un promedio ponderado de lo comprado: si
  /// quedaban 20 kg a 3.60 y entran 50 kg a 4.00, el kilo pasa a 3.89.
  final double costoUnitario;

  /// Cómo se compra: "saco", "balde", "caja". Vacío si se compra suelto.
  final String nombrePresentacion;

  /// Cuántas [unidad] trae una presentación: un saco de harina, 50 kg.
  final double unidadesPorPresentacion;

  /// Avisar cuando el stock baje de aquí. 0 = sin aviso.
  final double stockMinimo;

  final bool activo;

  bool get sePorPresentacion =>
      nombrePresentacion.isNotEmpty && unidadesPorPresentacion > 0;

  /// Lo que cuesta una presentación entera al costo actual: el saco, S/ 180.
  double get costoPresentacion => costoUnitario * unidadesPorPresentacion;

  /// Cuántos sacos completos quedan en el almacén.
  double get presentacionesEnStock =>
      sePorPresentacion ? stock / unidadesPorPresentacion : 0;

  bool get bajoMinimo => stockMinimo > 0 && stock <= stockMinimo;

  String get nombreCompleto =>
      marca.isEmpty ? nombre : '$marca $nombre';

  /// Cómo se lee el stock: "112.5 kg" y, si aplica, "2.25 sacos".
  String get stockLegible {
    final base = '${_sinCeros(stock)} $unidad';
    if (!sePorPresentacion) return base;
    return '$base · ${_sinCeros(presentacionesEnStock)} $nombrePresentacion(s)';
  }

  factory Insumo.desdeJson(Map<String, dynamic> j) => Insumo(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        marca: (j['marca'] ?? '') as String,
        unidad: (j['unidad'] ?? 'kg') as String,
        stock: ((j['stock'] as num?) ?? 0).toDouble(),
        costoUnitario: ((j['costo_unitario'] as num?) ?? 0).toDouble(),
        nombrePresentacion: (j['nombre_presentacion'] ?? '') as String,
        unidadesPorPresentacion:
            ((j['unidades_por_presentacion'] as num?) ?? 0).toDouble(),
        stockMinimo: ((j['stock_minimo'] as num?) ?? 0).toDouble(),
        activo: (j['activo'] ?? true) as bool,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'marca': marca,
        'unidad': unidad,
        'stock': stock,
        'costo_unitario': costoUnitario,
        'nombre_presentacion': nombrePresentacion,
        'unidades_por_presentacion': unidadesPorPresentacion,
        'stock_minimo': stockMinimo,
        'activo': activo,
      };

  Insumo copiar({
    String? nombre,
    String? marca,
    String? unidad,
    double? stock,
    double? costoUnitario,
    String? nombrePresentacion,
    double? unidadesPorPresentacion,
    double? stockMinimo,
    bool? activo,
  }) =>
      Insumo(
        id: id,
        nombre: nombre ?? this.nombre,
        marca: marca ?? this.marca,
        unidad: unidad ?? this.unidad,
        stock: stock ?? this.stock,
        costoUnitario: costoUnitario ?? this.costoUnitario,
        nombrePresentacion: nombrePresentacion ?? this.nombrePresentacion,
        unidadesPorPresentacion:
            unidadesPorPresentacion ?? this.unidadesPorPresentacion,
        stockMinimo: stockMinimo ?? this.stockMinimo,
        activo: activo ?? this.activo,
      );

  Insumo conId(String nuevoId) => Insumo(
        id: nuevoId,
        nombre: nombre,
        marca: marca,
        unidad: unidad,
        stock: stock,
        costoUnitario: costoUnitario,
        nombrePresentacion: nombrePresentacion,
        unidadesPorPresentacion: unidadesPorPresentacion,
        stockMinimo: stockMinimo,
        activo: activo,
      );

  /// Costo promedio ponderado tras una compra. Es la razón de que el margen
  /// no salte de golpe cuando sube el precio del saco.
  Insumo conCompra({required double cantidad, required double montoTotal}) {
    final nuevoStock = stock + cantidad;
    if (nuevoStock <= 0) return copiar(stock: 0);
    final valorPrevio = stock * costoUnitario;
    return copiar(
      stock: nuevoStock,
      costoUnitario: (valorPrevio + montoTotal) / nuevoStock,
    );
  }
}

enum TipoMovimientoInsumo {
  /// Entró mercadería del proveedor: sube stock y sale plata.
  compra,

  /// Se gastó produciendo: baja stock. No mueve plata (ya se pagó al comprar).
  consumo,

  /// Se malogró o se derramó: baja stock y se pierde su valor.
  merma,

  /// Corrección de conteo.
  ajuste,
}

extension TipoMovimientoInsumoX on TipoMovimientoInsumo {
  bool get sumaStock =>
      this == TipoMovimientoInsumo.compra || this == TipoMovimientoInsumo.ajuste;
}

class MovimientoInsumo {
  const MovimientoInsumo({
    required this.id,
    required this.insumoId,
    required this.insumoNombre,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.monto = 0,
    this.presentaciones = 0,
    this.nota = '',
    this.produccionId,
  });

  final String id;
  final String insumoId;
  final String insumoNombre;
  final TipoMovimientoInsumo tipo;

  /// Siempre positiva, en la unidad base del insumo. El signo lo pone [tipo].
  final double cantidad;

  /// Plata: lo pagado en la compra, o el valor perdido en la merma.
  final double monto;

  /// Presentaciones compradas, cuando el tendero contó en sacos.
  final double presentaciones;

  final String nota;
  final DateTime fecha;

  /// Movimiento de producción que gastó este insumo, si vino de ahí.
  final String? produccionId;

  double get deltaStock => tipo.sumaStock ? cantidad : -cantidad;

  MovimientoInsumo conId(String nuevoId) => MovimientoInsumo(
        id: nuevoId,
        insumoId: insumoId,
        insumoNombre: insumoNombre,
        tipo: tipo,
        cantidad: cantidad,
        monto: monto,
        presentaciones: presentaciones,
        nota: nota,
        fecha: fecha,
        produccionId: produccionId,
      );

  /// Solo la compra saca plata del bolsillo. El consumo ya se pagó antes.
  double get egreso => tipo == TipoMovimientoInsumo.compra ? monto : 0;

  /// Valor de lo que se echó a perder. No es plata que sale, pero duele.
  double get perdida => tipo == TipoMovimientoInsumo.merma ? monto : 0;

  factory MovimientoInsumo.desdeJson(Map<String, dynamic> j) => MovimientoInsumo(
        id: j['id'] as String,
        insumoId: (j['insumo_id'] ?? '') as String,
        insumoNombre: (j['insumo_nombre'] ?? '') as String,
        tipo: _enumDesde(TipoMovimientoInsumo.values, j['tipo'] as String?,
            TipoMovimientoInsumo.ajuste),
        cantidad: ((j['cantidad'] as num?) ?? 0).toDouble(),
        monto: ((j['monto'] as num?) ?? 0).toDouble(),
        presentaciones: ((j['presentaciones'] as num?) ?? 0).toDouble(),
        nota: (j['nota'] ?? '') as String,
        fecha: DateTime.parse(j['fecha'] as String).toLocal(),
        produccionId: j['produccion_id'] as String?,
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'insumo_id': insumoId,
        'insumo_nombre': insumoNombre,
        'tipo': tipo.name,
        'cantidad': cantidad,
        'monto': monto,
        'presentaciones': presentaciones,
        'nota': nota,
        'fecha': fecha.toUtc().toIso8601String(),
        'produccion_id': produccionId,
      };
}

/// Una línea de la receta: cuánto de un insumo lleva un lote del producto.
/// "Una plancha de pan lleva 2 kg de harina."
class LineaReceta {
  const LineaReceta({
    required this.insumoId,
    required this.insumoNombre,
    required this.unidad,
    required this.cantidadPorLote,
    this.costoUnitario = 0,
  });

  final String insumoId;
  final String insumoNombre;
  final String unidad;
  final double cantidadPorLote;

  /// Costo del insumo al momento de leer la receta, para estimar el lote.
  final double costoUnitario;

  double costoPorLotes(double lotes) =>
      cantidadPorLote * lotes * costoUnitario;

  factory LineaReceta.desdeJson(Map<String, dynamic> j) => LineaReceta(
        insumoId: j['insumo_id'] as String,
        insumoNombre: (j['insumo_nombre'] ?? '') as String,
        unidad: (j['unidad'] ?? '') as String,
        cantidadPorLote: ((j['cantidad_por_lote'] as num?) ?? 0).toDouble(),
        costoUnitario: ((j['costo_unitario'] as num?) ?? 0).toDouble(),
      );

  Map<String, dynamic> aJson() => {
        'insumo_id': insumoId,
        'cantidad_por_lote': cantidadPorLote,
      };

  LineaReceta copiar({double? cantidadPorLote, double? costoUnitario}) =>
      LineaReceta(
        insumoId: insumoId,
        insumoNombre: insumoNombre,
        unidad: unidad,
        cantidadPorLote: cantidadPorLote ?? this.cantidadPorLote,
        costoUnitario: costoUnitario ?? this.costoUnitario,
      );
}

/// Lo que realmente se gastó de un insumo en una horneada concreta.
class ConsumoInsumo {
  const ConsumoInsumo({
    required this.insumoId,
    required this.insumoNombre,
    required this.unidad,
    required this.cantidad,
  });

  final String insumoId;
  final String insumoNombre;
  final String unidad;
  final double cantidad;

  ConsumoInsumo copiar({double? cantidad}) => ConsumoInsumo(
        insumoId: insumoId,
        insumoNombre: insumoNombre,
        unidad: unidad,
        cantidad: cantidad ?? this.cantidad,
      );
}

/// Resultado de una horneada: qué salió, qué costó y si rindió lo esperado.
class ResultadoProduccion {
  const ResultadoProduccion({
    required this.unidadesProducidas,
    required this.unidadesEsperadas,
    required this.costoTotal,
  });

  final int unidadesProducidas;

  /// Lo que debía salir según la receta y los lotes declarados.
  final int unidadesEsperadas;

  final double costoTotal;

  double get costoUnitario =>
      unidadesProducidas <= 0 ? 0 : costoTotal / unidadesProducidas;

  int get diferencia => unidadesProducidas - unidadesEsperadas;

  /// Qué tanto rindió respecto de lo esperado: 100% es justo lo previsto.
  double get rendimiento => unidadesEsperadas <= 0
      ? 100
      : (unidadesProducidas / unidadesEsperadas) * 100;

  bool get rindioMenos => unidadesEsperadas > 0 && diferencia < 0;
}

String _sinCeros(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
