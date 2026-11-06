/* Prueba schema.sql contra un Postgres de verdad, en memoria (PGlite), antes
   de correrlo en Supabase. Imita lo mínimo de Supabase que el esquema usa
   (roles, privilegios por defecto, auth.uid, storage, realtime) y prueba lo
   que un usuario podría hacer con la API: quién cambia qué en perfiles, el
   fiado con su cupo y qué funciones se pueden llamar.
   Se corre con `npm run probar` desde esta carpeta. */
import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'node:fs'

const db = new PGlite()
// Lo mínimo de Supabase: roles, privilegios por defecto del esquema public
// (en Supabase todo lo nuevo nace con permisos para anon y authenticated) y
// los esquemas auth y storage.
await db.exec(`
  create role anon nologin; create role authenticated nologin; create role service_role nologin bypassrls;
  grant usage on schema public to anon, authenticated, service_role;
  alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
  alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
  alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
  create schema auth; create schema storage;
  grant usage on schema auth, storage to anon, authenticated;
  create table auth.users (id uuid primary key, email text, raw_user_meta_data jsonb default '{}');
  create function auth.uid() returns uuid language sql stable as $$
    select (nullif(current_setting('request.jwt.claims', true), '')::json ->> 'sub')::uuid $$;
  grant execute on function auth.uid() to anon, authenticated;
  create table storage.buckets (id text primary key, name text, public boolean);
  create table storage.objects (id serial primary key, bucket_id text, name text);
  alter table storage.objects enable row level security;
  grant all on storage.objects to anon, authenticated;
  create publication supabase_realtime;
`)
await db.exec(readFileSync(new URL('schema.sql', import.meta.url), 'utf8'))

const DUENO = '00000000-0000-0000-0000-00000000000a'
const ANA = '00000000-0000-0000-0000-00000000000b'
const BETO = '00000000-0000-0000-0000-00000000000c'
await db.exec(`insert into auth.users (id, email, raw_user_meta_data) values
  ('${DUENO}', 'dueno@tienda.pe', '{"nombre":"Dueño"}'),
  ('${ANA}', 'ana@x.pe', '{"nombre":"Ana"}'),
  ('${BETO}', 'beto@x.pe', '{"nombre":"Beto"}')`)

// Como llega un pedido por la API: con el rol y el token del usuario.
const como = async (uid, rol = 'authenticated') => {
  await db.query('reset role')
  await db.query(`select set_config('request.jwt.claims', $1, false)`, [uid ? JSON.stringify({ sub: uid, role: rol }) : ''])
  await db.query(`set role ${rol}`)
}
const editor = async () => { await db.query('reset role'); await db.query(`select set_config('request.jwt.claims', '', false)`) }
const intenta = async (sql, params) => { try { return (await db.query(sql, params)).rows } catch (e) { return e } }
const perfil = async (id) => { await editor(); return (await db.query('select * from perfiles where id = $1', [id])).rows[0] }

let fallos = 0
const ok = (cond, msg) => { console.log((cond ? '  ok  ' : ' FALLA ') + msg); if (!cond) fallos++ }

console.log('— Perfiles —')
ok((await db.query('select count(*)::int n from perfiles')).rows[0].n === 3, 'el registro crea un perfil por usuario, como cliente')

await editor()
await db.query(`update perfiles set rol = 'tendero' where id = $1`, [DUENO])
ok((await perfil(DUENO)).rol === 'tendero', 'desde el editor SQL se asciende al dueño a tendero')

await como(ANA)
const propia = await intenta(`update perfiles set nombre = 'Ana P.', telefono = '999', direccion = 'Jr. Uno' where id = $1 returning nombre`, [ANA])
ok(Array.isArray(propia) && propia[0]?.nombre === 'Ana P.', 'el cliente edita su nombre, teléfono y dirección')

await como(ANA)
await intenta(`update perfiles set rol = 'tendero' where id = $1`, [ANA])
ok((await perfil(ANA)).rol === 'cliente', 'el cliente no puede ponerse rol de tendero')

