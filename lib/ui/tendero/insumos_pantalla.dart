import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../comun/widgets.dart';

/// Almacén de materia prima: harina, levadura, manteca. No se vende, se gasta.
class InsumosVista extends ConsumerWidget {
  const InsumosVista({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insumos = ref.watch(insumosProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(insumosProvider),
      child: AsyncVista(
        valor: insumos,
        alReintentar: () => ref.invalidate(insumosProvider),
        constructor: (lista) {
          if (lista.isEmpty) {
            return EstadoVacio(
              icono: Icons.grain,
              titulo: 'Sin insumos todavía',
              detalle: 'Agrega la harina, la levadura y lo que uses para producir.',
              accion: FilledButton.tonal(
                onPressed: () => abrirEditorInsumo(context, ref, null),
                child: const Text('Agregar insumo'),
              ),
            );
          }
          final bajos = lista.where((i) => i.bajoMinimo).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              if (bajos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.notification_important_outlined),
                      title: Text('${bajos.length} insumo(s) por acabarse'),
                      subtitle: Text(bajos.map((i) => i.nombre).join(', ')),
                    ),
                  ),
                ),
              for (final i in lista)
                _FilaInsumo(
                  insumo: i,
                  alEditar: () => abrirEditorInsumo(context, ref, i),
                  alComprar: () => abrirCompraInsumo(context, ref, i),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilaInsumo extends StatelessWidget {
  const _FilaInsumo({
    required this.insumo,
    required this.alEditar,
    required this.alComprar,
  });

  final Insumo insumo;
  final VoidCallback alEditar;
  final VoidCallback alComprar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: alEditar,
        leading: IconButton(
          tooltip: 'Registrar compra',
          icon: const Icon(Icons.local_shipping_outlined),
          onPressed: alComprar,
        ),
        title: Text(
          insumo.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${Formato.soles(insumo.costoUnitario)} por ${insumo.unidad}'
          '${insumo.sePorPresentacion ? ' · ${insumo.nombrePresentacion} de ${Formato.cantidad(insumo.unidadesPorPresentacion)} ${insumo.unidad}' : ''}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${Formato.cantidad(insumo.stock)} ${insumo.unidad}',
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: insumo.bajoMinimo ? t.colorScheme.tertiary : null,
              ),
            ),
            if (insumo.sePorPresentacion)
              Text(
                '${Formato.cantidad(insumo.presentacionesEnStock)} ${insumo.nombrePresentacion}(s)',
                style: t.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}

// --- Alta y edición del insumo ---------------------------------------------

Future<void> abrirEditorInsumo(
  BuildContext context,
  WidgetRef ref,
  Insumo? insumo,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _EditorInsumo(insumo: insumo),
    ),
  );
}

class _EditorInsumo extends ConsumerStatefulWidget {
  const _EditorInsumo({this.insumo});

  final Insumo? insumo;

  @override
  ConsumerState<_EditorInsumo> createState() => _EditorInsumoState();
}

class _EditorInsumoState extends ConsumerState<_EditorInsumo> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _marca;
  late final TextEditingController _presentacion;
  late final TextEditingController _porPresentacion;
  late final TextEditingController _minimo;
  late final TextEditingController _stockInicial;
  late final TextEditingController _costoInicial;
  late String _unidad;
  bool _guardando = false;

  bool get _esNuevo => widget.insumo == null;

  @override
  void initState() {
    super.initState();
    final i = widget.insumo;
    _nombre = TextEditingController(text: i?.nombre ?? '');
    _marca = TextEditingController(text: i?.marca ?? '');
    _presentacion = TextEditingController(text: i?.nombrePresentacion ?? '');
    _porPresentacion = TextEditingController(
      text: (i?.unidadesPorPresentacion ?? 0) > 0
          ? Formato.cantidad(i!.unidadesPorPresentacion)
          : '',
    );
    _minimo = TextEditingController(
      text: (i?.stockMinimo ?? 0) > 0 ? Formato.cantidad(i!.stockMinimo) : '',
    );
    _stockInicial = TextEditingController(text: '0');
    _costoInicial = TextEditingController(
      text: (i?.costoUnitario ?? 0) > 0 ? i!.costoUnitario.toStringAsFixed(2) : '',
    );
    _unidad = i?.unidad ?? 'kg';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _marca.dispose();
    _presentacion.dispose();
    _porPresentacion.dispose();
    _minimo.dispose();
    _stockInicial.dispose();
    _costoInicial.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final base = widget.insumo;
      await ref.read(insumosRepoProvider).guardar(Insumo(
            id: base?.id ?? '',
            nombre: _nombre.text.trim(),
            marca: _marca.text.trim(),
            unidad: _unidad,
            // El stock de un insumo ya creado se mueve con compras y consumos,
            // igual que el de los productos.
            stock: base?.stock ?? _num(_stockInicial),
            costoUnitario: base?.costoUnitario ?? _num(_costoInicial),
            nombrePresentacion: _presentacion.text.trim(),
            unidadesPorPresentacion: _num(_porPresentacion),
            stockMinimo: _num(_minimo),
            activo: base?.activo ?? true,
          ));
      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
      mostrarAviso(context, _esNuevo ? 'Insumo agregado' : 'Insumo actualizado');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _darDeBaja() async {
    try {
      await ref.read(insumosRepoProvider).darDeBaja(widget.insumo!.id);
      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) mostrarError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _esNuevo ? 'Nuevo insumo' : 'Editar insumo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Harina',
                ),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Escribe el nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _marca,
                      decoration: const InputDecoration(labelText: 'Marca'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unidad,
                      decoration: const InputDecoration(
                        labelText: 'Se gasta en',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'L', child: Text('L')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'und', child: Text('und')),
                      ],
                      onChanged: (v) => setState(() => _unidad = v ?? 'kg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _presentacion,
                      decoration: const InputDecoration(
                        labelText: 'Se compra por',
                        hintText: 'saco',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _porPresentacion,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Trae',
                        suffixText: _unidad,
                        helperText: 'Ej.: 50',
                      ),
                    ),
                  ),
                ],
              ),
              if (_esNuevo) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockInicial,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Tengo ahora',
                          suffixText: _unidad,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costoInicial,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Me cuesta',
                          prefixText: 'S/ ',
                          helperText: 'por $_unidad',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _minimo,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Avisarme cuando baje de',
                  suffixText: _unidad,
                  helperText: 'Déjalo vacío si no quieres aviso',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: Text(_esNuevo ? 'Agregar' : 'Guardar'),
              ),
              if (!_esNuevo)
                TextButton(
                  onPressed: _guardando ? null : _darDeBaja,
                  child: const Text('Dar de baja'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Compra de insumo -------------------------------------------------------

Future<void> abrirCompraInsumo(
  BuildContext context,
  WidgetRef ref,
  Insumo insumo,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _CompraInsumo(insumo: insumo),
    ),
  );
}

