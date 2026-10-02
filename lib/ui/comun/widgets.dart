import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/modelos.dart';
import '../../datos/repos/repos.dart';

/// Muestra un mensaje de error legible. Si viene de la app usamos su texto;
/// cualquier otra cosa se resume para no filtrar detalles técnicos al cliente.
void mostrarError(BuildContext context, Object error) {
  final texto = error is ErrorApp ? error.mensaje : 'Algo salió mal. Inténtalo otra vez.';
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      showCloseIcon: true,
    ));
}

void mostrarAviso(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Copia un texto al portapapeles y lo avisa.
///
/// Está pensado para el número de Yape o Plin: el vecino va a salir de la app
/// para pagar, y teclear nueve dígitos de memoria en la otra pantalla es donde
/// más se equivoca. Un dígito mal escrito manda la plata a un desconocido.
class BotonCopiar extends StatelessWidget {
  const BotonCopiar({
    super.key,
    required this.texto,
    this.aviso = 'Copiado',
    this.color,
  });

  final String texto;
  final String aviso;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy_rounded, size: 20),
      tooltip: 'Copiar',
      color: color,
      visualDensity: VisualDensity.compact,
      onPressed: () async {
        try {
          await Clipboard.setData(ClipboardData(text: texto));
          if (!context.mounted) return;
          mostrarAviso(context, aviso);
        } catch (_) {
          // Hay navegadores que niegan el permiso de escribir el portapapeles.
          // El texto sigue siendo seleccionable a mano, así que se avisa: peor
          // que no copiar es tocar el botón y que no pase nada.
          if (!context.mounted) return;
          mostrarAviso(context,
              'No se pudo copiar. Mantén presionado el número para seleccionarlo.');
        }
      },
    );
  }
}

/// Envoltorio estándar para pintar un AsyncValue sin repetir el when() a mano.
class AsyncVista<T> extends StatelessWidget {
  const AsyncVista({
    super.key,
    required this.valor,
    required this.constructor,
    this.alReintentar,
  });

  final AsyncValue<T> valor;
  final Widget Function(T datos) constructor;
  final VoidCallback? alReintentar;

  @override
  Widget build(BuildContext context) {
    return valor.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EstadoVacio(
        icono: Icons.cloud_off_outlined,
        titulo: 'No se pudo cargar',
        detalle: e is ErrorApp ? e.mensaje : 'Revisa tu conexión e inténtalo otra vez.',
        accion: alReintentar == null
            ? null
            : FilledButton.tonal(
                onPressed: alReintentar,
                child: const Text('Reintentar'),
              ),
      ),
      data: constructor,
    );
  }
}

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle = '',
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: t.colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo,
                style: t.textTheme.titleMedium, textAlign: TextAlign.center),
            if (detalle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                detalle,
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium
                    ?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
            ],
            if (accion != null) ...[const SizedBox(height: 20), accion!],
          ],
        ),
      ),
    );
  }
}

/// Chip de color según el estado del pedido, para leer la lista de un vistazo.
class ChipEstado extends StatelessWidget {
  const ChipEstado({super.key, required this.estado});

  final EstadoPedido estado;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final (fondo, texto) = switch (estado) {
      EstadoPedido.pendiente => (esquema.tertiaryContainer, esquema.onTertiaryContainer),
      EstadoPedido.confirmado ||
      EstadoPedido.preparando =>
        (esquema.secondaryContainer, esquema.onSecondaryContainer),
      EstadoPedido.listo => (esquema.primaryContainer, esquema.onPrimaryContainer),
      EstadoPedido.entregado => (esquema.surfaceContainerHighest, esquema.onSurfaceVariant),
      EstadoPedido.cancelado => (esquema.errorContainer, esquema.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(color: texto, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class ChipPago extends StatelessWidget {
  const ChipPago({super.key, required this.estado, required this.metodo});

  final EstadoPago estado;
  final MetodoPago metodo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final icono = switch (estado) {
      EstadoPago.pagado => Icons.check_circle_outline,
      EstadoPago.verificando => Icons.hourglass_top_outlined,
      EstadoPago.fiado => Icons.receipt_long_outlined,
      EstadoPago.fallido => Icons.error_outline,
      EstadoPago.pendiente => Icons.payments_outlined,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 15, color: esquema.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '${metodo.etiqueta} · ${estado.etiqueta}',
          style: TextStyle(fontSize: 12, color: esquema.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Banner permanente que recuerda que no hay backend configurado.
class AvisoDemo extends StatelessWidget {
  const AvisoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: esquema.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: esquema.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Modo demo: los datos son de ejemplo y no se guardan.',
              style: TextStyle(fontSize: 12, color: esquema.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
