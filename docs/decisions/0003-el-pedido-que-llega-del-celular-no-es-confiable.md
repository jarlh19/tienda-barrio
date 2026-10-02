# ADR-0003: El pedido que llega del celular no es confiable

## Status
Accepted

## Date
2026-09-01

## Context

El cliente escribe directo en la tabla `pedidos` con su propia sesión, y el
payload incluía `precio_unitario`, `cliente_nombre` y `estado_pago`. Un modelo
de amenazas de cinco minutos sobre esa frontera encontró cuatro abusos posibles
con solo cambiar el JSON antes de enviarlo:

| Abuso | Efecto |
|---|---|
| Bajar `precio_unitario` | Comprarse el pan a un céntimo; el total se calculaba desde los items enviados |
| Mandar `estado_pago: pagado` | El pedido entra como cobrado sin haber pagado |
| Falsear `cliente_nombre` | Suplantar a otro vecino en el panel del tendero |
| Pedir al fiado sobre el cupo | La validación del cupo vivía solo en Dart |

Además, la política de `movimientos_fiado` solo permite escribir al tendero, así
que la deuda que la app intentaba anotar desde el cliente **nunca se habría
guardado en producción**: el fiado estaba roto y no se notaba en modo demo.

Y `productos` era legible por cualquier sesión, con `costo` incluido: el margen
del negocio quedaba expuesto al cliente.

## Decision

1. Un trigger `sanear_pedido()` (BEFORE INSERT, `security definer`) **reescribe**
   los items desde `productos` —precio, nombre y unidad—, fija `estado_pago`
   según el método de pago, toma el nombre del perfil y valida stock y cupo de
   fiado contra la base.
2. El cargo al fiado lo inserta el trigger de pedidos, no la app. En modo demo
   lo hace `MemPedidosRepo`, para que ambos caminos se comporten igual.
3. El cliente lee el catálogo por la vista `catalogo`, que no expone `costo`,
   `unidades_por_lote` ni `codigo_barras`. La tabla `productos` pasa a ser solo
   del tendero.
4. El texto de búsqueda se sanea antes de entrar al filtro de PostgREST, donde
   la coma y el paréntesis son sintaxis.

La validación en Dart se queda: es comodidad para el usuario, no un control.

## Alternatives Considered

### Confiar en el cliente y revisar después
- Pros: cero trabajo.
- Contras: el tendero descubriría el fraude al cuadrar caja, si es que lo
  descubre.
- Rechazada.

### Mover la creación del pedido a una Edge Function
- Pros: control total del servidor, sin triggers.
- Contras: otra pieza que desplegar y versionar; el trigger ya corre dentro de
  la misma transacción que el insert.
- Rechazada por ahora: el trigger da la misma garantía con menos infraestructura.

### Quitar `costo` de `productos` y llevarlo a otra tabla
- Pros: la columna sensible deja de existir en la tabla que lee el cliente.
- Contras: parte en dos la ficha del producto y complica cada lectura del
  tendero.
- Rechazada: la vista logra lo mismo sin partir el modelo.

## Consequences

- La app cliente ya no puede fijar precios ni estados de pago: si el catálogo
  cambió entre que se armó el carrito y se envió el pedido, manda la base.
- El total del pedido puede diferir de lo que el cliente vio si el precio subió
  entre medias. Es correcto, pero conviene avisarlo en pantalla (pendiente).
- `SbCatalogoRepo.productos()` lee de dos orígenes según quién pregunte.
- `test/seguridad_test.dart` cubre los abusos como casos de prueba.
