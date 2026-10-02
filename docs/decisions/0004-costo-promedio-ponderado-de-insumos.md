# ADR-0004: El costo del insumo es promedio ponderado

## Status
Accepted

## Date
2026-09-01

## Context

El costo por unidad de un insumo cambia con cada compra: un saco de harina a
S/ 180 hoy y a S/ 220 el mes que viene. Ese número alimenta el costo del pan y,
por lo tanto, el margen que la app le muestra al tendero.

## Decision

`costo_unitario` del insumo se recalcula en cada compra como promedio ponderado
del stock:

    nuevo = (stock_previo × costo_previo + monto_pagado) / (stock_previo + entrada)

Si quedaban 20 kg a S/ 3.60 y entran 50 kg por S/ 220, el kilo pasa a S/ 3.89.

El costo del producto terminado se fija con el de **la última horneada**: los
insumos gastados divididos entre las unidades que salieron.

## Alternatives Considered

### Último precio pagado
- Pros: trivial de calcular y de explicar.
- Contras: el margen salta de golpe con una sola compra cara, aunque el 80% del
  stock siga siendo barato.
- Rechazada: daría una lectura falsa justo cuando el tendero necesita decidir si
  sube el precio.

### FIFO por lotes
- Pros: es lo más fiel a la realidad contable.
- Contras: obliga a rastrear cada lote y su saldo; mucha máquina para una tienda
  de barrio.
- Rechazada: complejidad desproporcionada.

## Consequences

- El margen se mueve de forma suave y predecible.
- El costo mostrado no coincide con ninguna factura concreta; es un promedio.
- Una compra a precio muy distinto se diluye en el stock existente, que es
  justamente lo que se busca.
- La mano de obra y el gas **no** entran: el margen real de la panadería es algo
  menor que el que muestra la app.
