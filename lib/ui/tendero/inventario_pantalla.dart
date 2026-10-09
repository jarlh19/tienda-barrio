import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../../core/config.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';
import 'escaner_pantalla.dart';
import 'insumos_pantalla.dart';
import 'movimiento_hoja.dart';
import 'receta_hoja.dart';

class InventarioPantalla extends ConsumerStatefulWidget {
  const InventarioPantalla({super.key});

  @override
  ConsumerState<InventarioPantalla> createState() => _InventarioPantallaState();
}

class _InventarioPantallaState extends ConsumerState<InventarioPantalla> {
  /// Dos almacenes distintos: lo que se vende y lo que se gasta produciendo.
  bool _verInsumos = false;

  @override
  Widget build(BuildContext context) {
    final inventario = ref.watch(inventarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(L.of(context).navInventario),
        actions: [
          IconButton(
            tooltip: _verInsumos
                ? L.of(context).nuevoInsumo
                : L.of(context).agregarSinCodigo,
            icon: const Icon(Icons.add),
            onPressed: () => _verInsumos
                ? abrirEditorInsumo(context, ref, null)
                : _abrirEditor(context, ref, null),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                    value: false, label: Text(L.of(context).segProductos)),
                ButtonSegment(
                    value: true, label: Text(L.of(context).segInsumos)),
              ],
              selected: {_verInsumos},
              onSelectionChanged: (s) => setState(() => _verInsumos = s.first),
            ),
          ),
        ),
      ),
      floatingActionButton: _verInsumos
          ? null
          : FloatingActionButton.extended(
              // Las pantallas del panel viven a la vez dentro de un IndexedStack:
              // sin tag propio, los botones flotantes chocan al cambiar de pestaña.
              heroTag: 'fab-inventario',
              onPressed: () => escanearYRegistrar(context, ref),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(L.of(context).escanear),
            ),
      body: _verInsumos
          ? const InsumosVista()
          : RefreshIndicator(
        onRefresh: () async => ref.invalidate(inventarioProvider),
        child: AsyncVista(
          valor: inventario,
          alReintentar: () => ref.invalidate(inventarioProvider),
          constructor: (lista) {
            if (lista.isEmpty) {
              return EstadoVacio(
                icono: Icons.inventory_2_outlined,
                titulo: L.of(context).inventarioVacio,
                detalle: L.of(context).inventarioVacioDetalle,
              );
            }
            final agotados = lista.where((p) => !p.hayStock && p.activo).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                if (agotados > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_outlined),
                        title:
                            Text(L.of(context).productosSinStock(agotados)),
                        subtitle:
                            Text(L.of(context).productosSinStockDetalle),
                      ),
                    ),
                  ),
                for (final p in lista)
                  _FilaProducto(
                    producto: p,
                    alEditar: () => _abrirEditor(context, ref, p),
                    alReponer: () => abrirHojaMovimiento(
                      context,
                      ref,
                      producto: p,
                      tipo: p.seProduce
                          ? TipoMovimientoInventario.produccion
                          : TipoMovimientoInventario.compra,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilaProducto extends StatelessWidget {
  const _FilaProducto({
    required this.producto,
    required this.alEditar,
    required this.alReponer,
  });

  final Producto producto;
  final VoidCallback alEditar;
  final VoidCallback alReponer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: alEditar,
        leading: IconButton(
          tooltip: producto.seProduce
              ? L.of(context).registrarProduccion
              : L.of(context).registrarCompra,
          icon: Icon(producto.seProduce
              ? Icons.bakery_dining_outlined
              : Icons.add_shopping_cart),
          onPressed: alReponer,
        ),
        title: Text(
          producto.nombreCompleto,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: producto.activo ? null : TextDecoration.lineThrough,
            color: producto.activo ? null : t.colorScheme.outline,
          ),
        ),
        subtitle: Text(
          L.of(context).productoResumen(
            Formato.soles(producto.precio),
            producto.unidad,
            producto.seVendePorPaquete
                ? L.of(context).productoPaqueteSufijo(
                    '${producto.unidadesPorPaquete}',
                    Formato.soles(producto.precioPaquete))
                : '',
            producto.costo > 0
                ? L.of(context).productoMargenSufijo(
                    Formato.soles(producto.margenUnitario))
                : '',
            producto.activo ? '' : L.of(context).productoBajaSufijo,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${producto.stock}',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: !producto.hayStock
                    ? t.colorScheme.error
                    : producto.stockBajo
                        ? t.colorScheme.tertiary
                        : null,
              ),
            ),
            Text(L.of(context).enStock, style: t.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Camino principal para dar de alta mercadería: se escanea el envase y la
/// app decide sola. Si el código ya existe abre ese producto para reponer
/// stock o corregir el precio; si es nuevo, abre el alta con el código puesto.
Future<void> escanearYRegistrar(BuildContext context, WidgetRef ref) async {
  final codigo = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const EscanerPantalla()),
  );
  if (codigo == null || !context.mounted) return;

  try {
    final existente = await ref.read(catalogoRepoProvider).porCodigoBarras(codigo);
    if (!context.mounted) return;

    if (existente == null) {
      await abrirAltaConCodigo(context, ref, codigo);
      return;
    }

    mostrarAviso(
      context,
      L.of(context).productoYaRegistrado(
          existente.nombreCompleto, Formato.cantidad(existente.stock)),
    );
    await _abrirEditor(context, ref, existente);
  } catch (e) {
    if (context.mounted) mostrarError(context, e);
  }
}

/// Alta de un producto que todavía no existe, con el código ya puesto.
Future<void> abrirAltaConCodigo(
  BuildContext context,
  WidgetRef ref,
  String codigo,
) =>
    _abrirEditor(context, ref, null, codigoBarras: codigo);

Future<void> _abrirEditor(
  BuildContext context,
  WidgetRef ref,
  Producto? producto, {
  String codigoBarras = '',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _EditorProducto(producto: producto, codigoBarras: codigoBarras),
    ),
  );
}

