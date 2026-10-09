import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config.dart';
import '../datos/modelos/modelos.dart';
import '../datos/repos/memoria.dart';
import '../datos/repos/pasarela.dart';
import '../datos/repos/repos.dart';
import '../datos/repos/supabase_repos.dart';

// --- Repositorios ---------------------------------------------------------
// Un único punto decide si la app habla con Supabase o con el almacén demo.

final _almacenProvider = Provider((ref) => AlmacenMemoria.instancia);

SupabaseClient get _sb => Supabase.instance.client;

final authRepoProvider = Provider<AuthRepo>((ref) => Config.hayBackend
    ? SbAuthRepo(_sb)
    : MemAuthRepo(ref.watch(_almacenProvider)));

final catalogoRepoProvider = Provider<CatalogoRepo>((ref) => Config.hayBackend
    ? SbCatalogoRepo(_sb)
    : MemCatalogoRepo(ref.watch(_almacenProvider)));

final pedidosRepoProvider = Provider<PedidosRepo>((ref) => Config.hayBackend
    ? SbPedidosRepo(_sb)
    : MemPedidosRepo(ref.watch(_almacenProvider)));

final fiadoRepoProvider = Provider<FiadoRepo>((ref) => Config.hayBackend
    ? SbFiadoRepo(_sb)
    : MemFiadoRepo(ref.watch(_almacenProvider)));

final inventarioRepoProvider = Provider<InventarioRepo>((ref) => Config.hayBackend
    ? SbInventarioRepo(_sb)
    : MemInventarioRepo(ref.watch(_almacenProvider)));

final insumosRepoProvider = Provider<InsumosRepo>((ref) => Config.hayBackend
    ? SbInsumosRepo(_sb)
    : MemInsumosRepo(ref.watch(_almacenProvider)));

final tiendaRepoProvider = Provider<TiendaRepo>((ref) => Config.hayBackend
    ? SbTiendaRepo(_sb)
    : MemTiendaRepo(ref.watch(_almacenProvider)));

/// Cambiar esta línea es lo único que hace falta para enchufar una pasarela real.
final pasarelaProvider = Provider<PasarelaPago>((ref) => const PagoLocal());

// --- Sesión ---------------------------------------------------------------

class SesionNotifier extends Notifier<Perfil?> {
  StreamSubscription<Perfil?>? _sub;

  @override
  Perfil? build() {
    final repo = ref.watch(authRepoProvider);
    _sub = repo.cambios.listen((p) => state = p);
    ref.onDispose(() => _sub?.cancel());
    return repo.perfilActual;
  }

  Future<void> iniciarSesion(String email, String clave) async {
    state = await ref.read(authRepoProvider).iniciarSesion(
          email: email,
          clave: clave,
        );
  }

  /// Entra con la cuenta de Google del dispositivo. Devuelve `false` si no hay
  /// sesión todavía: el usuario cerró el selector, o en web la entrada sigue
  /// por redirección y el perfil llegará solo por el stream.
  Future<bool> entrarConGoogle() async {
    final p = await ref.read(authRepoProvider).entrarConGoogle();
    if (p != null) state = p;
    return p != null;
  }

  Future<void> registrar({
    required String nombre,
    required String email,
    required String clave,
    String telefono = '',
    String direccion = '',
  }) async {
    state = await ref.read(authRepoProvider).registrar(
          nombre: nombre,
          email: email,
          clave: clave,
          telefono: telefono,
          direccion: direccion,
        );
  }

  Future<void> guardar(Perfil perfil) async {
    state = await ref.read(authRepoProvider).guardarPerfil(perfil);
  }

  Future<void> cerrarSesion() async {
    await ref.read(authRepoProvider).cerrarSesion();
    state = null;
  }
}

final sesionProvider =
    NotifierProvider<SesionNotifier, Perfil?>(SesionNotifier.new);

/// Si mostrar o no el botón de Google: depende de la plataforma y de que el ID
/// de cliente esté configurado.
final hayGoogleProvider =
    Provider<bool>((ref) => ref.watch(authRepoProvider).hayGoogle);

// --- Catálogo -------------------------------------------------------------

final categoriasProvider = FutureProvider<List<Categoria>>(
    (ref) => ref.watch(catalogoRepoProvider).categorias());

final filtroCategoriaProvider = StateProvider<String?>((ref) => null);
final busquedaProvider = StateProvider<String>((ref) => '');

/// Catálogo que ve el cliente: filtrado por categoría y búsqueda.
final productosProvider = FutureProvider<List<Producto>>((ref) {
  final categoria = ref.watch(filtroCategoriaProvider);
  final busqueda = ref.watch(busquedaProvider);
  return ref.watch(catalogoRepoProvider).productos(
        categoriaId: categoria,
        busqueda: busqueda,
      );
});

