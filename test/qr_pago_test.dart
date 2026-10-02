import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';

void main() {
  group('datos de cobro de la tienda', () {
    test('un método sin número ni QR no se le ofrece al cliente', () {
      const vacia = Tienda();

      expect(vacia.aceptaPagoCon(MetodoPago.yape), isFalse);
      expect(vacia.aceptaPagoCon(MetodoPago.plin), isFalse);
    });

    test('basta el QR para aceptar el método, sin número', () {
      const soloQr = Tienda(qrYapeUrl: 'https://x/qr-yape.png');

      expect(soloQr.aceptaPagoCon(MetodoPago.yape), isTrue);
      expect(soloQr.aceptaPagoCon(MetodoPago.plin), isFalse);
    });

    test('cada método devuelve su propio número y su propio QR', () {
      const tienda = Tienda(
        numeroYape: '999 111 222',
        numeroPlin: '988 333 444',
        qrYapeUrl: 'yape.png',
        qrPlinUrl: 'plin.png',
      );

      expect(tienda.numeroDe(MetodoPago.yape), '999 111 222');
      expect(tienda.numeroDe(MetodoPago.plin), '988 333 444');
      expect(tienda.qrDe(MetodoPago.yape), 'yape.png');
      expect(tienda.qrDe(MetodoPago.plin), 'plin.png');
    });

    test('el QR subido queda guardado y se puede volver a leer', () async {
      final repo = MemTiendaRepo(AlmacenMemoria.instancia);
      final imagen = Uint8List.fromList([137, 80, 78, 71]); // cabecera PNG

      final url = await repo.subirQr(
        metodo: MetodoPago.plin,
        bytes: imagen,
        extension: 'png',
      );
      await repo.guardar((await repo.obtener()).copiar(qrPlinUrl: url));

      final guardada = await repo.obtener();
      expect(guardada.qrPlinUrl, url);
      expect(guardada.aceptaPagoCon(MetodoPago.plin), isTrue);
      // En modo demo el QR viaja como data URI, sin Storage detrás.
      expect(url, startsWith('data:image/png;base64,'));
      expect(
        const Base64Decoder().convert(url.split(',').last),
        equals(imagen),
      );
    });
  });
}
