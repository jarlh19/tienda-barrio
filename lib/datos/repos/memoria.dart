import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../../core/config.dart';
import '../modelos/modelos.dart';
import 'repos.dart';

String _id() {
  final r = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
}

/// Almacén compartido del modo demo: todo vive en RAM y se pierde al cerrar.
/// Existe para poder recorrer la app completa sin backend configurado.
class AlmacenMemoria {
  AlmacenMemoria._() {
    _sembrar();
  }

  static final AlmacenMemoria instancia = AlmacenMemoria._();

  final List<Perfil> perfiles = [];
  final List<Categoria> categorias = [];
  final List<Producto> productos = [];
  final List<Pedido> pedidos = [];
  final List<MovimientoFiado> movimientos = [];
  final List<MovimientoInventario> movimientosInventario = [];
  final List<Insumo> insumos = [];
  final List<MovimientoInsumo> movimientosInsumo = [];
  final Map<String, List<LineaReceta>> recetas = {};
  final Map<String, double> limites = {};

  Tienda tienda = const Tienda(
    numeroYape: '999 888 777',
    numeroPlin: '999 888 777',
  );

  final _pedidosCtrl = StreamController<List<Pedido>>.broadcast();
  Stream<List<Pedido>> get flujoPedidos => _pedidosCtrl.stream;

  /// Unico lugar donde cambia el stock en el modo demo: asi el saldo del
  /// producto y el kardex nunca se separan.
  void moverStock(String productoId, int delta) {
    final i = productos.indexWhere((p) => p.id == productoId);
    if (i < 0) return;
    final restante = productos[i].stock + delta;
    productos[i] = productos[i].copiar(stock: restante < 0 ? 0 : restante);
  }

  /// Aplica un movimiento del kardex: lo guarda y mueve el saldo.
  void registrarMovimientoInventario(MovimientoInventario m) {
    final conId = m.id.isEmpty ? m.conId(_id()) : m;
    movimientosInventario.add(conId);
    moverStock(conId.productoId, conId.deltaStock);
  }

  /// Aplica un movimiento de insumo: lo guarda, mueve el stock y —si fue
  /// compra— recalcula el costo promedio del kilo.
  MovimientoInsumo registrarMovimientoInsumo(MovimientoInsumo m) {
    final conId = m.id.isEmpty ? m.conId(_id()) : m;
    movimientosInsumo.add(conId);

    final i = insumos.indexWhere((x) => x.id == conId.insumoId);
    if (i < 0) return conId;

    if (conId.tipo == TipoMovimientoInsumo.compra) {
      insumos[i] = insumos[i]
          .conCompra(cantidad: conId.cantidad, montoTotal: conId.monto);
    } else {
      final restante = insumos[i].stock + conId.deltaStock;
      insumos[i] = insumos[i].copiar(stock: restante < 0 ? 0 : restante);
    }
    return conId;
  }

  void notificarPedidos() {
    final copia = List<Pedido>.from(pedidos)
      ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
    _pedidosCtrl.add(copia);
  }

