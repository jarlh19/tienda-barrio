import 'package:flutter_test/flutter_test.dart';
import 'package:tienda_barrio/datos/modelos/modelos.dart';
import 'package:tienda_barrio/datos/repos/memoria.dart';

MovimientoFiado _mov(TipoMovimiento tipo, double monto) => MovimientoFiado(
      id: '',
      clienteId: 'u-cliente',
      tipo: tipo,
      monto: monto,
      fecha: DateTime.now(),
    );

void main() {
  test('el cupo disponible descuenta la deuda acumulada', () {
    const cuenta = CuentaFiado(
      clienteId: 'x',
      clienteNombre: 'Cliente',
      saldo: 40,
      limite: 100,
    );

    expect(cuenta.disponible, 60);
    expect(cuenta.alcanzaPara(60), isTrue);
    expect(cuenta.alcanzaPara(60.01), isFalse);
  });

  test('la deuda nunca queda negativa aunque se abone de más', () {
    const cuenta =
        CuentaFiado(clienteId: 'x', clienteNombre: 'Cliente', saldo: 0, limite: 50);

    expect(cuenta.disponible, 50);
  });

  test('los cargos suman y los abonos restan al saldo', () async {
    final repo = MemFiadoRepo(AlmacenMemoria.instancia);
    final antes = (await repo.cuenta('u-cliente')).saldo;

    await repo.registrarMovimiento(_mov(TipoMovimiento.cargo, 30));
    await repo.registrarMovimiento(_mov(TipoMovimiento.abono, 10));

    expect((await repo.cuenta('u-cliente')).saldo, antes + 20);
  });
}
