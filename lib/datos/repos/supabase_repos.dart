import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../modelos/modelos.dart';
import 'repos.dart';

/// Implementación real contra Supabase. El esquema está en `supabase/schema.sql`.

Map<String, dynamic> _fila(dynamic e) => Map<String, dynamic>.from(e as Map);

/// Palabras que delatan un error técnico de Postgres. Los mensajes de los
/// triggers propios ("Tu cupo de fiado no alcanza") sí se muestran; los que
/// hablan de relaciones, columnas o permisos se cambian por uno genérico
/// para no filtrarle al usuario la forma de la base.
const _jergaDeBase = [
  'relation',
  'column',
  'violates',
  'constraint',
  'permission denied',
  'syntax',
  'null value',
  'duplicate key',
];

bool _esTecnico(String mensaje) {
  final m = mensaje.toLowerCase();
  return _jergaDeBase.any(m.contains);
}

Never _traducir(Object e) {
  if (e is ErrorApp) throw e;
  if (e is AuthException) throw ErrorApp(e.message);
  if (e is PostgrestException) {
    throw ErrorApp(_esTecnico(e.message)
        ? 'No se pudo completar la operación.'
        : e.message);
  }
  throw ErrorApp('No se pudo conectar con la tienda. Revisa tu internet.');
}

/// El texto de búsqueda entra en un filtro de PostgREST, donde la coma y el
/// paréntesis son sintaxis. Se dejan solo letras, números y espacios: buscar
/// no debería poder reescribir la consulta.
String _saneado(String texto) =>
    texto.replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), '').trim();

class SbAuthRepo implements AuthRepo {
  SbAuthRepo(this._c);

  final SupabaseClient _c;
  Perfil? _actual;

  @override
  Perfil? get perfilActual => _actual;

  @override
  Stream<Perfil?> get cambios =>
      _c.auth.onAuthStateChange.asyncMap((evento) async {
        final usuario = evento.session?.user;
        if (usuario == null) {
          _actual = null;
          return null;
        }
        _actual = await _perfilDe(usuario.id);
        return _actual;
      });

  Future<Perfil> _perfilDe(String id) async {
    final fila =
        await _c.from('perfiles').select().eq('id', id).maybeSingle();
    if (fila == null) throw ErrorApp('Tu perfil aún no está creado.');
    return Perfil.desdeJson(_fila(fila));
  }

  @override
  Future<Perfil> iniciarSesion(
      {required String email, required String clave}) async {
    try {
      final res = await _c.auth
          .signInWithPassword(email: email.trim(), password: clave);
      final id = res.user?.id;
      if (id == null) throw ErrorApp('Correo o contraseña incorrectos.');
      return _actual = await _perfilDe(id);
    } catch (e) {
      _traducir(e);
    }
  }

  /// Mientras la app no esté registrada en Google Cloud esto es falso y el
  /// botón no se muestra (ADR-0005).
  @override
  bool get hayGoogle => Config.hayGoogle;