  void _sembrar() {
    perfiles.addAll(const [
      Perfil(
        id: 'u-tendero',
        nombre: 'Doña Rosa',
        rol: Rol.tendero,
        telefono: '999888777',
        direccion: 'Av. Los Álamos 120',
      ),
      Perfil(
        id: 'u-cliente',
        nombre: 'Jorge',
        rol: Rol.cliente,
        telefono: '987654321',
        direccion: 'Jr. Las Flores 45, Dpto 302',
      ),
      Perfil(
        id: 'u-cliente-2',
        nombre: 'Sra. Elena',
        rol: Rol.cliente,
        telefono: '955443322',
        direccion: 'Calle Union 88',
      ),
    ]);

    categorias.addAll(const [
      Categoria(id: 'c1', nombre: 'Abarrotes', emoji: '🥫'),
      Categoria(id: 'c2', nombre: 'Bebidas', emoji: '🥤'),
      Categoria(id: 'c3', nombre: 'Limpieza', emoji: '🧼'),
      Categoria(id: 'c4', nombre: 'Snacks', emoji: '🍪'),
      Categoria(id: 'c5', nombre: 'Panadería', emoji: '🥖'),
    ]);

    productos.addAll(const [
      Producto(
          id: 'p1',
          nombre: 'Arroz extra',
          precio: 4.50,
          stock: 30,
          categoriaId: 'c1',
          unidad: 'bolsa',
          descripcion: 'Arroz extra, grano largo.',
          codigoBarras: '7750243011408',
          marca: 'Costeño',
          contenido: 1.0,
          medida: 'kg'),
      Producto(
          id: 'p2',
          nombre: 'Aceite vegetal',
          precio: 9.90,
          stock: 12,
          categoriaId: 'c1',
          unidad: 'botella',
          codigoBarras: '7750106000132',
          marca: 'Primor',
          contenido: 900.0,
          medida: 'ml'),
      Producto(
          id: 'p3',
          nombre: 'Azúcar rubia',
          precio: 4.20,
          stock: 18,
          categoriaId: 'c1',
          unidad: 'bolsa',
          codigoBarras: '7750243000105',
          contenido: 1.0,
          medida: 'kg'),
      Producto(
          id: 'p4',
          nombre: 'Leche evaporada',
          precio: 4.30,
          stock: 24,
          categoriaId: 'c1',
          unidad: 'lata',
          codigoBarras: '7750885000101',
          marca: 'Gloria',
          contenido: 395.0,
          medida: 'g'),
      Producto(
          id: 'p5',
          nombre: 'Gaseosa',
          precio: 7.50,
          stock: 9,
          categoriaId: 'c2',
          unidad: 'botella',
          codigoBarras: '7750182001155',
          marca: 'Inca Kola',
          contenido: 1.5,
          medida: 'L'),
      Producto(
          id: 'p6',
          nombre: 'Agua sin gas',
          precio: 1.80,
          stock: 40,
          categoriaId: 'c2',
          unidad: 'botella',
          codigoBarras: '7750182002015',
          marca: 'San Luis',
          contenido: 625.0,
          medida: 'ml'),
      Producto(
          id: 'p7',
          nombre: 'Cerveza',
          precio: 8.00,
          stock: 4,
          categoriaId: 'c2',
          unidad: 'botella',
          codigoBarras: '7750144000162',
          marca: 'Pilsen',
          contenido: 650.0,
          medida: 'ml'),
      Producto(
          id: 'p8',
          nombre: 'Detergente',
          precio: 11.50,
          stock: 7,
          categoriaId: 'c3',
          unidad: 'bolsa',
          codigoBarras: '7750520000228',
          marca: 'Bolívar',
          contenido: 780.0,
          medida: 'g'),
      Producto(
          id: 'p9',
          nombre: 'Lejía',
          precio: 5.90,
          stock: 0,
          categoriaId: 'c3',
          unidad: 'botella',
          codigoBarras: '7751158000105',
          marca: 'Clorox',
          contenido: 1.0,
          medida: 'L'),
      Producto(
          id: 'p10',
          nombre: 'Papel higiénico x4',
          precio: 6.90,
          stock: 15,
          categoriaId: 'c3',
          unidad: 'paquete',
          codigoBarras: '7750670000114',
          marca: 'Suave'),
      Producto(
          id: 'p11',
          nombre: 'Galletas',
          precio: 1.50,
          stock: 50,
          categoriaId: 'c4',
          unidad: 'paquete',
          codigoBarras: '7622300861575',
          marca: 'Oreo',
          contenido: 36.0,
          medida: 'g'),
      Producto(
          id: 'p12',
          nombre: 'Chizitos',
          precio: 3.50,
          stock: 22,
          categoriaId: 'c4',
          unidad: 'bolsa',
          codigoBarras: '7750106001238',
          marca: 'Karinto',
          contenido: 130.0,
          medida: 'g'),
      Producto(
          id: 'p13',
          nombre: 'Pan francés',
          precio: 0.25,
          stock: 80,
          categoriaId: 'c5',
          unidad: 'und',
          descripcion: 'Recién horneado cada mañana.',
          costo: 0.12,
          unidadesPorLote: 30,
          nombreLote: 'plancha',
          unidadesPorPaquete: 4),
      Producto(
          id: 'p14',
          nombre: 'Pan de yema',
          precio: 0.50,
          stock: 35,
          categoriaId: 'c5',
          unidad: 'und',
          costo: 0.22,
          unidadesPorLote: 24,
          nombreLote: 'plancha',
          unidadesPorPaquete: 2),
    ]);

    insumos.addAll(const [
      Insumo(
        id: 'i1',
        nombre: 'Harina',
        marca: 'Nicolini',
        unidad: 'kg',
        stock: 100,
        costoUnitario: 3.60,
        nombrePresentacion: 'saco',
        unidadesPorPresentacion: 50,
        stockMinimo: 25,
      ),
      Insumo(
        id: 'i2',
        nombre: 'Levadura',
        unidad: 'kg',
        stock: 2,
        costoUnitario: 14.00,
        nombrePresentacion: 'bolsa',
        unidadesPorPresentacion: 0.5,
        stockMinimo: 0.5,
      ),
      Insumo(
        id: 'i3',
        nombre: 'Manteca',
        unidad: 'kg',
        stock: 8,
        costoUnitario: 7.50,
        nombrePresentacion: 'balde',
        unidadesPorPresentacion: 4,
      ),
      Insumo(
        id: 'i4',
        nombre: 'Sal',
        unidad: 'kg',
        stock: 5,
        costoUnitario: 1.20,
        nombrePresentacion: 'bolsa',
        unidadesPorPresentacion: 1,
      ),
    ]);

    // Receta de una plancha de pan francés (30 panes).
    recetas['p13'] = const [
      LineaReceta(
          insumoId: 'i1',
          insumoNombre: 'Nicolini Harina',
          unidad: 'kg',
          cantidadPorLote: 2),
      LineaReceta(
          insumoId: 'i2',
          insumoNombre: 'Levadura',
          unidad: 'kg',
          cantidadPorLote: 0.04),
      LineaReceta(
          insumoId: 'i3',
          insumoNombre: 'Manteca',
          unidad: 'kg',
          cantidadPorLote: 0.1),
      LineaReceta(
          insumoId: 'i4',
          insumoNombre: 'Sal',
          unidad: 'kg',
          cantidadPorLote: 0.04),
    ];

    limites['u-cliente'] = 150;
    limites['u-cliente-2'] = 80;

    movimientos.addAll([
      MovimientoFiado(
        id: _id(),
        clienteId: 'u-cliente-2',
        tipo: TipoMovimiento.cargo,
        monto: 32.50,
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        descripcion: 'Compra del sábado',
      ),
      MovimientoFiado(
        id: _id(),
        clienteId: 'u-cliente-2',
        tipo: TipoMovimiento.abono,
        monto: 20,
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        descripcion: 'Abono en efectivo',
      ),
    ]);

    pedidos.add(Pedido(
      id: _id(),
      clienteId: 'u-cliente-2',
      clienteNombre: 'Sra. Elena',
      creadoEn: DateTime.now().subtract(const Duration(minutes: 25)),
      estado: EstadoPedido.pendiente,
      metodoPago: MetodoPago.efectivo,
      direccion: 'Calle Union 88',
      items: const [
        ItemPedido(
            productoId: 'p13',
            nombre: 'Pan francés',
            precioUnitario: 0.25,
            cantidad: 10),
        ItemPedido(
            productoId: 'p4',
            nombre: 'Gloria Leche evaporada 395 g',
            precioUnitario: 4.30,
            cantidad: 2),
      ],
    ));
  }
}