await como(ANA)
await intenta(`update perfiles set limite_fiado = 99999 where id = $1`, [ANA])
ok(Number((await perfil(ANA)).limite_fiado) === 100, 'el cliente no puede subirse el cupo de fiado')

await como(ANA)
await intenta(`update perfiles set nombre = 'otro' where id = $1`, [BETO])
ok((await perfil(BETO)).nombre === 'Beto', 'el cliente no edita el perfil de otro')

await como(DUENO)
await intenta(`update perfiles set limite_fiado = 250 where id = $1`, [BETO])
ok(Number((await perfil(BETO)).limite_fiado) === 250, 'el tendero cambia el cupo de un cliente')

await como(DUENO)
await intenta(`update perfiles set rol = 'tendero' where id = $1`, [BETO])
ok((await perfil(BETO)).rol === 'cliente', 'el tendero tampoco asciende a nadie desde la app')

// Segunda capa: aunque alguien vuelva a abrir el update de toda la tabla, el
// trigger sigue frenando.
await editor()
await db.query('grant update on perfiles to authenticated')
await como(ANA)
const rolAbierto = await intenta(`update perfiles set rol = 'tendero' where id = $1`, [ANA])
await como(ANA)
const cupoAbierto = await intenta(`update perfiles set limite_fiado = 99999 where id = $1`, [ANA])
ok(/editor SQL/.test(rolAbierto.message) && /Solo el tendero/.test(cupoAbierto.message),
  'con el permiso abierto, el trigger igual frena rol y cupo')
await editor()
await db.query('revoke update on perfiles from authenticated')
await db.query('grant update (nombre, telefono, direccion, limite_fiado) on perfiles to authenticated')

await como(null, 'anon')
const anonimo = await intenta('select count(*)::int n from perfiles')
ok(Array.isArray(anonimo) && anonimo[0].n === 0, 'sin sesión no se ve ningún perfil')

console.log('\n— Pedidos y fiado —')
await editor()
const pan = (await db.query(`insert into productos (nombre, precio, stock) values ('Pan', 40, 10) returning id`)).rows[0].id
// El celular manda un precio de 1 céntimo: la base tiene que ignorarlo.
const pedir = (metodo, cantidad) => intenta(
  `insert into pedidos (cliente_id, items, metodo_pago, total) values ($1, $2, $3, 0.01) returning total`,
  [ANA, JSON.stringify([{ producto_id: pan, cantidad, precio_unitario: 0.01 }]), metodo])

await como(ANA)
const contado = await pedir('efectivo', 1)
ok(Array.isArray(contado) && Number(contado[0].total) === 40,
  `el total del pedido sale del precio de la base (dio ${contado[0]?.total ?? contado.message})`)

await como(ANA)
const fiado = await pedir('fiado', 2)
await editor()
const deuda = Number((await db.query('select coalesce(sum(monto), 0) d from movimientos_fiado where cliente_id = $1', [ANA])).rows[0].d)
ok(Array.isArray(fiado) && deuda === 80, `el cliente pide al fiado dentro de su cupo y debe 80 (debe ${deuda})`)

await como(ANA)
const otro = await pedir('fiado', 1)
ok(otro instanceof Error && /cupo/.test(otro.message), 'y no pasa del cupo de 100')

// Cada pedido descuenta stock al entrar: un cliente no puede tener más de 3
// en curso, o con pedidos falsos vaciaría la tienda.
await editor()
await db.query(`update productos set stock = 100 where id = $1`, [pan])
await db.query(`update pedidos set estado = 'entregado' where cliente_id = $1`, [ANA])
for (let i = 0; i < 3; i++) { await como(ANA); await pedir('efectivo', 1) }
await como(ANA)
const cuarto = await pedir('efectivo', 1)
ok(cuarto instanceof Error && /3 pedidos en curso/.test(cuarto.message),
  `el cuarto pedido en curso se rechaza (${cuarto.message ?? 'pasó'})`)