/// Inventario completo del tendero: incluye productos dados de baja.
final inventarioProvider = FutureProvider<List<Producto>>((ref) =>
    ref.watch(catalogoRepoProvider).productos(soloActivos: false));

// --- Pedidos --------------------------------------------------------------

final misPedidosProvider = FutureProvider<List<Pedido>>((ref) {
  final perfil = ref.watch(sesionProvider);
  if (perfil == null) return Future.value(const []);
  return ref.watch(pedidosRepoProvider).deCliente(perfil.id);
});

final pedidosTiendaProvider = StreamProvider<List<Pedido>>(
    (ref) => ref.watch(pedidosRepoProvider).flujoTodos());

// --- Fiado ----------------------------------------------------------------

final miCuentaFiadoProvider = FutureProvider<CuentaFiado?>((ref) {
  final perfil = ref.watch(sesionProvider);
  if (perfil == null) return Future.value(null);
  return ref.watch(fiadoRepoProvider).cuenta(perfil.id);
});

final cuentasFiadoProvider = FutureProvider<List<CuentaFiado>>(
    (ref) => ref.watch(fiadoRepoProvider).cuentas());

// --- Caja: ingresos y egresos ---------------------------------------------

/// Periodo que se está mirando en la pantalla de Caja.
enum Periodo { hoy, semana, mes }

extension PeriodoX on Periodo {
  /// Desde cuándo cuenta el periodo. El día arranca a las 00:00, no hace 24 h:
  /// el tendero cierra caja por día calendario, no por reloj.
  DateTime get desde {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return switch (this) {
      Periodo.hoy => hoy,
      Periodo.semana => hoy.subtract(const Duration(days: 6)),
      Periodo.mes => DateTime(ahora.year, ahora.month, 1),
    };
  }
}

final periodoCajaProvider = StateProvider<Periodo>((ref) => Periodo.hoy);

final movimientosProvider = FutureProvider<List<MovimientoInventario>>((ref) {
  final periodo = ref.watch(periodoCajaProvider);
  return ref.watch(inventarioRepoProvider).movimientos(desde: periodo.desde);
});

final movimientosInsumoProvider =
    FutureProvider<List<MovimientoInsumo>>((ref) {
  final periodo = ref.watch(periodoCajaProvider);
  return ref.watch(insumosRepoProvider).movimientos(desde: periodo.desde);
});

/// Cuánto entró, cuánto salió y cuánto quedó en el periodo elegido.
final resumenCajaProvider = FutureProvider<ResumenCaja>((ref) async {
  final periodo = ref.watch(periodoCajaProvider);
  final movimientos = await ref.watch(movimientosProvider.future);
  final deInsumos = await ref.watch(movimientosInsumoProvider.future);
  return ResumenCaja.desde(
    movimientos,
    movimientosInsumo: deInsumos,
    desde: periodo.desde,
    hasta: DateTime.now(),
  );
});

/// Insumos activos: lo que hay en el almacén para producir.
final insumosProvider =
    FutureProvider<List<Insumo>>((ref) => ref.watch(insumosRepoProvider).insumos());

/// Receta de un producto: cuánto de cada insumo lleva un lote.
final recetaProvider = FutureProvider.family<List<LineaReceta>, String>(
    (ref, productoId) => ref.watch(insumosRepoProvider).receta(productoId));

// --- Tienda ---------------------------------------------------------------

/// Datos de cobro que el cliente necesita al pagar: números y QR de Yape/Plin.
final tiendaProvider =
    FutureProvider<Tienda>((ref) => ref.watch(tiendaRepoProvider).obtener());

/// Refresca todo lo que depende del backend tras una operación de escritura.
/// Hay dos entradas porque `Ref` (providers) y `WidgetRef` (widgets) no
/// comparten tipo, pero sí la firma de `invalidate`.
void _invalidarTodo(void Function(ProviderOrFamily) invalidar) {
  invalidar(productosProvider);
  invalidar(inventarioProvider);
  invalidar(misPedidosProvider);
  invalidar(miCuentaFiadoProvider);
  invalidar(cuentasFiadoProvider);
  invalidar(tiendaProvider);
  invalidar(movimientosProvider);
  invalidar(movimientosInsumoProvider);
  invalidar(insumosProvider);
  invalidar(resumenCajaProvider);
}

void refrescarTodo(WidgetRef ref) => _invalidarTodo(ref.invalidate);

void refrescarTodoDesdeProvider(Ref ref) => _invalidarTodo(ref.invalidate);