class _CompraInsumo extends ConsumerStatefulWidget {
  const _CompraInsumo({required this.insumo});

  final Insumo insumo;

  @override
  ConsumerState<_CompraInsumo> createState() => _CompraInsumoState();
}

class _CompraInsumoState extends ConsumerState<_CompraInsumo> {
  final _cantidad = TextEditingController(text: '1');
  final _monto = TextEditingController();
  late bool _porPresentacion = widget.insumo.sePorPresentacion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cantidad.addListener(() => setState(() {}));
    _monto.text = _sugerido.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _cantidad.dispose();
    _monto.dispose();
    super.dispose();
  }

  double get _ingresado =>
      double.tryParse(_cantidad.text.replaceAll(',', '.')) ?? 0;

  /// Cantidad en unidad base: 2 sacos de 50 kg son 100 kg.
  double get _enUnidadBase => _porPresentacion
      ? _ingresado * widget.insumo.unidadesPorPresentacion
      : _ingresado;

  double get _sugerido => _enUnidadBase * widget.insumo.costoUnitario;

  Future<void> _guardar() async {
    final insumo = widget.insumo;
    if (_enUnidadBase <= 0) {
      mostrarAviso(context, 'Indica cuánto entró');
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref.read(insumosRepoProvider).registrarMovimiento(MovimientoInsumo(
            id: '',
            insumoId: insumo.id,
            insumoNombre: insumo.nombreCompleto,
            tipo: TipoMovimientoInsumo.compra,
            cantidad: _enUnidadBase,
            monto: double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0,
            presentaciones: _porPresentacion ? _ingresado : 0,
            fecha: DateTime.now(),
          ));
      if (!mounted) return;
      refrescarTodo(ref);
      Navigator.of(context).pop();
      mostrarAviso(context, 'Compra registrada');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insumo = widget.insumo;
    final t = Theme.of(context);
    final monto = double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0;
    final nuevoCosto = _enUnidadBase <= 0
        ? insumo.costoUnitario
        : ((insumo.stock * insumo.costoUnitario) + monto) /
            (insumo.stock + _enUnidadBase);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comprar ${insumo.nombreCompleto}',
                style: t.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (insumo.sePorPresentacion)
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text('Por ${insumo.nombrePresentacion}'),
                  ),
                  ButtonSegment(value: false, label: Text('Por ${insumo.unidad}')),
                ],
                selected: {_porPresentacion},
                onSelectionChanged: (s) =>
                    setState(() => _porPresentacion = s.first),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidad,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _porPresentacion
                    ? '¿Cuántos ${insumo.nombrePresentacion}s?'
                    : '¿Cuántos ${insumo.unidad}?',
                helperText: _porPresentacion && _enUnidadBase > 0
                    ? '= ${Formato.cantidad(_enUnidadBase)} ${insumo.unidad}'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Cuánto pagaste en total',
                prefixText: 'S/ ',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock: ${Formato.cantidad(insumo.stock)} → '
                    '${Formato.cantidad(insumo.stock + _enUnidadBase)} ${insumo.unidad}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'El ${insumo.unidad} pasa de ${Formato.soles(insumo.costoUnitario)} '
                    'a ${Formato.soles(nuevoCosto)}',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: const Text('Registrar compra'),
            ),
          ],
        ),
      ),
    );
  }
}

