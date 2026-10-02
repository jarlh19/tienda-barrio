# ADR-0005: Entrar con Google, y el correo de respaldo

## Status
Accepted — escrito y probado, apagado hasta registrar la app en Google Cloud.

## Date
2026-09-29

## Context

La primera pantalla pedía cinco campos —nombre, correo, contraseña, celular y
dirección— antes de dejar ver un solo producto. Para una tienda de barrio eso es
al revés de como funciona el negocio: el vecino ya entra a comprar, no a darse de
alta.

El celular del vecino ya tiene una cuenta de Google configurada. Pedirle que
invente otra contraseña es pedirle trabajo por algo que el sistema operativo ya
sabe.

## Decision

**Google es el camino principal.** El botón *Continuar con Google* es lo primero
de la pantalla; el formulario de correo vive detrás de *Prefiero usar mi correo*
y aparece solo si alguien lo pide.

Mientras el registro en Google Cloud no esté hecho, el botón **no se muestra** y
el formulario vuelve a ser la única entrada. Lo decide `Config.hayGoogle`, que
mira si hay ID de cliente configurado. Así el trabajo queda hecho sin dejar en
producción un botón que no puede funcionar, y encenderlo es pasar un
`--dart-define`, no volver a programar.

Y como está apagado, la **dependencia nativa se quita**. `google_sign_in` obliga
a subir `minSdk` a 23 por el Credential Manager de Android: no vale dejar fuera
los celulares anteriores a 2015 por una función que nadie puede usar todavía.

Sin ella, `entrarConGoogle()` usa `signInWithOAuth` de Supabase, que ya viene en
el proyecto: manda a Google fuera de la app y vuelve por redirección. Por eso
devuelve `Perfil?` y no `Perfil` —no hay nada que devolver en el momento, la
sesión llega después por el stream de `cambios`. El selector de cuentas del
sistema, que es la buena experiencia, vuelve reinstalando el paquete el día que
se active.

Android pide el **ID de cliente web**, no el suyo. El ID de Android sirve para
que Google reconozca al APK por su huella SHA-1; la *audiencia* del token es
quien lo va a leer, que es Supabase. Poner el de Android hace que Supabase
rechace el token sin explicar por qué.

El formulario se queda. No todos los celulares tienen los servicios de Google,
y el teléfono que se presta en el mostrador no debería arrastrar la cuenta del
dueño.

## Alternatives Considered

### Solo Google, sin formulario
- Pros: una sola pantalla, cero mantenimiento de contraseñas.
- Contras: deja fuera los celulares sin servicios de Google, que en el barrio no
  son raros.
- Rechazada.

### Enlace mágico al correo
- Pros: sin contraseñas y sin registrar nada en Google Cloud.
- Contras: obliga a salir de la app, abrir el correo y volver. Para este público
  es peor que el formulario.
- Rechazada.

### Código por SMS
- Pros: el número es lo que el tendero usa de verdad para ubicar al cliente.
- Contras: cada mensaje se paga y exige contratar un proveedor.
- Rechazada por ahora; el celular se sigue pidiendo en el perfil.

## Consequences

- El perfil de quien entra con Google llega **sin celular ni dirección**: Google
  no los tiene. La dirección se pide en el primer pedido —el checkout ya la
  exigía— y desde ahora **queda guardada en el perfil**, así el segundo pedido
  sale lleno. Sin eso, quitar el formulario habría cambiado un registro molesto
  por un campo repetido en cada compra.
- `crear_perfil()` tenía que cambiar: leía solo `nombre`, y Google manda
  `full_name` o `name`. Un usuario de Google habría quedado sin nombre y el
  tendero habría visto pedidos de nadie.
- `minSdk` se queda en el de Flutter. Volverá a 23 el día que se reinstale
  `google_sign_in`, y ahí sí quedarán fuera los Android anteriores a 2015: es un
  costo que conviene pagar cuando la función sirva, no antes.
- Al reinstalar el paquete hay que volver a cerrar la sesión de Google dentro de
  `cerrarSesion()`. Si no, el selector de cuentas no vuelve a salir y el celular
  prestado entra como el dueño anterior.
- Hay que registrar la app en Google Cloud y cargar el ID de cliente en Supabase.
  Es trabajo fuera del código, y sin él el botón no aparece: `hayGoogle` es falso
  cuando no hay ID configurado, para no mostrar un botón que falla al tocarlo.
- La "G" del botón está dibujada con texto. La marca oficial es un archivo que
  Google entrega en sus guías; hay que incorporarlo antes de publicar, porque las
  condiciones de uso de la marca no admiten una imitación.