class _EditorProducto extends ConsumerStatefulWidget {
  const _EditorProducto({this.producto, this.codigoBarras = ''});

  final Producto? producto;

  /// Código recién escaneado, cuando el alta viene del escáner.
  final String codigoBarras;

  @override
  ConsumerState<_EditorProducto> createState() => _EditorProductoState();
}

class _EditorProductoState extends ConsumerState<_EditorProducto> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  late final TextEditingController _unidad;
  late final TextEditingController _imagen;
  late final TextEditingController _codigo;
  late final TextEditingController _marca;
  late final TextEditingController _contenido;
  late final TextEditingController _costo;
  late final TextEditingController _porLote;
  late final TextEditingController _nombreLote;
  late final TextEditingController _porPaquete;
  late String _medida;
  late String? _categoriaId;
  late bool _activo;
  bool _guardando = false;

  bool get _esNuevo => widget.producto == null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _precio = TextEditingController(text: p?.precio.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: (p?.stock ?? 0).toString());
    _unidad = TextEditingController(text: p?.unidad ?? 'und');
    _imagen = TextEditingController(text: p?.imagenUrl ?? '');
    _codigo = TextEditingController(
      text: p?.codigoBarras.isNotEmpty == true
          ? p!.codigoBarras
          : widget.codigoBarras,
    );
    _marca = TextEditingController(text: p?.marca ?? '');
    _contenido = TextEditingController(
      text: (p?.contenido ?? 0) > 0 ? Formato.cantidad(p!.contenido) : '',
    );
    _costo = TextEditingController(
      text: (p?.costo ?? 0) > 0 ? p!.costo.toStringAsFixed(2) : '',
    );
    _porLote = TextEditingController(
      text: (p?.unidadesPorLote ?? 0) > 0 ? '${p!.unidadesPorLote}' : '',
    );
    _nombreLote = TextEditingController(text: p?.nombreLote ?? '');
    _porPaquete = TextEditingController(
      text: (p?.unidadesPorPaquete ?? 0) > 1 ? '${p!.unidadesPorPaquete}' : '',
    );
    _medida = p?.medida.isNotEmpty == true ? p!.medida : 'und';
    _categoriaId = (p?.categoriaId.isEmpty ?? true) ? null : p!.categoriaId;
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    _unidad.dispose();
    _imagen.dispose();
    _codigo.dispose();
    _marca.dispose();
    _contenido.dispose();
    _costo.dispose();
    _porLote.dispose();
    _nombreLote.dispose();
    _porPaquete.dispose();
    super.dispose();
  }

  Future<void> _escanearCodigo() async {
    final codigo = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const EscanerPantalla()),
    );
    if (codigo != null && mounted) _codigo.text = codigo;
  }

  /// Un código pertenece a un solo producto: si ya está en otro, avisamos en
  /// vez de dejar dos filas que el escáner no podría distinguir.
  Future<String?> _duenoDelCodigo(String codigo) async {
    if (codigo.isEmpty) return null;
    final otro = await ref.read(catalogoRepoProvider).porCodigoBarras(codigo);
    if (otro == null || otro.id == widget.producto?.id) return null;
    return otro.nombre;
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final ocupadoPor = await _duenoDelCodigo(_codigo.text.trim());
      if (ocupadoPor != null) {
        if (mounted) {
          mostrarAviso(context, L.of(context).codigoYaEsDe(ocupadoPor));
        }
        return;
      }
      await ref.read(catalogoRepoProvider).guardarProducto(
            Producto(
              id: widget.producto?.id ?? '',
              nombre: _nombre.text.trim(),
              precio: double.parse(_precio.text.replaceAll(',', '.')),
              stock: int.parse(_stock.text),
              categoriaId: _categoriaId ?? '',
              marca: _marca.text.trim(),
              contenido:
                  double.tryParse(_contenido.text.replaceAll(',', '.')) ?? 0,
              medida: _contenido.text.trim().isEmpty ? '' : _medida,
              costo: double.tryParse(_costo.text.replaceAll(',', '.')) ?? 0,
              unidadesPorLote: int.tryParse(_porLote.text.trim()) ?? 0,
              nombreLote: _nombreLote.text.trim().isEmpty
                  ? (int.tryParse(_porLote.text.trim()) != null ? 'lote' : '')
                  : _nombreLote.text.trim(),
              unidadesPorPaquete: int.tryParse(_porPaquete.text.trim()) ?? 0,
              unidad: _unidad.text.trim().isEmpty ? 'und' : _unidad.text.trim(),
              imagenUrl: _imagen.text.trim(),
              codigoBarras: _codigo.text.trim(),
              activo: _activo,
            ),
          );
      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
      mostrarAviso(
          context,
          _esNuevo
              ? L.of(context).productoAgregado
              : L.of(context).productoActualizado);
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _darDeBaja() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(L.of(context).darDeBajaPregunta),
        content: Text(L.of(context).darDeBajaDetalle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L.of(context).no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(L.of(context).darDeBaja),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await ref
          .read(catalogoRepoProvider)
          .eliminarProducto(widget.producto!.id);
      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider).valueOrNull ?? const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _esNuevo
                    ? L.of(context).nuevoProducto
                    : L.of(context).editarProducto,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    InputDecoration(labelText: L.of(context).campoNombre),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? L.of(context).validaEscribeNombre
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marca,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: L.of(context).campoMarca,
                  hintText: L.of(context).marcaEjemplo,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codigo,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: L.of(context).escanearCodigoBarras,
                  helperText: L.of(context).codigoBarrasVacio,
                  prefixIcon: const Icon(Icons.barcode_reader),
                  suffixIcon: IconButton(
                    tooltip: L.of(context).escanear,
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _escanearCodigo,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precio,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: L.of(context).campoPrecio,
                        prefixText: '${Config.simboloMoneda} ',
                      ),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                        if (n == null || n <= 0) {
                          return L.of(context).precioInvalido;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costo,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: L.of(context).campoCosto,
                        prefixText: '${Config.simboloMoneda} ',
                        helperText: L.of(context).costoHelper,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        return (n == null || n < 0)
                            ? L.of(context).costoInvalido
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: L.of(context).campoStock,
                  helperText: _esNuevo
                      ? L.of(context).stockHelperNuevo
                      : L.of(context).stockHelperExistente,
                ),
                // Ya existiendo, el stock se mueve por el kardex: se deja ver
                // pero no se edita a mano, para que caja e inventario cuadren.
                enabled: _esNuevo,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return L.of(context).stockInvalido;
                  return null;
                },
              ),
              _BloqueVenta(porPaquete: _porPaquete, precio: _precio),
              _BloqueProduccion(porLote: _porLote, nombreLote: _nombreLote),
              if (!_esNuevo)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        abrirEditorReceta(context, ref, widget.producto!),
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(L.of(context).recetaBoton),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unidad,
                      decoration: InputDecoration(
                        labelText: L.of(context).campoUnidad,
                        hintText: L.of(context).unidadEjemplo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _categoriaId,
                      isExpanded: true,
                      decoration: InputDecoration(
                          labelText: L.of(context).campoCategoria),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(L.of(context).sinCategoria),
                        ),
                        for (final c in categorias)
                          DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text('${c.emoji} ${c.nombre}'.trim()),
                          ),
                      ],
                      onChanged: (v) => setState(() => _categoriaId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contenido,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: L.of(context).campoPesoVolumen,
                        hintText: '900',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        return (n == null || n <= 0)
                            ? L.of(context).cantidadInvalida
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _medida,
                      decoration:
                          InputDecoration(labelText: L.of(context).campoMedida),
                      items: const [
                        DropdownMenuItem(value: 'und', child: Text('und')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'L', child: Text('L')),
                      ],
                      onChanged: (v) => setState(() => _medida = v ?? 'und'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagen,
                decoration: InputDecoration(
                  labelText: L.of(context).campoFotoUrl,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
                title: Text(L.of(context).visibleEnCatalogo),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(_esNuevo
                    ? L.of(context).agregar
                    : L.of(context).guardar),
              ),
              if (!_esNuevo)
                TextButton(
                  onPressed: _guardando ? null : _darDeBaja,
                  child: Text(L.of(context).darDeBaja),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Presentación de venta: "4 panes por S/ 1.00". El precio guardado sigue
/// siendo el unitario; el paquete es solo cómo lo pide el cliente.
class _BloqueVenta extends StatefulWidget {
  const _BloqueVenta({required this.porPaquete, required this.precio});

  final TextEditingController porPaquete;
  final TextEditingController precio;

  @override
  State<_BloqueVenta> createState() => _BloqueVentaState();
}

class _BloqueVentaState extends State<_BloqueVenta> {
  @override
  Widget build(BuildContext context) {
    final unidades = int.tryParse(widget.porPaquete.text.trim()) ?? 0;
    final precio =
        double.tryParse(widget.precio.text.replaceAll(',', '.')) ?? 0;
    final total = unidades * precio;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: widget.porPaquete,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: L.of(context).seVendeDeA,
          prefixIcon: const Icon(Icons.sell_outlined),
          helperText: unidades > 1 && total > 0
              ? L.of(context)
                  .seMostrara('$unidades', Formato.soles(total))
              : L.of(context).seVendeDeAEjemplo,
        ),
      ),
    );
  }
}

/// Producción por lotes: una plancha da 30 panes.
class _BloqueProduccion extends StatefulWidget {
  const _BloqueProduccion({required this.porLote, required this.nombreLote});

  final TextEditingController porLote;
  final TextEditingController nombreLote;

  @override
  State<_BloqueProduccion> createState() => _BloqueProduccionState();
}

class _BloqueProduccionState extends State<_BloqueProduccion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.porLote,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: L.of(context).unidadesPorLote,
                helperText: L.of(context).unidadesPorLoteEjemplo,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: widget.nombreLote,
              decoration: InputDecoration(
                labelText: L.of(context).nombreDelLote,
                hintText: L.of(context).nombreDelLoteEjemplo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
