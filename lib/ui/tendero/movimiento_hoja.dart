import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../comun/widgets.dart';

Future<void> abrirHojaMovimiento(
  BuildContext context,
  WidgetRef ref, {
  Producto? producto,
  TipoMovimientoInventario tipo = TipoMovimientoInventario.produccion,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _HojaMovimiento(productoInicial: producto, tipoInicial: tipo),
    ),
  );
}

/// Registrar lo que entra y lo que sale: una plancha horneada, una compra al
/// proveedor, lo que se vendió en el mostrador o lo que se malogró.
class _HojaMovimiento extends ConsumerStatefulWidget {
  const _HojaMovimiento({this.productoInicial, required this.tipoInicial});

  final Producto? productoInicial;
  final TipoMovimientoInventario tipoInicial;

  @override
  ConsumerState<_HojaMovimiento> createState() => _HojaMovimientoState();
}

class _HojaMovimientoState extends ConsumerState<_HojaMovimiento> {
  final _cantidad = TextEditingController(text: '1');
  final _monto = TextEditingController();
  final _nota = TextEditingController();

  late TipoMovimientoInventario _tipo = widget.tipoInicial;
  Producto? _producto;
  bool _porLotes = true;
  bool _montoEditado = false;
  bool _guardando = false;

  /// Lo que se va a gastar de cada insumo. Arranca con lo que dice la receta
  /// y el tendero lo corrige si esa horneada salió distinta.
  final Map<String, TextEditingController> _consumos = {};
  List<LineaReceta> _receta = const [];

  /// Tipos que el tendero registra a mano. La devolución la genera la app
  /// sola cuando se cancela un pedido.
  static const _tipos = [
    TipoMovimientoInventario.produccion,
    TipoMovimientoInventario.compra,
    TipoMovimientoInventario.venta,
    TipoMovimientoInventario.merma,
    TipoMovimientoInventario.ajuste,
  ];

