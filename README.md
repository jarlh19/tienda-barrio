# Tienda de Barrio — mobile app

**English** · [Español](README.es.md)

A Flutter app for a neighborhood store: customers place their order from their
phone and the shopkeeper handles it from the same app. It includes catalog,
cart, orders, shopkeeper panel, payments and store credit ("fiado").

- **Flutter 3.44** (Android, iOS and web from the same code)
- **Supabase** for data, auth and real-time orders
- **Riverpod** for state, **go_router** for navigation

## Running the project

Without credentials it starts in **demo mode** with sample data in memory: you
can walk through the whole app without a backend (nothing is saved on close).

```bash
flutter run
```

The demo sign-in screen has two buttons: *Cliente* (customer) and *Tendero*
(shopkeeper).

With Supabase configured:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

Quick checks:

```bash
flutter analyze
```

```bash
flutter test
```

54 tests cover the cart, stock ledger and cash, ingredient costing, store
credit, payment methods, barcode intake and sign-in.

## Connecting Supabase

1. Create a project at [supabase.com](https://supabase.com) (the free plan is
   more than enough).
2. Paste and run the whole `supabase/schema.sql` in the SQL Editor. It creates
   tables, triggers, RLS policies and the initial categories.
3. Copy the *Project URL* and the *anon/publishable key* from Settings → API
   and pass them with `--dart-define` as above.
4. Sign up in the app with the owner's email and promote it to shopkeeper:

```sql
update public.perfiles set rol = 'tendero'
 where id = (select id from auth.users where email = 'dueno@tienda.com');
```

The role is never chosen from the app: every account starts as `cliente` and
is promoted by hand in the database. That way nobody becomes a shopkeeper just
by signing up.

## Architecture

```
lib/
  core/        config (dart-define), theme, formatting, router
  datos/
    modelos/   Producto, Pedido, CuentaFiado, ...
    repos/     interfaces + Supabase implementation + in-memory implementation
  estado/      Riverpod providers, cart and checkout
  ui/
    auth/      sign-in and sign-up
    cliente/   catalog, cart, payment, my orders, my credit
    tendero/   orders, inventory, ingredients, recipes, scanner, cash, credit
    comun/     profile and shared widgets
supabase/schema.sql
tool/icono.py
```

The app only knows the **interfaces** in `datos/repos/repos.dart`. Behind them
there can be Supabase or the in-memory store, chosen in a single place
(`estado/providers.dart`). That is why demo mode does not leak into the
screens.

## Payments

`PasarelaPago` (`datos/repos/pasarela.dart`) is the only path a payment goes
through. Today it has one implementation, `PagoLocal`:

| Method | What happens |
|---|---|
| Cash | The order stays *unpaid*; it is collected on delivery |
| Yape / Plin | The customer sees the store's QR code and phone number (with a copy button), pays and enters the operation code → the order goes to *verifying* → the shopkeeper confirms or rejects it from the panel |
| Store credit | The credit limit is checked, the amount is charged to the customer's account and the order is marked *on credit* |
| Card | Disabled: requires a payment gateway |

Yape and Plin are the most used mobile wallets in Peru.

### The store's QR code

The shopkeeper uploads their own QR code in **Perfil → Cómo me pagan**: they
pick the image exported from Yape or Plin and it is stored in Supabase Storage
(bucket `tienda`, public read, write only for the shopkeeper). Each method has
its own number and QR, and uploading a new one replaces the previous file
instead of leaving orphans behind.

A method is only offered to the customer if it has a number or a QR; otherwise
it shows as disabled with "La tienda aún no lo tiene configurado". In demo mode
the QR is kept as a data URI in memory, with no Storage behind it.

Next to the number there is a **copy button**. The customer is about to leave
the app to pay, and typing nine digits from memory on another screen is where
mistakes happen: one wrong digit sends the money to a stranger.

To plug in a real payment gateway (Mercado Pago, Culqi, Izipay) you implement
that same interface and change one line in `estado/providers.dart`; no screen
needs to change. Note that a gateway requires a merchant account and business
identity verification, which is a separate process from the code.

## Sign in with Google

> **The button is hidden today.** The flow is written and tested, but the app
> is not registered in Google Cloud yet, so it stays hidden: a screen with a
> single way in is better than a button that fails when tapped. It is turned
> on by passing the client ID through `--dart-define`, with no code changes.
>
> The native dependency (`google_sign_in`) **was removed in the meantime**,
> because it raised the Android minimum to version 6 and left old phones out
> for a feature that is switched off. When enabled this way, Google opens in
> the browser and returns to the app. To get the system account picker back
> (which is better) reinstall it: `flutter pub add google_sign_in`.