  @override
  Future<Perfil?> entrarConGoogle() async {
    try {
      // Sin la dependencia nativa la entrada la arma Supabase: manda a Google
      // fuera de la app y vuelve por redirección, así que aquí no hay perfil
      // que devolver — llega después por `cambios`. El selector de cuentas del
      // sistema vuelve cuando se reinstale `google_sign_in`.
      await _c.auth.signInWithOAuth(OAuthProvider.google);
      return null;
    } catch (e) {
      _traducir(e);
    }
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
    try {
      final res = await _c.auth.signUp(
        email: email.trim(),
        password: clave,
        data: {
          'nombre': nombre,
          'telefono': telefono,
          'direccion': direccion,
          'rol': rol.name,
        },
      );
      final id = res.user?.id;
      if (id == null) {
        throw ErrorApp('Revisa tu correo para confirmar la cuenta.');
      }
      // El trigger `crear_perfil` inserta la fila; la leemos para tener el rol
      // real (nunca confiamos en el metadata del cliente para permisos).
      return _actual = await _perfilDe(id);
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> cerrarSesion() async {
    await _c.auth.signOut();
    _actual = null;
  }

  @override
  Future<Perfil> guardarPerfil(Perfil perfil) async {
    try {
      final fila = await _c
          .from('perfiles')
          .update({
            'nombre': perfil.nombre,
            'telefono': perfil.telefono,
            'direccion': perfil.direccion,
          })
          .eq('id', perfil.id)
          .select()
          .single();
      return _actual = Perfil.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<Perfil>> clientes() async {
    try {
      final filas =
          await _c.from('perfiles').select().eq('rol', 'cliente').order('nombre');
      return (filas as List).map((e) => Perfil.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbCatalogoRepo implements CatalogoRepo {
  SbCatalogoRepo(this._c);

  final SupabaseClient _c;

  @override
  Future<List<Categoria>> categorias() async {
    try {
      final filas = await _c.from('categorias').select().order('nombre');
      return (filas as List).map((e) => Categoria.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<Producto>> productos({
    String? categoriaId,
    String busqueda = '',
    bool soloActivos = true,
  }) async {
    try {
      // El cliente lee la vista `catalogo`, que no expone costo ni receta; el
      // tendero (soloActivos: false) lee la tabla completa.
      var q = _c.from(soloActivos ? 'catalogo' : 'productos').select();
      if (categoriaId != null) q = q.eq('categoria_id', categoriaId);
      final texto = _saneado(busqueda);
      if (texto.isNotEmpty) {
        q = q.or('nombre.ilike.%$texto%,marca.ilike.%$texto%');
      }
      final filas = await q.order('nombre');
      return (filas as List).map((e) => Producto.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Producto?> porCodigoBarras(String codigo) async {
    final buscado = codigo.trim();
    if (buscado.isEmpty) return null;
    try {
      final fila = await _c
          .from('productos')
          .select()
          .eq('codigo_barras', buscado)
          .maybeSingle();
      return fila == null ? null : Producto.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Producto> guardarProducto(Producto producto) async {
    try {
      final datos = producto.aJson()..remove('id');
      final fila = producto.id.isEmpty
          ? await _c.from('productos').insert(datos).select().single()
          : await _c
              .from('productos')
              .update(datos)
              .eq('id', producto.id)
              .select()
              .single();
      return Producto.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> eliminarProducto(String id) async {
    try {
      // Baja lógica: los pedidos viejos siguen mostrando el producto.
      await _c.from('productos').update({'activo': false}).eq('id', id);
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbPedidosRepo implements PedidosRepo {
  SbPedidosRepo(this._c);

  final SupabaseClient _c;

  @override
  Future<Pedido> crear(Pedido pedido) async {
    try {
      final datos = pedido.aJson()
        ..remove('id')
        ..remove('total'); // columna generada en la base
      final fila = await _c.from('pedidos').insert(datos).select().single();
      return Pedido.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<Pedido>> deCliente(String clienteId) async {
    try {
      final filas = await _c
          .from('pedidos')
          .select()
          .eq('cliente_id', clienteId)
          .order('creado_en', ascending: false);
      return (filas as List).map((e) => Pedido.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<Pedido>> todos() async {
    try {
      final filas =
          await _c.from('pedidos').select().order('creado_en', ascending: false);
      return (filas as List).map((e) => Pedido.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Stream<List<Pedido>> flujoTodos() => _c
      .from('pedidos')
      .stream(primaryKey: ['id'])
      .order('creado_en', ascending: false)
      .map((filas) => filas.map((e) => Pedido.desdeJson(_fila(e))).toList());

  @override
  Future<Pedido> cambiarEstado(String pedidoId, EstadoPedido estado) async {
    try {
      final fila = await _c
          .from('pedidos')
          .update({'estado': estado.name})
          .eq('id', pedidoId)
          .select()
          .single();
      return Pedido.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Pedido> cambiarEstadoPago(
    String pedidoId,
    EstadoPago estado, {
    String? referencia,
  }) async {
    try {
      final datos = <String, dynamic>{'estado_pago': estado.name};
      if (referencia != null) datos['referencia_pago'] = referencia;
      final fila = await _c
          .from('pedidos')
          .update(datos)
          .eq('id', pedidoId)
          .select()
          .single();
      return Pedido.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbFiadoRepo implements FiadoRepo {
  SbFiadoRepo(this._c);

  final SupabaseClient _c;

  CuentaFiado _armar(
    Map<String, dynamic> perfil,
    List<MovimientoFiado> movimientos,
  ) {
    final saldo = movimientos.fold<double>(0, (s, m) => s + m.efecto);
    return CuentaFiado(
      clienteId: perfil['id'] as String,
      clienteNombre: (perfil['nombre'] ?? '') as String,
      saldo: saldo < 0 ? 0 : saldo,
      limite: ((perfil['limite_fiado'] as num?) ?? 100).toDouble(),
      movimientos: movimientos,
    );
  }

  Future<List<MovimientoFiado>> _movimientosDe(String clienteId) async {
    final filas = await _c
        .from('movimientos_fiado')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha', ascending: false);
    return (filas as List)
        .map((e) => MovimientoFiado.desdeJson(_fila(e)))
        .toList();
  }

  @override
  Future<CuentaFiado> cuenta(String clienteId) async {
    try {
      final perfil = await _c
          .from('perfiles')
          .select()
          .eq('id', clienteId)
          .maybeSingle();
      if (perfil == null) throw ErrorApp('Cliente no encontrado.');
      return _armar(_fila(perfil), await _movimientosDe(clienteId));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<CuentaFiado>> cuentas() async {
    try {
      // Dos consultas, no una por cliente: con 40 clientes el panel hacía 41
      // viajes a la base cada vez que se abría la pestaña de fiado.
      final filas =
          await _c.from('perfiles').select().eq('rol', 'cliente').order('nombre');
      final todos = await _c
          .from('movimientos_fiado')
          .select()
          .order('fecha', ascending: false);

      final porCliente = <String, List<MovimientoFiado>>{};
      for (final e in todos as List) {
        final m = MovimientoFiado.desdeJson(_fila(e));
        porCliente.putIfAbsent(m.clienteId, () => []).add(m);
      }

      final cuentas = [
        for (final f in filas as List)
          _armar(_fila(f), porCliente[_fila(f)['id']] ?? const []),
      ]..sort((a, b) => b.saldo.compareTo(a.saldo));
      return cuentas;
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> registrarMovimiento(MovimientoFiado movimiento) async {
    try {
      await _c
          .from('movimientos_fiado')
          .insert(movimiento.aJson()..remove('id'));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> cambiarLimite(String clienteId, double limite) async {
    try {
      await _c
          .from('perfiles')
          .update({'limite_fiado': limite}).eq('id', clienteId);
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbTiendaRepo implements TiendaRepo {
  SbTiendaRepo(this._c);

  final SupabaseClient _c;

  /// La tienda es una sola: fila fija para no tener que buscarla.
  static const _id = 1;
  static const _bucket = 'tienda';

  @override
  Future<Tienda> obtener() async {
    try {
      final fila =
          await _c.from('tienda').select().eq('id', _id).maybeSingle();
      return fila == null ? const Tienda() : Tienda.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Tienda> guardar(Tienda tienda) async {
    try {
      final fila = await _c
          .from('tienda')
          .upsert({'id': _id, ...tienda.aJson()})
          .select()
          .single();
      return Tienda.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<String> subirQr({
    required MetodoPago metodo,
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      // Nombre fijo por método: subir un QR nuevo reemplaza al anterior en vez
      // de ir dejando basura en el bucket.
      final ruta = 'qr-${metodo.name}.$extension';
      await _c.storage.from(_bucket).uploadBinary(
            ruta,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      final url = _c.storage.from(_bucket).getPublicUrl(ruta);
      // El parámetro rompe la caché para que el cliente vea el QR nuevo.
      return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbInventarioRepo implements InventarioRepo {
  SbInventarioRepo(this._c);

  final SupabaseClient _c;

  @override
  Future<MovimientoInventario> registrar(MovimientoInventario movimiento) async {
    try {
      // El trigger `aplicar_movimiento` mueve el stock del producto: se hace
      // en la base para que saldo y kardex no puedan quedar desfasados.
      final fila = await _c
          .from('movimientos_inventario')
          .insert(movimiento.aJson()..remove('id'))
          .select()
          .single();
      return MovimientoInventario.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<MovimientoInventario>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? productoId,
    int limite = 500,
  }) async {
    try {
      var q = _c.from('movimientos_inventario').select();
      if (productoId != null) q = q.eq('producto_id', productoId);
      if (desde != null) q = q.gte('fecha', desde.toUtc().toIso8601String());
      if (hasta != null) q = q.lte('fecha', hasta.toUtc().toIso8601String());
      final filas = await q.order('fecha', ascending: false).limit(limite);
      return (filas as List)
          .map((e) => MovimientoInventario.desdeJson(_fila(e)))
          .toList();
    } catch (e) {
      _traducir(e);
    }
  }
}

class SbInsumosRepo implements InsumosRepo {
  SbInsumosRepo(this._c);

  final SupabaseClient _c;

  @override
  Future<List<Insumo>> insumos({bool soloActivos = true}) async {
    try {
      var q = _c.from('insumos').select();
      if (soloActivos) q = q.eq('activo', true);
      final filas = await q.order('nombre');
      return (filas as List).map((e) => Insumo.desdeJson(_fila(e))).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<Insumo> guardar(Insumo insumo) async {
    try {
      final datos = insumo.aJson()..remove('id');
      final fila = insumo.id.isEmpty
          ? await _c.from('insumos').insert(datos).select().single()
          : await _c
              .from('insumos')
              .update(datos)
              .eq('id', insumo.id)
              .select()
              .single();
      return Insumo.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> darDeBaja(String insumoId) async {
    try {
      await _c.from('insumos').update({'activo': false}).eq('id', insumoId);
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<MovimientoInsumo> registrarMovimiento(
      MovimientoInsumo movimiento) async {
    try {
      // El trigger `aplicar_movimiento_insumo` mueve el stock y recalcula el
      // costo promedio: se hace en la base para que no puedan desfasarse.
      final fila = await _c
          .from('movimientos_insumo')
          .insert(movimiento.aJson()..remove('id'))
          .select()
          .single();
      return MovimientoInsumo.desdeJson(_fila(fila));
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<MovimientoInsumo>> movimientos({
    DateTime? desde,
    DateTime? hasta,
    String? insumoId,
    int limite = 500,
  }) async {
    try {
      var q = _c.from('movimientos_insumo').select();
      if (insumoId != null) q = q.eq('insumo_id', insumoId);
      if (desde != null) q = q.gte('fecha', desde.toUtc().toIso8601String());
      if (hasta != null) q = q.lte('fecha', hasta.toUtc().toIso8601String());
      final filas = await q.order('fecha', ascending: false).limit(limite);
      return (filas as List)
          .map((e) => MovimientoInsumo.desdeJson(_fila(e)))
          .toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<List<LineaReceta>> receta(String productoId) async {
    try {
      // Se trae el insumo junto con la línea para leer su costo de hoy.
      final filas = await _c
          .from('recetas')
          .select('cantidad_por_lote, insumos(id, nombre, marca, unidad, costo_unitario)')
          .eq('producto_id', productoId);

      return (filas as List).map((e) {
        final fila = _fila(e);
        final insumo = Insumo.desdeJson(_fila(fila['insumos']));
        return LineaReceta(
          insumoId: insumo.id,
          insumoNombre: insumo.nombreCompleto,
          unidad: insumo.unidad,
          cantidadPorLote: (fila['cantidad_por_lote'] as num).toDouble(),
          costoUnitario: insumo.costoUnitario,
        );
      }).toList();
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<void> guardarReceta(String productoId, List<LineaReceta> lineas) async {
    try {
      // Se reemplaza entera: es más simple de razonar que ir diferenciando
      // qué línea se agregó, cambió o se quitó.
      await _c.from('recetas').delete().eq('producto_id', productoId);
      if (lineas.isEmpty) return;
      await _c.from('recetas').insert([
        for (final l in lineas)
          {
            'producto_id': productoId,
            'insumo_id': l.insumoId,
            'cantidad_por_lote': l.cantidadPorLote,
          }
      ]);
    } catch (e) {
      _traducir(e);
    }
  }

  @override
  Future<ResultadoProduccion> registrarProduccion({
    required Producto producto,
    required double lotes,
    required int unidadesProducidas,
    required List<ConsumoInsumo> consumos,
    String nota = '',
  }) async {
    try {
      // Una sola llamada: la función en la base descuenta los insumos, mete
      // las unidades y actualiza el costo dentro de la misma transacción.
      final fila = await _c.rpc('registrar_produccion', params: {
        'p_producto_id': producto.id,
        'p_producto_nombre': producto.nombreCompleto,
        'p_lotes': lotes,
        'p_unidades': unidadesProducidas,
        'p_nota': nota,
        'p_consumos': [
          for (final c in consumos)
            if (c.cantidad > 0)
              {'insumo_id': c.insumoId, 'cantidad': c.cantidad}
        ],
      });

      final datos = _fila(fila);
      return ResultadoProduccion(
        unidadesProducidas: unidadesProducidas,
        unidadesEsperadas: (producto.unidadesPorLote * lotes).round(),
        costoTotal: ((datos['costo_total'] as num?) ?? 0).toDouble(),
      );
    } catch (e) {
      _traducir(e);
    }
  }
}