class MemAuthRepo implements AuthRepo {
  MemAuthRepo(this._a);

  final AlmacenMemoria _a;
  final _ctrl = StreamController<Perfil?>.broadcast();
  Perfil? _actual;

  @override
  Stream<Perfil?> get cambios => _ctrl.stream;

  @override
  Perfil? get perfilActual => _actual;

  void _entrar(Perfil p) {
    _actual = p;
    _ctrl.add(p);
  }

  @override
  Future<Perfil> iniciarSesion(
      {required String email, required String clave}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // En demo el correo elige el rol: cualquier cosa con "tendero" entra
    // como dueño de la tienda; el resto, como cliente.
    final esTendero = email.toLowerCase().contains('tendero');
    final p = _a.perfiles.firstWhere(
      (x) => esTendero ? x.rol == Rol.tendero : x.id == 'u-cliente',
      orElse: () => _a.perfiles.first,
    );
    _entrar(p);
    return p;
  }

  /// En demo no hay Google de verdad: no hay a quién pedirle el token ni quién
  /// lo valide. El botón sigue la misma regla que en producción —aparece solo
  /// si hay ID de cliente configurado— y si aparece entra como el vecino de
  /// ejemplo, para poder recorrer el flujo sin backend.
  @override
  bool get hayGoogle => Config.hayGoogle;

