import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formato.dart';
import '../../datos/modelos/modelos.dart';
import '../../estado/carrito.dart';
import '../../estado/providers.dart';
import '../../l10n/app_localizations.dart';
import '../comun/widgets.dart';

class CatalogoPantalla extends ConsumerWidget {
  const CatalogoPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosProvider);
    final unidades = ref.watch(unidadesCarritoProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Buscador(),
            const _FilaCategorias(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(productosProvider),
                child: AsyncVista(
                  valor: productos,
                  alReintentar: () => ref.invalidate(productosProvider),
                  constructor: (lista) {
                    if (lista.isEmpty) {
                      return EstadoVacio(
                        icono: Icons.search_off,
                        titulo: L.of(context).catalogoSinResultados,
                        detalle: L.of(context).catalogoSinResultadosDetalle,
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: lista.length,
                      itemBuilder: (_, i) => _TarjetaProducto(lista[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: unidades == 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/carrito'),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                '$unidades · ${Formato.soles(ref.watch(totalCarritoProvider))}',
              ),
            ),
    );
  }
}

class _Buscador extends ConsumerStatefulWidget {
  const _Buscador();

  @override
  ConsumerState<_Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends ConsumerState<_Buscador> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  // Esperamos a que el cliente deje de escribir para no consultar en cada tecla.
  void _cambio(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(busquedaProvider.notifier).state = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _ctrl,
        onChanged: _cambio,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: L.of(context).catalogoBuscar,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _ctrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _ctrl.clear();
                    _cambio('');
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }
}

class _FilaCategorias extends ConsumerWidget {
  const _FilaCategorias();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasProvider);
    final seleccion = ref.watch(filtroCategoriaProvider);

    return categorias.maybeWhen(
      data: (lista) => SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(L.of(context).filtroTodo),
                selected: seleccion == null,
                onSelected: (_) =>
                    ref.read(filtroCategoriaProvider.notifier).state = null,
              ),
            ),
            for (final c in lista)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('${c.emoji} ${c.nombre}'.trim()),
                  selected: seleccion == c.id,
                  onSelected: (sel) =>
                      ref.read(filtroCategoriaProvider.notifier).state =
                          sel ? c.id : null,
                ),
              ),
          ],
        ),
      ),
      orElse: () => const SizedBox(height: 48),
    );
  }
}

class _TarjetaProducto extends ConsumerWidget {
  const _TarjetaProducto(this.producto);

  final Producto producto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final carrito = ref.watch(carritoProvider.notifier);
    ref.watch(carritoProvider); // redibuja al cambiar cantidades
    final cantidad = carrito.cantidadDe(producto.id);
    final agotado = !producto.hayStock;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: ImagenProducto(producto: producto),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  producto.nombreCompleto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formato.soles(producto.precio)} · ${producto.unidad}',
                  style: t.textTheme.bodySmall
                      ?.copyWith(color: t.colorScheme.onSurfaceVariant),
                ),
                if (producto.seVendePorPaquete)
                  Text(
                    '${producto.unidadesPorPaquete} x ${Formato.soles(producto.precioPaquete)}',
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 8),
                if (agotado)
                  Text(
                    L.of(context).productoAgotado,
                    style: t.textTheme.labelMedium
                        ?.copyWith(color: t.colorScheme.error),
                  )
                else if (cantidad == 0)
                  SizedBox(
                    height: 34,
                    child: FilledButton.tonal(
                      onPressed: () => carrito.agregar(producto),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.fromHeight(34),
                      ),
                      child: Text(L.of(context).agregar),
                    ),
                  )
                else
                  _Contador(
                    cantidad: cantidad,
                    tope: producto.stock,
                    alCambiar: (n) => carrito.cambiarCantidad(producto, n),
                  ),
                if (producto.stockBajo && !agotado)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      L.of(context).quedanUnidades(
                          Formato.cantidad(producto.stock)),
                      style: t.textTheme.labelSmall
                          ?.copyWith(color: t.colorScheme.tertiary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImagenProducto extends StatelessWidget {
  const ImagenProducto({super.key, required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    if (producto.imagenUrl.isEmpty) {
      return Container(
        color: esquema.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.inventory_2_outlined,
            size: 36, color: esquema.outline),
      );
    }
    return CachedNetworkImage(
      imageUrl: producto.imagenUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: esquema.surfaceContainerHighest),
      errorWidget: (_, _, _) => Container(
        color: esquema.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined,
            size: 32, color: esquema.outline),
      ),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.cantidad,
    required this.tope,
    required this.alCambiar,
  });

  final int cantidad;
  final int tope;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: esquema.secondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BotonIcono(
            icono: Icons.remove,
            alTocar: () => alCambiar(cantidad - 1),
          ),
          Text('$cantidad',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          _BotonIcono(
            icono: Icons.add,
            alTocar: cantidad >= tope ? null : () => alCambiar(cantidad + 1),
          ),
        ],
      ),
    );
  }
}

class _BotonIcono extends StatelessWidget {
  const _BotonIcono({required this.icono, this.alTocar});

  final IconData icono;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 36,
        height: 34,
        child: Icon(
          icono,
          size: 18,
          color: alTocar == null
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