await editor()
await db.query(`update pedidos set estado = 'entregado'
  where id = (select id from pedidos where cliente_id = $1 and estado = 'pendiente' limit 1)`, [ANA])
await como(ANA)
const otraVez = await pedir('efectivo', 1)
ok(Array.isArray(otraVez), `cuando la tienda entrega uno, se puede volver a pedir (${otraVez.message ?? 'ok'})`)

console.log('\n— Funciones —')
await editor()
const puede = async (rol, firma) => (await db.query(`select has_function_privilege($1, $2, 'execute') p`, [rol, firma])).rows[0].p
// Todas las funciones del esquema, no una lista: si alguien agrega una y se
// olvida de cerrarla, esto falla.
const funciones = (await db.query(`select p.oid::regprocedure::text firma from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'`)).rows.map((f) => f.firma)
const permitidas = {
  anon: ['es_tendero()'],
  authenticated: ['borrar_mi_cuenta()', 'es_tendero()', 'registrar_produccion(uuid,text,numeric,integer,text,jsonb)'],
}
ok(funciones.length >= 9, `revisa las ${funciones.length} funciones del esquema`)
for (const rol of ['anon', 'authenticated']) {
  const abiertas = []
  for (const f of funciones) if (await puede(rol, `public.${f}`)) abiertas.push(f)
  ok(abiertas.sort().join() === permitidas[rol].sort().join(), `${rol} solo ejecuta ${permitidas[rol].join(' y ')} (ejecuta: ${abiertas.join(', ')})`)
}
await como(ANA)
const rpc = await intenta(`select registrar_produccion($1, 'Pan', 1, 30, '', '[]')`, [pan])
ok(rpc instanceof Error && /Solo el tendero/.test(rpc.message), 'un cliente llama a registrar_produccion y la función lo rechaza')
await editor()
const porDefecto = (await db.query(`select coalesce(array_agg(a::text), '{}') acl from pg_default_acl d, unnest(d.defaclacl) a
  where d.defaclobjtype = 'f' and d.defaclnamespace = 'public'::regnamespace`)).rows[0].acl
ok(!porDefecto.some((a) => /^(anon|authenticated)=/.test(a)), 'una función nueva ya no nace abierta para anon ni authenticated')
// Lo que se cree después (otra versión del esquema, el editor SQL del panel)
// no nace abierto: una tabla sin RLS sería legible con la clave publicable.
await db.exec(`create table public.tabla_nueva_de_prueba (id int);
  create sequence public.secuencia_nueva_de_prueba;
  create function public.funcion_nueva_de_prueba() returns int language sql as 'select 1'`)
for (const rol of ['anon', 'authenticated']) {
  const { rows: [p] } = await db.query(`select
    has_table_privilege($1, 'public.tabla_nueva_de_prueba', 'select, insert, update, delete') tabla,
    has_sequence_privilege($1, 'public.secuencia_nueva_de_prueba', 'usage, select, update') secuencia,
    has_function_privilege($1, 'public.funcion_nueva_de_prueba()', 'execute') funcion`, [rol])
  ok(!p.tabla && !p.secuencia && !p.funcion, `${rol} no usa una tabla, secuencia ni función nuevas (tabla ${p.tabla}, secuencia ${p.secuencia}, función ${p.funcion})`)
}
const { rows: [sr] } = await db.query(`select has_table_privilege('service_role', 'public.tabla_nueva_de_prueba', 'select') t,
  has_function_privilege('service_role', 'public.funcion_nueva_de_prueba()', 'execute') f`)
ok(sr.t && sr.f, 'service_role sigue con acceso a lo nuevo')
await db.exec(`drop table public.tabla_nueva_de_prueba; drop sequence public.secuencia_nueva_de_prueba;
  drop function public.funcion_nueva_de_prueba()`)

