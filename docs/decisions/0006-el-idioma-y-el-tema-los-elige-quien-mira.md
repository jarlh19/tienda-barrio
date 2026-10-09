# ADR-0006: El idioma y el tema los elige quien mira

## Status
Accepted

## Date
2026-10-08

## Context

La app tenía los dos temas escritos desde el principio, pero `MaterialApp` no
fijaba `themeMode`, así que mandaba el celular y nadie podía elegir. Y el idioma
estaba clavado: `locale: const Locale('es')` ignoraba incluso el idioma del
sistema. `supportedLocales` nombraba `en`, pero no había ni una traducción: los
únicos delegates eran los de Flutter, que traducen "Cancel" y "OK", no la app.

Los ~200 textos vivían dentro de los widgets, y tres cosas más los tenían fuera
de la capa de UI, donde no hay forma de saber en qué idioma está mirando nadie:

| Dónde | Qué |
|---|---|
| `datos/modelos/modelos.dart` | `EstadoPedido.etiqueta`, `MetodoPago.etiqueta` y tres más |
| `datos/repos/*` y `estado/checkout.dart` | 16 mensajes de error en español dentro de `ErrorApp` |
| `core/formato.dart` | "hace 5 min", "ayer", y las fechas con `DateFormat(..., 'es')` |

## Decision

Traducciones con `gen-l10n`: `lib/l10n/app_es.arb` es la plantilla y manda si a
una traducción le falta una clave. El español se queda como idioma de trabajo
porque es el de la tienda y el del código.

**Las etiquetas salen del dominio.** `EstadoPedido.listo` significa lo mismo en
cualquier idioma; "Listo para entregar" es solo una de sus formas de decirlo.
Las extensiones `texto(L)` viven en `ui/comun/etiquetas.dart`.

**Los errores viajan como clave, no como frase.** `ErrorApp` lleva un `Aviso`
—un enum— y los datos que necesite; `textoDeError` lo traduce al mostrarlo. Lo
que llega del servidor no tiene `Aviso` y se enseña tal cual: traducirlo
exigiría adivinar, y un mensaje raro es mejor que uno inventado.

**El tema y el idioma se eligen en Perfil** y se guardan con
`shared_preferences`, con "según el celular" como opción y como valor de
partida. El almacén se inyecta desde `main`, no se abre dentro del provider.

## Alternatives Considered

### Dejar el idioma solo al del sistema, sin selector
- Pros: menos pantalla, menos estado que guardar.
- Contras: el celular de un vecino puede estar en inglés sin que él lo lea, y
  al revés. El idioma de la app no tiene por qué ser el del sistema.
- Rechazada; el selector cuesta poco y ya había que poner el del tema.

### Pasar un objeto de textos a los repositorios
- Pros: los mensajes se arman donde ocurre el error, con todo el contexto.
- Contras: mete el idioma en la capa de datos y obliga a enhebrar el objeto por
  cada constructor. Los repos pasarían a depender de la UI.
- Rechazada: la clave viaja igual de bien y no ensucia nada.

### Traducir también los datos de la tienda
- Pros: una app enteramente en inglés.
- Contras: los productos, las categorías y las unidades los escribe el tendero.
  Traducirlos obligaría a pedirle cada nombre dos veces.
- Rechazada: la interfaz se traduce, el contenido no.

## Consequences

- `Formato.hace`, `fechaHora` y `fechaCorta` reciben `L`: la fecha se arma con
  el idioma que se esté mirando, no con uno fijo.
- Las pruebas de interfaz tienen que decir en qué idioma miran. El entorno de
  pruebas arranca en inglés, así que sin fijarlo las búsquedas en español
  fallarían por un motivo ajeno a lo que se prueba. `test/ayuda.dart` lo
  resuelve en una línea.
- Un texto nuevo son dos sitios: la clave en los dos `.arb`. Si solo se toca el
  español, el inglés hereda el texto en español en vez de romperse.
- El catálogo sigue en el idioma en que el tendero escribió sus productos.
- `shared_preferences` entra como dependencia. Sin almacén —en pruebas— las
  preferencias funcionan igual, solo que no se recuerdan.