  @override
  void initState() {
    super.initState();
    _producto = widget.productoInicial;
    _cantidad.addListener(_recalcularMonto);
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _monto.dispose();
    _nota.dispose();
    for (final c in _consumos.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Trae la receta del producto y prellena el consumo según los lotes.
  Future<void> _cargarReceta() async {
    final p = _producto;
    if (p == null || _tipo != TipoMovimientoInventario.produccion) {
      setState(() => _receta = const []);
      return;
    }
    try {
      final lineas = await ref.read(insumosRepoProvider).receta(p.id);
      if (!mounted) return;
      setState(() {
        _receta = lineas;
        for (final c in _consumos.values) {
          c.dispose();
        }
        _consumos.clear();
        for (final l in lineas) {
          _consumos[l.insumoId] = TextEditingController()
            ..addListener(() => setState(() {}));
        }
      });
      _recalcularConsumos();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  /// Los lotes mandan sobre el consumo sugerido: 2 planchas, 4 kg de harina.
  void _recalcularConsumos() {
    if (_receta.isEmpty) return;
    final lotes = _lotesDeclarados;
    for (final l in _receta) {
      final ctrl = _consumos[l.insumoId];
      if (ctrl == null) continue;
      final sugerido = l.cantidadPorLote * lotes;
      ctrl.text = sugerido <= 0 ? '' : Formato.cantidad(sugerido, decimales: 3);
    }
    setState(() {});
  }

  /// Cuántos lotes se hicieron. Si el tendero contó en unidades, se deducen
  /// del rendimiento declarado del producto.
  double get _lotesDeclarados {
    final p = _producto;
    if (p == null) return 0;
    if (_usaLotes) return _cantidadIngresada;
    if (p.unidadesPorLote <= 0) return 0;
    return _cantidadIngresada / p.unidadesPorLote;
  }

  List<ConsumoInsumo> get _consumosDeclarados => [
        for (final l in _receta)
          ConsumoInsumo(
            insumoId: l.insumoId,
            insumoNombre: l.insumoNombre,
            unidad: l.unidad,
            cantidad: double.tryParse(
                    (_consumos[l.insumoId]?.text ?? '').replaceAll(',', '.')) ??
                0,
          ),
      ];

  double get _costoDeInsumos {
    var total = 0.0;
    for (final l in _receta) {
      final cantidad = double.tryParse(
              (_consumos[l.insumoId]?.text ?? '').replaceAll(',', '.')) ??
          0;
      total += cantidad * l.costoUnitario;
    }
    return total;
  }

  bool get _produceConReceta =>
      _tipo == TipoMovimientoInventario.produccion && _receta.isNotEmpty;

  double get _cantidadIngresada =>
      double.tryParse(_cantidad.text.replaceAll(',', '.')) ?? 0;

  bool get _usaLotes =>
      _porLotes &&
      _producto?.seProduce == true &&
      _tipo == TipoMovimientoInventario.produccion;

  /// Unidades reales del movimiento: 2 planchas × 30 = 60 panes.
  int get _unidades {
    final n = _cantidadIngresada;
    if (n <= 0) return 0;
    return _usaLotes ? (n * _producto!.unidadesPorLote).round() : n.round();
  }

  bool get _pideMonto => _tipo != TipoMovimientoInventario.ajuste;

  /// Sugerencia de plata según el tipo: el costo si es entrada, el precio de
  /// venta si es salida. El tendero puede corregirla.
  double get _montoSugerido {
    final p = _producto;
    if (p == null) return 0;
    return switch (_tipo) {
      TipoMovimientoInventario.venta => p.precio * _unidades,
      TipoMovimientoInventario.produccion ||
      TipoMovimientoInventario.compra ||
      TipoMovimientoInventario.merma =>
        p.costo * _unidades,
      _ => 0,
    };
  }

  void _recalcularMonto() {
    _recalcularConsumos();
    if (_montoEditado) {
      setState(() {});
      return;
    }
    _monto.text = _montoSugerido <= 0 ? '' : _montoSugerido.toStringAsFixed(2);
    setState(() {});
  }

  String get _etiquetaMonto => switch (_tipo) {
        TipoMovimientoInventario.venta => 'Cuánto cobraste',
        TipoMovimientoInventario.merma => 'Cuánto perdiste',
        _ => 'Cuánto te costó',
      };

  Future<void> _guardar() async {
    final p = _producto;
    if (p == null) {
      mostrarAviso(context, 'Elige el producto');
      return;
    }
    if (_unidades <= 0) {
      mostrarAviso(context, 'Indica la cantidad');
      return;
    }
    if (!_tipo.sumaStock && _unidades > p.stock) {
      mostrarAviso(
        context,
        'Solo hay ${p.stock} en stock y estás sacando $_unidades.',
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      if (_produceConReceta) {
        final resultado =
            await ref.read(insumosRepoProvider).registrarProduccion(
                  producto: p,
                  lotes: _lotesDeclarados,
                  unidadesProducidas: _unidades,
                  consumos: _consumosDeclarados,
                  nota: _nota.text.trim(),
                );
        if (!mounted) return;
        refrescarTodo(ref);
        Navigator.of(context).pop();
        mostrarAviso(context, _resumenDe(resultado));
        return;
      }

      await ref.read(inventarioRepoProvider).registrar(MovimientoInventario(
            id: '',
            productoId: p.id,
            productoNombre: p.nombreCompleto,
            tipo: _tipo,
            unidades: _unidades,
            monto: _pideMonto
                ? (double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0)
                : 0,
            lotes: _usaLotes ? _cantidadIngresada : 0,
            nota: _nota.text.trim(),
            fecha: DateTime.now(),
          ));

      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
      mostrarAviso(context, '${_tipo.etiqueta} registrada');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Qué contarle al tendero cuando termina la horneada.
  String _resumenDe(ResultadoProduccion r) {
    final costo = Formato.soles(r.costoUnitario);
    if (r.unidadesEsperadas <= 0 || r.diferencia == 0) {
      return 'Producción registrada · $costo por unidad';
    }
    final signo = r.diferencia > 0 ? '+' : '';
    return 'Registrada · $signo${r.diferencia} vs lo esperado · $costo c/u';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final productos = ref.watch(inventarioProvider).valueOrNull ?? const [];
    final p = _producto;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Registrar movimiento', style: t.textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final tipo in _tipos)
                  ChoiceChip(
                    label: Text(tipo == TipoMovimientoInventario.venta
                        ? 'Venta en mostrador'
                        : tipo.etiqueta),
                    selected: _tipo == tipo,
                    onSelected: (_) {
                      setState(() => _tipo = tipo);
                      _cargarReceta();
                      _recalcularMonto();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: p?.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Producto'),
              items: [
                for (final prod in productos)
                  DropdownMenuItem(
                    value: prod.id,
                    child: Text(
                      '${prod.nombreCompleto} · ${prod.stock} en stock',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                setState(() {
                  _producto = productos.firstWhere((x) => x.id == id);
                  _porLotes = _producto!.seProduce;
                });
                _cargarReceta();
                _recalcularMonto();
              },
            ),
            if (p != null && p.seProduce &&
                _tipo == TipoMovimientoInventario.produccion) ...[
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text('Por ${p.nombreLote}'),
                  ),
                  const ButtonSegment(value: false, label: Text('Por unidad')),
                ],
                selected: {_porLotes},
                onSelectionChanged: (s) {
                  setState(() => _porLotes = s.first);
                  _recalcularMonto();
                },
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _cantidad,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _usaLotes
                    ? '¿Cuántas ${p!.nombreLote}s?'
                    : 'Cantidad de unidades',
                helperText: _usaLotes && _unidades > 0
                    ? '= $_unidades ${p!.unidad} en el inventario'
                    : null,
              ),
            ),
            if (_produceConReceta) ...[
              const SizedBox(height: 16),
              _Receta(
                receta: _receta,
                controles: _consumos,
                costoTotal: _costoDeInsumos,
                unidades: _unidades,
              ),
            ] else if (_pideMonto) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _monto,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() => _montoEditado = true),
                decoration: InputDecoration(
                  labelText: _etiquetaMonto,
                  prefixText: 'S/ ',
                  helperText: _montoEditado
                      ? 'Lo escribiste tú'
                      : 'Calculado del producto; puedes corregirlo',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _nota,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Horneada de la mañana',
              ),
            ),
            if (p != null && _unidades > 0) ...[
              const SizedBox(height: 16),
              _Vista(
                producto: p,
                tipo: _tipo,
                unidades: _unidades,
                monto: _produceConReceta
                    ? _costoDeInsumos
                    : (double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0),
                esCostoDeInsumos: _produceConReceta,
                unidadesEsperadas: _produceConReceta && p.unidadesPorLote > 0
                    ? (p.unidadesPorLote * _lotesDeclarados).round()
                    : 0,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text('Registrar ${_tipo.etiqueta.toLowerCase()}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Antes de guardar: cómo queda el stock y qué hace con la caja.
class _Vista extends StatelessWidget {
  const _Vista({
    required this.producto,
    required this.tipo,
    required this.unidades,
    required this.monto,
    this.esCostoDeInsumos = false,
    this.unidadesEsperadas = 0,
  });

  final Producto producto;
  final TipoMovimientoInventario tipo;
  final int unidades;
  final double monto;

  /// El costo vino de la receta: no sale plata de la caja, ya se pagó al
  /// comprar los insumos.
  final bool esCostoDeInsumos;

  final int unidadesEsperadas;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final delta = tipo.sumaStock ? unidades : -unidades;
    final quedan = (producto.stock + delta).clamp(0, 1 << 31);
    final esIngreso = tipo == TipoMovimientoInventario.venta;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock: ${producto.stock} → $quedan ${producto.unidad}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (monto > 0 && esCostoDeInsumos)
            Text(
              'Costo del lote ${Formato.soles(monto)} · '
              '${Formato.soles(monto / unidades)} por unidad',
              style: TextStyle(color: t.colorScheme.onSurfaceVariant),
            )
          else if (monto > 0)
            Text(
              esIngreso
                  ? 'Entra ${Formato.soles(monto)} a la caja'
                  : 'Sale ${Formato.soles(monto)} de la caja',
              style: TextStyle(
                color: esIngreso ? t.colorScheme.primary : t.colorScheme.error,
              ),
            ),
          if (unidadesEsperadas > 0 && unidades != unidadesEsperadas)
            Text(
              unidades < unidadesEsperadas
                  ? 'Rindió ${unidadesEsperadas - unidades} menos de lo esperado ($unidadesEsperadas)'
                  : 'Rindió ${unidades - unidadesEsperadas} más de lo esperado ($unidadesEsperadas)',
              style: TextStyle(
                color: unidades < unidadesEsperadas
                    ? t.colorScheme.error
                    : t.colorScheme.primary,
              ),
            ),
          if (esIngreso && producto.costo > 0)
            Text(
              'Ganancia estimada '
              '${Formato.soles(producto.margenUnitario * unidades)}',
              style: t.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

/// Lo que se va a gastar de cada insumo en esta horneada. Viene prellenado
/// por la receta y se corrige a mano: la masa nunca sale idéntica.
class _Receta extends StatelessWidget {
  const _Receta({
    required this.receta,
    required this.controles,
    required this.costoTotal,
    required this.unidades,
  });

  final List<LineaReceta> receta;
  final Map<String, TextEditingController> controles;
  final double costoTotal;
  final int unidades;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qué vas a gastar', style: t.textTheme.titleSmall),
          Text(
            'Sale de la receta; corrígelo si esta vez usaste más o menos.',
            style: t.textTheme.bodySmall
                ?.copyWith(color: t.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final l in receta)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.insumoNombre,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: controles[l.insumoId],
                      textAlign: TextAlign.end,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        suffixText: l.unidad,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 20),
          Text(
            'Costo de los insumos ${Formato.soles(costoTotal)}'
            '${unidades > 0 ? ' · ${Formato.soles(costoTotal / unidades)} por unidad' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