  @override
  Future<Perfil?> entrarConGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final p = _a.perfiles.firstWhere(
      (x) => x.id == 'u-cliente',
      orElse: () => _a.perfiles.first,
    );
    _entrar(p);
    return p;
  }

  @override
  Future<Perfil> registrar({
    required String nombre,
    required String email,
    required String clave,
    String telefono = '',
    String direccion = '',
    Rol rol = Rol.cliente,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final p = Perfil(
      id: _id(),
      nombre: nombre,
      rol: rol,
      telefono: telefono,
      direccion: direccion,
    );
    _a.perfiles.add(p);
    _a.limites[p.id] = 100;
    _entrar(p);
    return p;
  }

  @override
  Future<void> cerrarSesion() async {
    _actual = null;
    _ctrl.add(null);
  }

  @override
  Future<Perfil> guardarPerfil(Perfil perfil) async {
    final i = _a.perfiles.indexWhere((x) => x.id == perfil.id);
    if (i >= 0) _a.perfiles[i] = perfil;
    if (_actual?.id == perfil.id) _entrar(perfil);
    return perfil;
  }

  @override
  Future<List<Perfil>> clientes() async =>
      _a.perfiles.where((p) => p.rol == Rol.cliente).toList();
}

class MemCatalogoRepo implements CatalogoRepo {
  MemCatalogoRepo(this._a);

  final AlmacenMemoria _a;

  @override
  Future<List<Categoria>> categorias() async => List.of(_a.categorias);

  @override
  Future<List<Producto>> productos({
    String? categoriaId,
    String busqueda = '',
    bool soloActivos = true,
  }) async {
    final q = busqueda.trim().toLowerCase();
    return _a.productos.where((p) {
      if (soloActivos && !p.activo) return false;
      if (categoriaId != null && p.categoriaId != categoriaId) return false;
      if (q.isNotEmpty &&
          !p.nombreCompleto.toLowerCase().contains(q) &&
          p.codigoBarras != q) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));
  }

  @override
  Future<Producto?> porCodigoBarras(String codigo) async {
    final buscado = codigo.trim();
    if (buscado.isEmpty) return null;
    for (final p in _a.productos) {
      if (p.codigoBarras == buscado) return p;
    }
    return null;
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    final i = _a.productos.indexWhere((p) => p.id == producto.id);
    if (i >= 0) {
      _a.productos[i] = producto;
      return producto;
    }
    final nuevo = producto.id.isEmpty ? producto.conId(_id()) : producto;
    _a.productos.add(nuevo);
    return nuevo;
  }

  @override
  Future<void> eliminarProducto(String id) async {
    _a.productos.removeWhere((p) => p.id == id);
  }
}

class MemPedidosRepo implements PedidosRepo {
  MemPedidosRepo(this._a);

  final AlmacenMemoria _a;