// Borrar la cuenta desde la app (derecho de cancelación; Play Store también lo
// pide). Lo que es del cliente se va; las ventas y el fiado ya saldado quedan
// en las cuentas del tendero, sin nombre. Si debe fiado o tiene un pedido en
// curso, no se borra nada: el tendero no puede perder una deuda ni quedarse
// con un pedido de nadie a medio entregar.
console.log('\n— Borrar la cuenta —')
const borrar = () => intenta('select borrar_mi_cuenta()')
const cuenta = async (sql, params) => { await editor(); return (await db.query(sql, params)).rows[0].n }

await como(DUENO)
const delTendero = await borrar()
ok(delTendero instanceof Error && /tendero/.test(delTendero.message), `el tendero no borra su cuenta desde la app (${delTendero.message ?? 'pasó'})`)

await editor()
await db.query(`update pedidos set direccion = 'Jr. Uno 123', notas = 'tocar el timbre' where cliente_id = $1`, [ANA])
await como(ANA)
const enCurso = await borrar()
ok(enCurso instanceof Error && /pedidos en curso/.test(enCurso.message), `con un pedido en curso no se borra (${enCurso.message ?? 'pasó'})`)
ok(await cuenta('select count(*)::int n from auth.users where id = $1', [ANA]) === 1, 'y la cuenta sigue')

await editor()
await db.query(`update pedidos set estado = 'entregado' where cliente_id = $1`, [ANA])
await como(ANA)
const debe = await borrar()
ok(debe instanceof Error && /S\/ 80\.00/.test(debe.message) && /fiado/.test(debe.message),
  `debiendo fiado no se borra, y el mensaje dice cuánto (${debe.message ?? 'pasó'})`)

await editor()
await db.query(`insert into movimientos_fiado (cliente_id, tipo, monto, descripcion) values ($1, 'abono', 80, 'Pago en tienda')`, [ANA])
const pedidosAntes = await cuenta('select count(*)::int n from pedidos where cliente_id = $1', [ANA])
const fiadoAntes = await cuenta('select count(*)::int n from movimientos_fiado where cliente_id = $1', [ANA])
const kardexAntes = await cuenta('select count(*)::int n from movimientos_inventario')
await como(ANA)
const listo = await borrar()
ok(Array.isArray(listo), `sin deuda ni pedidos en curso, la cuenta se borra (${listo.message ?? 'ok'})`)
ok(await cuenta('select count(*)::int n from auth.users where id = $1', [ANA]) === 0, 'su usuario ya no existe')
ok(await cuenta('select count(*)::int n from perfiles where id = $1', [ANA]) === 0, 'ni su perfil, con nombre, teléfono y dirección')
ok(await cuenta(`select count(*)::int n from pedidos where cliente_id is null and cliente_nombre = 'Cuenta borrada'
  and direccion = '' and notas = ''`) === pedidosAntes && pedidosAntes > 0,
  `sus ${pedidosAntes} pedidos quedan como ventas, sin nombre, dirección ni notas`)
ok(await cuenta('select count(*)::int n from movimientos_fiado where cliente_id is null') === fiadoAntes && fiadoAntes > 0,
  `sus ${fiadoAntes} movimientos de fiado quedan en la caja, sin cliente`)
ok(await cuenta('select count(*)::int n from movimientos_inventario') === kardexAntes, 'el kardex no cambia')
await como(DUENO)
const vistos = await intenta('select count(*)::int n from pedidos where cliente_id is null')
ok(Array.isArray(vistos) && vistos[0].n === pedidosAntes, 'el tendero sigue viendo esas ventas')

await como(BETO)
ok(Array.isArray(await borrar()), 'un cliente sin pedidos borra su cuenta')
ok(await cuenta('select count(*)::int n from auth.users where id = $1', [BETO]) === 0, 'y su usuario ya no existe')

await como(null, 'anon')
const sinSesion = await borrar()
ok(sinSesion instanceof Error, 'sin sesión no se puede llamar')

console.log(fallos ? `\n${fallos} FALLAS` : '\nTodo en orden')
process.exit(fallos ? 1 : 0)