Once enabled, the sign-in screen offers **Continue with Google** and nothing
else. The email form moves behind *Prefiero usar mi correo*, for phones without
Google services and for people who prefer a password.

Name and email come from the phone's account; the customer types nothing. What
Google does not have (phone number and address) is asked for on the first
order and saved to the profile, so the second order comes pre-filled. That
last part is already active and also applies to email sign-ups.

### Registering it in Google Cloud

These are the remaining steps to turn it on.

1. In [console.cloud.google.com](https://console.cloud.google.com) create a
   project and configure the **OAuth consent screen**.
2. *Credentials → Create credentials → OAuth client ID*, type **Web
   application**. Under authorized redirect URIs add
   `https://YOURPROJECT.supabase.co/auth/v1/callback`. Keep the **client ID
   and secret**: this is the one the app needs.
3. Another credential, this time type **Android**, with the package name
   (`com.jorge.tienda_barrio`) and the SHA-1 fingerprint of the certificate.
   To get it:

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

   That is the **debug** fingerprint. When the Play Store signing key is
   generated, its SHA-1 must be registered too, or the button will stop
   working precisely in the published version.

4. In Supabase: *Authentication → Providers → Google*, enable it and paste the
   client ID and secret from step 2 (the **web** ones, not the Android ones).

Then run with both Supabase credentials plus the web client ID:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi... --dart-define=GOOGLE_SERVER_CLIENT_ID=1234-abcd.apps.googleusercontent.com
```

Android asks for the **web** client ID, not its own. The Android one lets
Google recognize the APK by its fingerprint; the token audience is whoever
reads it, which is Supabase. This is the mistake that costs the most time,
because it fails without saying why (ADR-0005).

The button appears as soon as there is a client ID, in demo mode too. There it
is simulated: it signs in as the sample customer without asking anyone for an
account, which is all that can be done without a backend.

## Product record

Each product stores **name, brand, type (category), price, stock quantity,
packaging** (bottle, bag, can) and **weight or volume** (900 ml, 1 kg), plus
the barcode.

Brand and size are separate fields, not part of the name: the catalog can
build "Primor Aceite vegetal 900 ml" by itself, customers can search by brand,
and switching the bottle from 900 ml to 1 L does not require renaming the
product. Items sold loose leave the weight empty and carry nothing over.

## Barcodes

Stock intake starts at the scanner: in **Inventario → Escanear** the
shopkeeper points at the package and the app decides on its own.

- If the code is already registered, it opens that product to restock it or
  fix the price. It never creates a duplicate.
- If it is new, it opens the new-product form with the code filled in: only
  name, price and quantity are left.
- The code can also be typed by hand (torn or missing labels) and the field
  accepts input from a USB barcode gun.
- Items sold loose (bread, vegetables) have no code: the column stores NULL
  and the database's unique index allows several of those.

A code belongs to a single product; if it is repeated, the app says which
product owns it instead of saving two rows the scanner could not tell apart.

It reads EAN-13, EAN-8, UPC-A, UPC-E and Code 128 with `mobile_scanner`. The
camera permission is already declared in `AndroidManifest.xml` and
`Info.plist`.

## Inflows and outflows

Everything that enters or leaves inventory writes a row to the **stock
ledger** (`movimientos_inventario`): production, purchase, sale, waste,
adjustment and return. A product's stock is the balance of those movements
and the day's cash is their sum in soles, so there are no two sources of truth
that can drift apart.

| Movement | Stock | Cash |
|---|---|---|
| Production | up | cost goes out |
| Purchase | up | cost goes out |
| Sale (order or counter) | down | payment comes in |
| Waste | down | cost is lost |
| Adjustment | corrected | no money moves |
| Return (cancelled order) | back | income is reversed |

The shopkeeper's **Caja** (cash) tab shows, per day / 7 days / month: how much
came in, how much went out, what is left, the margin and what was sold. Order
sales are recorded automatically; production, purchases, waste and counter
sales are entered by the shopkeeper with the *Registrar* button.

Order sales are written by a database trigger, not by the app: the ledger does
not depend on the phone finishing the operation correctly.

## The bakery case

A product can declare **how many units come out of a batch** and **in what
pack size it is sold**:

- French bread: `unidades_por_lote = 30`, `nombre_lote = "plancha"` (tray),
  `unidades_por_paquete = 4`, price S/ 0.25, cost S/ 0.12.
- When recording production the shopkeeper enters **2 trays** and the app adds
  **60 loaves** to inventory, at a cost of S/ 7.20.
- The catalog shows "S/ 0.25 · und" and below it "4 x S/ 1.00".
- With the whole tray sold: S/ 7.50 came in, S/ 3.60 went out, S/ 3.90 is left
  (52% margin).

The stored price is always the **unit price**; the pack is only how the
customer orders it. So 10 loaves cost S/ 2.50 without building combos, and
changing "4 for one sol" to "5 for one sol" does not touch the price of past
sales.

Stock of an existing product **cannot be edited by hand**: it moves through
Production, Purchase, Waste or Adjustment. It is the only way for inventory
and cash to tell the same story.

## Ingredients and production

Flour is not sold: it is **consumed**. So it lives in its own store
(**Inventario → Insumos**), with its own ledger.

- It is **bought by package** and **used in the base unit**: "2 sacks" come in
  and the app records 100 kg. Production deducts it by the kilo.
- The cost per kilo is a **weighted average**: if 20 kg were left at S/ 3.60
  and 50 kg come in at S/ 4.00, the kilo goes to S/ 3.89. Without this the
  margin would jump every time the price of a sack changes.
- Each product can have a **recipe**: "one tray takes 2 kg of flour". When
  recording production the app proposes the consumption based on the batches
  and the shopkeeper corrects it, because dough never comes out identical.
- **The cost of bread comes from there**: ingredients used ÷ units produced.
  That number is stored on the product, so the margin is real and the
  shopkeeper finds out the same day flour goes up.
- It compares **actual output with expected output**: 2 trays of 100 should
  yield 200 loaves; if 180 came out, it says so and the cost per loaf rises
  accordingly.
- It does not allow production if there are not enough ingredients, and it
  never deducts halfway: the whole bake is a single operation.

### Cash counts money, not value

Ingredients bring the risk of counting twice: if the sack is an expense when
bought and the bake is an expense again, the cash would lie. The rule:

- **Money goes out** on purchases (ingredients or finished goods).
- **Money comes in** on sales.
- **Production does not move cash**: it turns already-paid flour into bread.
  Its cost is used to value the product and calculate the margin.
- **Waste does not move cash either**, but it is shown separately with its
  value: it is not money going out, it is money that will not come back.

## Store credit ("fiado")

Each customer has a credit limit (`limite_fiado`, S/ 100 by default). The
balance is not stored: it is computed from the movements (`cargo` adds debt,
`abono` subtracts it), so the history always matches the number on screen.

- The customer sees their debt, available credit and movements.
- The shopkeeper records payments and charges, and changes each customer's
  limit.
- If the order does not fit in the available credit, the *fiado* method is
  disabled.

## Name and icon

The app is called **Tienda de Barrio** in the app drawer, and it launches on a
green background instead of the default white.

The icon is not a PNG someone drew once: it is drawn in `tool/icono.py`, which
generates the Android, iOS and web sizes.

```bash
python tool/icono.py
```

Changing the color or shape means editing that file and running it again; the
generated PNGs stay in the project, so building does not need Python. Android
also gets the **adaptive icon** (the launcher crops it as a circle or square
depending on the manufacturer) and the monochrome layer used by Android 13
themed icons.

## Decisions

Decisions that would be costly to reverse are in `docs/decisions/` (Spanish):

| ADR | Decision |
|---|---|
| [0001](docs/decisions/0001-kardex-como-unica-verdad-del-stock.md) | The stock ledger is the single source of truth for stock |
| [0002](docs/decisions/0002-la-caja-cuenta-plata-no-valor.md) | Cash counts money, not value |
| [0003](docs/decisions/0003-el-pedido-que-llega-del-celular-no-es-confiable.md) | The order coming from the phone is not trusted |
| [0004](docs/decisions/0004-costo-promedio-ponderado-de-insumos.md) | Ingredient cost is a weighted average |
| [0005](docs/decisions/0005-entrar-con-google-y-el-correo-de-respaldo.md) | Sign in with Google, with email as fallback |

## Known gaps

- **Push notifications** when a new order arrives (today the panel only
  updates live while the app is open).
- **Product photos**: the editor accepts a URL; uploading the photo from the
  phone to Supabase Storage is still missing.
- **Scan to sell**: counter sales are recorded by picking the product from a
  list; scanning it is still missing.
- **Daily cash by payment method**: the summary adds everything together; it
  does not split cash, Yape and credit.
- **Yield history**: the app compares each bake with the expected output, but
  it does not chart how it evolves or warn when yield keeps dropping.
- **Labor and gas** are not part of the cost, only ingredients. The bakery's
  real margin is somewhat lower than what the app shows.
- **Price changed mid-order**: the database decides the price (ADR-0003), so if
  it goes up between building the cart and confirming, the total may differ
  from what the customer saw. The app does not warn about it yet.
- **Google Play signing**: the APK is currently signed with the debug key
  (`android/app/build.gradle.kts`). It installs on a phone, but publishing
  requires generating a proper key and a `key.properties` outside the project.