  @override
  Future<Pedido> crear(Pedido pedido) async {
    final nuevo = pedido.id.isEmpty
        ? Pedido(
            id: _id(),
            clienteId: pedido.clienteId,
            clienteNombre: pedido.clienteNombre,
            items: pedido.items,
            creadoEn: pedido.creadoEn,
            estado: pedido.estado,
            metodoPago: pedido.metodoPago,
            estadoPago: pedido.estadoPago,
            referenciaPago: pedido.referenciaPago,
            direccion: pedido.direccion,
            notas: pedido.notas,
          )
        : pedido;
    _a.pedidos.add(nuevo);

    // La deuda del fiado la anota quien guarda el pedido, igual que el trigger
    // en Supabase: el cliente no escribe su propia cuenta.
    if (nuevo.metodoPago == MetodoPago.fiado) {
      _a.movimientos.add(MovimientoFiado(
        id: _id(),
        clienteId: nuevo.clienteId,
        tipo: TipoMovimiento.cargo,
        monto: nuevo.total,
        fecha: nuevo.creadoEn,
        descripcion: 'Pedido ${nuevo.codigo}',
        pedidoId: nuevo.id,
      ));
    }

    // La venta entra al kardex: descuenta stock y suma a la caja, igual que
    // hace el trigger en Supabase.
    for (final item in nuevo.items) {
      _a.registrarMovimientoInventario(MovimientoInventario(
        id: '',
        productoId: item.productoId,
        productoNombre: item.nombre,
        tipo: TipoMovimientoInventario.venta,
        unidades: item.cantidad,
        monto: item.subtotal,
        fecha: nuevo.creadoEn,
        nota: 'Pedido ${nuevo.codigo}',
        pedidoId: nuevo.id,
      ));
    }
    _a.notificarPedidos();
    return nuevo;
  }

  @override
  Future<List<Pedido>> deCliente(String clienteId) async =>
      (_a.pedidos.where((p) => p.clienteId == clienteId).toList())
        ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

  @override
  Future<List<Pedido>> todos() async => List.of(_a.pedidos)
    ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));

  @override
  Stream<List<Pedido>> flujoTodos() async* {
    yield await todos();
    yield* _a.flujoPedidos;
  }

  Pedido _actualizar(String id, Pedido Function(Pedido) f) {
    final i = _a.pedidos.indexWhere((p) => p.id == id);
    if (i < 0) throw ErrorApp('El pedido ya no existe.');
    final actualizado = f(_a.pedidos[i]);
    _a.pedidos[i] = actualizado;
    _a.notificarPedidos();
    return actualizado;
  }

  @override
  Future<Pedido> cambiarEstado(String pedidoId, EstadoPedido estado) async {
    final antes = _a.pedidos.firstWhere((p) => p.id == pedidoId,
        orElse: () => throw ErrorApp('El pedido ya no existe.'));
    final despues = _actualizar(pedidoId, (p) => p.copiar(estado: estado));

    // Al cancelar vuelve la mercadería y se descuenta lo que se había contado
    // como ingreso; sin esto la caja del día quedaría inflada.
    if (estado == EstadoPedido.cancelado &&
        antes.estado != EstadoPedido.cancelado) {
      if (despues.metodoPago == MetodoPago.fiado) {
        _a.movimientos.add(MovimientoFiado(
          id: _id(),
          clienteId: despues.clienteId,
          tipo: TipoMovimiento.abono,
          monto: despues.total,
          fecha: DateTime.now(),
          descripcion: 'Pedido ${despues.codigo} cancelado',
          pedidoId: despues.id,
        ));
      }

      for (final item in despues.items) {
        _a.registrarMovimientoInventario(MovimientoInventario(
          id: '',
          productoId: item.productoId,
          productoNombre: item.nombre,
          tipo: TipoMovimientoInventario.devolucion,
          unidades: item.cantidad,
          monto: item.subtotal,
          fecha: DateTime.now(),
          nota: 'Pedido ${despues.codigo} cancelado',
          pedidoId: despues.id,
        ));
      }
    }
    return despues;
  }

  @override
  Future<Pedido> cambiarEstadoPago(
    String pedidoId,
    EstadoPago estado, {
    String? referencia,
  }) async =>
      _actualizar(pedidoId,
          (p) => p.copiar(estadoPago: estado, referenciaPago: referencia));
}

class MemFiadoRepo implements FiadoRepo {
  MemFiadoRepo(this._a);

  final AlmacenMemoria _a;

  CuentaFiado _armar(Perfil cliente) {
    final movs = _a.movimientos.where((m) => m.clienteId == cliente.id).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final saldo = movs.fold<double>(0, (s, m) => s + m.efecto);
    return CuentaFiado(
      clienteId: cliente.id,
      clienteNombre: cliente.nombre,
      saldo: saldo < 0 ? 0 : saldo,
      limite: _a.limites[cliente.id] ?? 100,
      movimientos: movs,
    );
  }

