import 'package:intl/intl.dart';

import 'config.dart';

/// Formatos compartidos por toda la app.
class Formato {
  // El patrón se arma a mano: `NumberFormat.currency` con es_PE deja el
  // símbolo al final ("9,90 S/") y en Perú se escribe "S/ 9.90".
  static final _monto = NumberFormat('#,##0.00', 'en_US');

  static final _fechaHora = DateFormat("d 'de' MMMM, HH:mm", 'es');
  static final _fechaCorta = DateFormat('dd/MM/yyyy', 'es');

  /// Cantidades del inventario: "30", "1.5", "0.04". Sin ceros de relleno,
  /// porque nadie escribe "30.00 panes" ni "2.000 kg" en una libreta.
  static String cantidad(num v, {int decimales = 2}) {
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d
        .toStringAsFixed(decimales)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String soles(num v) => '${Config.simboloMoneda} ${_monto.format(v)}';

  static String fechaHora(DateTime d) => _fechaHora.format(d);

  static String fechaCorta(DateTime d) => _fechaCorta.format(d);

  /// "hace 5 min", "hace 2 h", "ayer"... para las listas de pedidos.
  static String hace(DateTime d) {
    final dif = DateTime.now().difference(d);
    if (dif.inMinutes < 1) return 'ahora';
    if (dif.inMinutes < 60) return 'hace ${dif.inMinutes} min';
    if (dif.inHours < 24) return 'hace ${dif.inHours} h';
    if (dif.inDays == 1) return 'ayer';
    if (dif.inDays < 7) return 'hace ${dif.inDays} días';
    return fechaCorta(d);
  }
}
