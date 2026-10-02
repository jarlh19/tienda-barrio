import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/providers.dart';
import '../comun/widgets.dart';

Future<void> abrirEditorReceta(
  BuildContext context,
  WidgetRef ref,
  Producto producto,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _EditorReceta(producto: producto),
    ),
  );
}

/// Cuánto de cada insumo lleva un lote: "una plancha lleva 2 kg de harina".
/// Es lo que le permite a la app proponer el consumo y calcular el costo real.
class _EditorReceta extends ConsumerStatefulWidget {
  const _EditorReceta({required this.producto});

  final Producto producto;

  @override
  ConsumerState<_EditorReceta> createState() => _EditorRecetaState();
}

class _EditorRecetaState extends ConsumerState<_EditorReceta> {
  final Map<String, TextEditingController> _campos = {};
  bool _cargado = false;
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _prepararCampos(List<Insumo> insumos, List<LineaReceta> receta) {
    if (_cargado) return;
    _cargado = true;
    for (final i in insumos) {
      final linea = receta.where((l) => l.insumoId == i.id).firstOrNull;
      _campos[i.id] = TextEditingController(
        text: linea == null
            ? ''
            : Formato.cantidad(linea.cantidadPorLote, decimales: 3),
      )..addListener(() => setState(() {}));
    }
  }

  double _cantidadDe(String insumoId) =>
      double.tryParse((_campos[insumoId]?.text ?? '').replaceAll(',', '.')) ?? 0;

  Future<void> _guardar(List<Insumo> insumos) async {
    setState(() => _guardando = true);
    try {
      // Solo se guardan las líneas con cantidad: dejar un insumo en blanco es
      // la forma de sacarlo de la receta.
      final lineas = <LineaReceta>[
        for (final i in insumos)
          if (_cantidadDe(i.id) > 0)
            LineaReceta(
              insumoId: i.id,
              insumoNombre: i.nombreCompleto,
              unidad: i.unidad,
              cantidadPorLote: _cantidadDe(i.id),
              costoUnitario: i.costoUnitario,
            ),
      ];
      await ref
          .read(insumosRepoProvider)
          .guardarReceta(widget.producto.id, lineas);
      if (!mounted) return;
      ref.invalidate(recetaProvider(widget.producto.id));
      Navigator.of(context).pop();
      mostrarAviso(context, 'Receta guardada');
    } catch (e) {
      if (mounted) mostrarError(context, e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = widget.producto;
    final insumos = ref.watch(insumosProvider);
    final receta = ref.watch(recetaProvider(p.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receta de ${p.nombre}', style: t.textTheme.titleLarge),
            Text(
              'Cuánto se gasta para hacer '
              '${p.seProduce ? '1 ${p.nombreLote} (${p.unidadesPorLote} ${p.unidad})' : 'un lote'}.',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (insumos.isLoading || receta.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (insumos.valueOrNull?.isEmpty ?? true)
              const EstadoVacio(
                icono: Icons.grain,
                titulo: 'No hay insumos registrados',
                detalle: 'Agrégalos primero en Inventario → Insumos.',
              )
            else
              Builder(builder: (_) {
                final lista = insumos.value!;
                _prepararCampos(lista, receta.valueOrNull ?? const []);

                var costoLote = 0.0;
                for (final i in lista) {
                  costoLote += _cantidadDe(i.id) * i.costoUnitario;
                }

                return Column(
                  children: [
                    for (final i in lista)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                i.nombreCompleto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: TextField(
                                controller: _campos[i.id],
                                textAlign: TextAlign.end,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixText: i.unidad,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Costo del lote'),
                        Text(
                          Formato.soles(costoLote),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (p.seProduce && p.unidadesPorLote > 0 && costoLote > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${Formato.soles(costoLote / p.unidadesPorLote)} '
                          'por ${p.unidad}',
                          style: t.textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _guardando ? null : () => _guardar(lista),
                      child: const Text('Guardar receta'),
                    ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