  @override
  Future<CuentaFiado> cuenta(String clienteId) async {
    final cliente = _a.perfiles.firstWhere(
      (p) => p.id == clienteId,
      orElse: () => throw ErrorApp('Cliente no encontrado.'),
    );
    return _armar(cliente);
  }

  @override
  Future<List<CuentaFiado>> cuentas() async =>
      _a.perfiles.where((p) => p.rol == Rol.cliente).map(_armar).toList()
        ..sort((a, b) => b.saldo.compareTo(a.saldo));

  @override
  Future<void> registrarMovimiento(MovimientoFiado movimiento) async {
    _a.movimientos.add(
      movimiento.id.isEmpty
          ? MovimientoFiado(
              id: _id(),
              clienteId: movimiento.clienteId,
              tipo: movimiento.tipo,
              monto: movimiento.monto,
              fecha: movimiento.fecha,
              descripcion: movimiento.descripcion,
              pedidoId: movimiento.pedidoId,
            )
          : movimiento,
    );
  }

  @override
  Future<void> cambiarLimite(String clienteId, double limite) async {
    _a.limites[clienteId] = limite;
  }
}

class MemTiendaRepo implements TiendaRepo {
  MemTiendaRepo(this._a);

  final AlmacenMemoria _a;

  @override
  Future<Tienda> obtener() async => _a.tienda;

  @override
  Future<Tienda> guardar(Tienda tienda) async => _a.tienda = tienda;

  @override
  Future<String> subirQr({
    required MetodoPago metodo,
    required Uint8List bytes,
    required String extension,
  }) async {
    // Sin Storage detrás, el QR viaja como data URI: se ve igual en pantalla
    // y desaparece al cerrar la app, como todo en el modo demo.
    final tipo = extension == 'png' ? 'image/png' : 'image/jpeg';
    return 'data:$tipo;base64,${base64Encode(bytes)}';
  }
}

class MemInventarioRepo implements InventarioRepo {
  MemInventarioRepo(this._a);

  final AlmacenMemoria _a;

  @override
  Future<MovimientoInventario> registrar(MovimientoInventario movimiento) async {
    final m = movimiento.id.isEmpty ? movimiento.conId(_id()) : movimiento;
    _a.movimientosInventario.add(m);
    _a.moverStock(m.productoId, m.deltaStock);
    return m;
  }

