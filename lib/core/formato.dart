import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'config.dart';

/// Formatos compartidos por toda la app.
class Formato {
  // El patrón se arma a mano: `NumberFormat.currency` con es_PE deja el
  // símbolo al final ("9,90 S/") y en Perú se escribe "S/ 9.90".
  static final _monto = NumberFormat('#,##0.00', 'en_US');

  // La fecha se arma con el idioma que esté mirando el usuario, no con uno
  // fijo: los meses y el orden del día cambian entre español e inglés.
  static DateFormat _fechaHora(L l) =>
      DateFormat.MMMMd(l.localeName).add_Hm();
  static DateFormat _fechaCorta(L l) => DateFormat.yMd(l.localeName);

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

  static String fechaHora(L l, DateTime d) => _fechaHora(l).format(d);

  static String fechaCorta(L l, DateTime d) => _fechaCorta(l).format(d);

  /// "hace 5 min", "hace 2 h", "ayer"... para las listas de pedidos.
  static String hace(L l, DateTime d) {
    final dif = DateTime.now().difference(d);
    if (dif.inMinutes < 1) return l.haceAhora;
    if (dif.inMinutes < 60) return l.haceMinutos(dif.inMinutes);
    if (dif.inHours < 24) return l.haceHoras(dif.inHours);
    if (dif.inDays == 1) return l.haceAyer;
    if (dif.inDays < 7) return l.haceDias(dif.inDays);
    return fechaCorta(l, d);
  }
}
