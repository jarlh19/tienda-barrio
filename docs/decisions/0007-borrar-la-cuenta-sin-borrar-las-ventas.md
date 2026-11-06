# ADR-0007: Borrar la cuenta sin borrar las ventas

## Status
Accepted

## Date
2026-11-06

## Context

El cliente no tenía cómo borrar su cuenta: el perfil solo ofrecía cerrar
sesión, y Play Store exige poder hacerlo desde la app. Además, el borrado a
mano desde el panel de Supabase arrastraba demasiado: `pedidos` y
`movimientos_fiado` colgaban de `perfiles` con `on delete cascade`, así que se
iban las ventas, la deuda de fiado y los abonos ya cobrados. A la tienda se le
descuadraban la caja y el historial, y una deuda pendiente desaparecía.

## Decision

- "Borrar mi cuenta" en Perfil, con confirmación, solo para clientes.
- `public.borrar_mi_cuenta()` en `schema.sql`, `security definer`, solo para
  `authenticated`:
  - Frena sin borrar nada si quien llama es el tendero (la tienda se quedaría
    sin dueño), si tiene un pedido en curso o si debe fiado; el mensaje dice
    cuánto debe.
  - Si no, deja sus pedidos como ventas con `cliente_nombre = 'Cuenta borrada'`
    y sin dirección ni notas, y borra su fila de `auth.users`.
- `pedidos.cliente_id` y `movimientos_fiado.cliente_id` pasan a aceptar `null`
  con `on delete set null`: al borrarse el perfil, las ventas y el fiado ya
  saldado quedan en las cuentas de la tienda, sin cliente. Para bases ya
  creadas, `schema.sql` trae los `alter table` que hacen el cambio.
- La app lee un `cliente_id` vacío como "cuenta borrada" y no se cae.
- El modo demo aplica las mismas reglas, y el vecino de ejemplo vuelve a nacer
  si alguien borró su cuenta.

## Alternatives considered

- **Anonimizar sin frenar**: la deuda pendiente se perdía para el tendero.
- **Borrar todo, como antes**: lo más simple, pero descuadra ventas, caja e
  inventario.

## Consequences

- Una base ya creada necesita correr solo las partes nuevas (los `alter table`
  de `pedidos` y `movimientos_fiado`, la función y su `grant`); el archivo
  completo no se puede correr dos veces por la publicación de realtime.
- Pruebas: 14 nuevas en `supabase/probar-esquema.mjs` (11 fallaban antes; las
  otras tres comprueban lo que no debe cambiar) y 3 en
  `test/borrar_cuenta_test.dart`, que fallaban antes.