  @override
  Future<List<MovimientoInventario>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? productoId,
    int limite = 500,
  }) async {
    final filtrados = _a.movimientosInventario.where((m) {
      if (productoId != null && m.productoId != productoId) return false;
      if (desde != null && m.fecha.isBefore(desde)) return false;
      if (hasta != null && m.fecha.isAfter(hasta)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    // El modo demo respeta el mismo límite que Supabase: si no, la interfaz
    // prometería un tope que solo cumple la mitad de las implementaciones.
    return filtrados.length <= limite ? filtrados : filtrados.sublist(0, limite);
  }
}

class MemInsumosRepo implements InsumosRepo {
  MemInsumosRepo(this._a);

  final AlmacenMemoria _a;

  @override
  Future<List<Insumo>> insumos({bool soloActivos = true}) async =>
      _a.insumos.where((i) => !soloActivos || i.activo).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));

  @override
  Future<Insumo> guardar(Insumo insumo) async {
    final i = _a.insumos.indexWhere((x) => x.id == insumo.id);
    if (i >= 0) {
      _a.insumos[i] = insumo;
      return insumo;
    }
    final nuevo = insumo.id.isEmpty ? insumo.conId(_id()) : insumo;
    _a.insumos.add(nuevo);
    return nuevo;
  }

  @override
  Future<void> darDeBaja(String insumoId) async {
    final i = _a.insumos.indexWhere((x) => x.id == insumoId);
    if (i >= 0) _a.insumos[i] = _a.insumos[i].copiar(activo: false);
  }

  @override
  Future<MovimientoInsumo> registrarMovimiento(
      MovimientoInsumo movimiento) async {
    return _a.registrarMovimientoInsumo(movimiento);
  }

  @override
  Future<List<MovimientoInsumo>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? insumoId,
    int limite = 500,
  }) async {
    final filtrados = _a.movimientosInsumo.where((m) {
      if (insumoId != null && m.insumoId != insumoId) return false;
      if (desde != null && m.fecha.isBefore(desde)) return false;
      if (hasta != null && m.fecha.isAfter(hasta)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    // El modo demo respeta el mismo límite que Supabase: si no, la interfaz
    // prometería un tope que solo cumple la mitad de las implementaciones.
    return filtrados.length <= limite ? filtrados : filtrados.sublist(0, limite);
  }

  @override
  Future<List<LineaReceta>> receta(String productoId) async {
    final lineas = _a.recetas[productoId] ?? const <LineaReceta>[];
    // El costo se lee del insumo en este momento, no de cuando se guardó la
    // receta: así la estimación usa el precio de hoy.
    return lineas.map((l) {
      final insumo = _a.insumos.where((i) => i.id == l.insumoId).firstOrNull;
      if (insumo == null) return l;
      return LineaReceta(
        insumoId: insumo.id,
        insumoNombre: insumo.nombreCompleto,
        unidad: insumo.unidad,
        cantidadPorLote: l.cantidadPorLote,
        costoUnitario: insumo.costoUnitario,
      );
    }).toList();
  }

  @override
  Future<void> guardarReceta(String productoId, List<LineaReceta> lineas) async {
    _a.recetas[productoId] = List.of(lineas);
  }

  @override
  Future<ResultadoProduccion> registrarProduccion({
    required Producto producto,
    required double lotes,
    required int unidadesProducidas,
    required List<ConsumoInsumo> consumos,
    String nota = '',
  }) async {
    if (unidadesProducidas <= 0) {
      throw ErrorApp('Indica cuántas unidades salieron.');
    }

    // Primero se comprueba que alcance todo: mejor no empezar que dejar el
    // inventario a medio descontar.
    for (final c in consumos) {
      final insumo = _a.insumos.where((i) => i.id == c.insumoId).firstOrNull;
      if (insumo == null) throw ErrorApp('Ese insumo ya no existe.');
      if (c.cantidad > insumo.stock) {
        throw ErrorApp(
          'No alcanza ${insumo.nombreCompleto}: '
          'quedan ${insumo.stock.toStringAsFixed(2)} ${insumo.unidad} '
          'y necesitas ${c.cantidad.toStringAsFixed(2)}.',
        );
      }
    }

    var costoTotal = 0.0;
    final produccionId = _id();

    for (final c in consumos) {
      if (c.cantidad <= 0) continue;
      final insumo = _a.insumos.firstWhere((i) => i.id == c.insumoId);
      final costo = insumo.costoUnitario * c.cantidad;
      costoTotal += costo;

      _a.registrarMovimientoInsumo(MovimientoInsumo(
        id: '',
        insumoId: insumo.id,
        insumoNombre: insumo.nombreCompleto,
        tipo: TipoMovimientoInsumo.consumo,
        cantidad: c.cantidad,
        monto: costo,
        fecha: DateTime.now(),
        nota: nota,
        produccionId: produccionId,
      ));
    }

    _a.registrarMovimientoInventario(MovimientoInventario(
      id: produccionId,
      productoId: producto.id,
      productoNombre: producto.nombreCompleto,
      tipo: TipoMovimientoInventario.produccion,
      unidades: unidadesProducidas,
      monto: costoTotal,
      lotes: lotes,
      nota: nota,
      fecha: DateTime.now(),
      desdeInsumos: consumos.any((c) => c.cantidad > 0),
    ));

    // El costo del producto queda al de esta horneada: si subió la harina, el
    // margen que ve el tendero se entera hoy, no el mes que viene.
    final idx = _a.productos.indexWhere((p) => p.id == producto.id);
    if (idx >= 0 && costoTotal > 0) {
      _a.productos[idx] = _a.productos[idx]
          .copiar(costo: costoTotal / unidadesProducidas);
    }

    return ResultadoProduccion(
      unidadesProducidas: unidadesProducidas,
      unidadesEsperadas: (producto.unidadesPorLote * lotes).round(),
      costoTotal: costoTotal,
    );
  }
}
