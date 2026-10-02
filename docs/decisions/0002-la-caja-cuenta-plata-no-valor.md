# ADR-0002: La caja cuenta plata, no valor

## Status
Accepted

## Date
2026-09-01

## Context

Al agregar insumos apareció un doble conteo. El saco de harina sale del bolsillo
cuando se compra; si además la horneada cuenta su costo como egreso, la caja
resta dos veces la misma harina. Lo mismo con la merma: el pan malogrado ya se
pagó al comprar la materia prima.

El tendero de barrio no lleva contabilidad de devengo. La pregunta que le hace a
la app es literal: *"¿cuánta plata entró y cuánta salió hoy?"*.

## Decision

`ResumenCaja` mide **flujo de efectivo**:

- **Entra** con las ventas (pedido o mostrador).
- **Sale** con las compras: insumos y mercadería hecha.
- **Producir no mueve caja.** Transforma insumos ya pagados en producto. Su
  costo se guarda para valorizar el producto y calcular el margen.
- **La merma no mueve caja**, pero se reporta aparte como pérdida valorizada.

Una producción **sin** receta sí cuenta como egreso: ahí el tendero declara un
costo que efectivamente pagó y no pasó por el almacén de insumos. Eso lo marca
la bandera `desde_insumos` del movimiento.

## Alternatives Considered

### Contabilidad de devengo (costo de lo vendido)
- Pros: la utilidad sería la contable de verdad; el margen no baila con las
  compras grandes.
- Contras: exige explicarle al tendero por qué un día que compró S/ 500 de
  harina la app dice que ganó; obliga a valorizar inventario.
- Rechazada: el número que el usuario quiere ver es el de su bolsillo.

### Contar el egreso al producir y no al comprar
- Pros: el costo aparece junto al producto que lo causó.
- Contras: el día que compra tres sacos la caja no refleja que se quedó sin
  efectivo; el saldo de caja deja de parecerse a la realidad.
- Rechazada: invierte el momento en que la plata se mueve de verdad.

## Consequences

- El día que se compra mercadería la utilidad se hunde y luego se recupera con
  las ventas. Es fiel al bolsillo, pero hay que saber leerlo por periodo largo.
- La merma no castiga la caja; se muestra en su propia línea para que no pase
  desapercibida.
- El margen por producto sigue siendo real, porque el costo valorizado se
  guarda en el producto aunque no toque la caja.
- Los tests fijan la regla: `test/caja_test.dart` y `test/insumos_test.dart`
  comprueban que la harina se cuenta una sola vez.
