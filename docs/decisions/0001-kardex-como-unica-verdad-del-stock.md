# ADR-0001: El kardex es la única verdad del stock

## Status
Accepted

## Date
2026-09-01

## Context

La primera versión guardaba `productos.stock` como un número suelto que bajaba
cuando entraba un pedido. Al agregar producción, compras y mermas aparecieron
cuatro sitios distintos capaces de moverlo: el trigger de pedidos, el editor de
producto, la hoja de movimientos y el alta.

Con el stock editable a mano y movido desde varios lados, dos preguntas del
tendero dejaban de tener una sola respuesta: *"¿cuánto tengo?"* y *"¿por qué
tengo esto?"*. Un ajuste silencioso en el editor no dejaba rastro, y la caja del
día no cuadraba con el inventario.

## Decision

Toda entrada o salida de mercadería crea una fila en `movimientos_inventario`
(producción, compra, venta, merma, ajuste, devolución). El stock del producto es
el saldo de esos movimientos, aplicado por un trigger; ningún otro camino lo
toca. El campo `stock` del editor solo se puede escribir al **crear** el
producto: después se mueve con Producción, Compra, Merma o Ajuste.

Los insumos tienen su propio kardex (`movimientos_insumo`) con la misma regla.

## Alternatives Considered

### Dejar el stock editable y anotar el movimiento aparte
- Pros: cero fricción para corregir un conteo.
- Contras: el saldo y el histórico se separan en cuanto alguien edita a mano;
  el kardex pasa a ser decorativo.
- Rechazada: el histórico solo sirve si nadie puede saltárselo.

### Calcular el stock sumando los movimientos en cada lectura
- Pros: imposible que se desfase, no hay campo que mantener.
- Contras: cada listado del catálogo tendría que agregar todo el histórico;
  crece sin techo con el tiempo.
- Rechazada: coste de lectura inaceptable para la pantalla más usada.

## Consequences

- El inventario y la caja siempre cuentan la misma historia.
- Corregir un conteo obliga a registrar un **Ajuste**, que queda con fecha y
  nota. Es un paso más, y es deliberado.
- Cualquier función nueva que mueva mercadería tiene que escribir en el kardex;
  no hay atajo.
- El saldo puede recalcularse desde cero si alguna vez se corrompe.
