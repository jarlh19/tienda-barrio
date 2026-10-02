-- Esquema de la tienda de barrio para Supabase.
-- Ejecutar completo en el SQL Editor del proyecto (una sola vez).

-- ---------------------------------------------------------------- perfiles --
create table if not exists public.perfiles (
  id            uuid primary key references auth.users on delete cascade,
  nombre        text not null default '',
  telefono      text not null default '',
  direccion     text not null default '',
  rol           text not null default 'cliente' check (rol in ('cliente','tendero')),
  limite_fiado  numeric(10,2) not null default 100,
  creado_en     timestamptz not null default now()
);

-- Cada usuario nuevo de auth recibe su fila de perfil con los datos del registro.
-- El rol SIEMPRE nace como 'cliente': al tendero se le asciende a mano
-- (ver la última sección de este archivo), nunca desde la app.
create or replace function public.crear_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Quien se registra con correo manda 'nombre'; quien entra con Google manda
  -- 'full_name' o 'name', y nunca telefono ni direccion. Si no llega ninguno,
  -- queda la parte del correo antes de la arroba: es preferible a una fila sin
  -- nombre, que el tendero veria como un pedido de nadie.
  insert into public.perfiles (id, nombre, telefono, direccion)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'nombre', ''),
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      nullif(new.raw_user_meta_data ->> 'name', ''),
      split_part(coalesce(new.email, ''), '@', 1),
      ''
    ),
    coalesce(new.raw_user_meta_data ->> 'telefono', ''),
    coalesce(new.raw_user_meta_data ->> 'direccion', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists al_crear_usuario on auth.users;
create trigger al_crear_usuario
  after insert on auth.users
  for each row execute function public.crear_perfil();

-- Saber si quien consulta es el tendero, sin recursión en las políticas.
create or replace function public.es_tendero()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.perfiles
    where id = auth.uid() and rol = 'tendero'
  );
$$;

-- -------------------------------------------------------------- catálogo ----
create table if not exists public.categorias (
  id      uuid primary key default gen_random_uuid(),
  nombre  text not null,
  emoji   text not null default ''
);

create table if not exists public.productos (
  id           uuid primary key default gen_random_uuid(),
  nombre       text not null,
  descripcion  text not null default '',
  precio       numeric(10,2) not null check (precio > 0),
  stock        integer not null default 0 check (stock >= 0),
  unidad       text not null default 'und',
  marca        text not null default '',
  -- Lo que le cuesta al tendero cada unidad: sin esto no hay utilidad.
  costo        numeric(10,2) not null default 0 check (costo >= 0),
  -- Produccion: 30 panes por plancha. 0 = el producto se compra hecho.
  unidades_por_lote   integer not null default 0 check (unidades_por_lote >= 0),
  nombre_lote         text not null default '',
  -- Venta: 4 panes por 1 sol. 0 o 1 = se vende por unidad.
  unidades_por_paquete integer not null default 0 check (unidades_por_paquete >= 0),
  -- Peso o volumen del envase (900 ml, 1 kg). 0 en lo que se vende a granel.
  contenido    numeric(10,3) not null default 0 check (contenido >= 0),
  medida       text not null default '' check (medida in ('','g','kg','ml','L','und')),
  imagen_url   text not null default '',
  -- EAN-13/UPC del envase. NULL (no '') en lo que se vende suelto, para que
  -- el índice único deje convivir varios productos sin etiqueta.
  codigo_barras text,
  categoria_id uuid references public.categorias on delete set null,
  activo       boolean not null default true,
  creado_en    timestamptz not null default now()
);

-- Para bases creadas antes del escáner y de la ficha ampliada.
alter table public.productos add column if not exists codigo_barras text;
alter table public.productos add column if not exists marca text not null default '';
alter table public.productos add column if not exists contenido numeric(10,3) not null default 0;
alter table public.productos add column if not exists medida text not null default '';
alter table public.productos add column if not exists costo numeric(10,2) not null default 0;
alter table public.productos add column if not exists unidades_por_lote integer not null default 0;
alter table public.productos add column if not exists nombre_lote text not null default '';
alter table public.productos add column if not exists unidades_por_paquete integer not null default 0;

create index if not exists productos_categoria_idx on public.productos (categoria_id);
create index if not exists productos_nombre_idx on public.productos (lower(nombre));
create index if not exists productos_marca_idx on public.productos (lower(marca));
create unique index if not exists productos_codigo_barras_idx
  on public.productos (codigo_barras)
  where codigo_barras is not null;

-- ---------------------------------------------------------------- tienda ----
-- Datos de cobro del negocio. Una sola fila: id fijo en 1.
create table if not exists public.tienda (
  id           integer primary key default 1 check (id = 1),
  nombre       text not null default 'Tienda de Barrio',
  numero_yape  text not null default '',
  numero_plin  text not null default '',
  qr_yape_url  text not null default '',
  qr_plin_url  text not null default '',
  creado_en    timestamptz not null default now()
);

insert into public.tienda (id) values (1) on conflict (id) do nothing;

-- ---------------------------------------------------------------- pedidos --
create table if not exists public.pedidos (
  id              uuid primary key default gen_random_uuid(),
  cliente_id      uuid not null references public.perfiles on delete cascade,
  cliente_nombre  text not null default '',
  items           jsonb not null default '[]'::jsonb,
  total           numeric(10,2) not null default 0,
  estado          text not null default 'pendiente'
                  check (estado in ('pendiente','confirmado','preparando','listo','entregado','cancelado')),
  metodo_pago     text not null default 'efectivo'
                  check (metodo_pago in ('efectivo','yape','plin','tarjeta','fiado')),
  estado_pago     text not null default 'pendiente'
                  check (estado_pago in ('pendiente','verificando','pagado','fiado','fallido')),
  referencia_pago text not null default '',
  direccion       text not null default '',
  notas           text not null default '',
  creado_en       timestamptz not null default now()
);

create index if not exists pedidos_cliente_idx on public.pedidos (cliente_id, creado_en desc);
create index if not exists pedidos_estado_idx on public.pedidos (estado);

-- El pedido lo arma el celular del cliente: precio, nombre y estado de pago
-- llegan como datos, no como verdad. Este trigger los reescribe desde la base
-- ANTES de guardar. Sin esto, un cliente podria pedirse el pan a 1 centimo o
-- marcar su pedido como pagado.
create or replace function public.sanear_pedido()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  item      jsonb;
  producto  public.productos%rowtype;
  saneados  jsonb := '[]'::jsonb;
  cantidad  integer;
  cupo      numeric;
  deuda     numeric;
  total     numeric := 0;
begin
  -- El nombre sale del perfil, no del payload.
  select coalesce(nombre, '') into new.cliente_nombre
    from public.perfiles where id = new.cliente_id;

  if jsonb_array_length(coalesce(new.items, '[]'::jsonb)) = 0 then
    raise exception 'El pedido no tiene productos';
  end if;

  for item in select * from jsonb_array_elements(new.items) loop
    select * into producto from public.productos
     where id = (item ->> 'producto_id')::uuid and activo;
    if not found then
      raise exception 'Ese producto ya no esta disponible';
    end if;

    cantidad := greatest(1, (item ->> 'cantidad')::int);
    if cantidad > producto.stock then
      raise exception 'Solo quedan % de %', producto.stock, producto.nombre;
    end if;

    -- El precio y el nombre se toman del catalogo, no del cliente.
    saneados := saneados || jsonb_build_object(
      'producto_id', producto.id,
      'nombre', trim(both ' ' from coalesce(producto.marca,'') || ' ' || producto.nombre),
      'precio_unitario', producto.precio,
      'cantidad', cantidad,
      'unidad', producto.unidad
    );
    total := total + (producto.precio * cantidad);
  end loop;

  new.items := saneados;

  -- El estado de pago lo decide el metodo, nunca el cliente.
  new.estado_pago := case new.metodo_pago
    when 'efectivo' then 'pendiente'
    when 'yape'     then 'verificando'
    when 'plin'     then 'verificando'
    when 'fiado'    then 'fiado'
    else null
  end;
  if new.estado_pago is null then
    raise exception 'Ese metodo de pago no esta habilitado';
  end if;

  -- El cupo de fiado se valida aqui: la comprobacion del celular es una
  -- comodidad para el usuario, no un control.
  if new.metodo_pago = 'fiado' then
    select coalesce(limite_fiado, 0) into cupo
      from public.perfiles where id = new.cliente_id;
    select coalesce(sum(case when tipo = 'cargo' then monto else -monto end), 0)
      into deuda
      from public.movimientos_fiado where cliente_id = new.cliente_id;
    if greatest(deuda, 0) + total > cupo then
      raise exception 'Tu cupo de fiado no alcanza para este pedido';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists al_sanear_pedido on public.pedidos;
create trigger al_sanear_pedido
  before insert on public.pedidos
  for each row execute function public.sanear_pedido();

-- El total lo calcula la base a partir de los items: el cliente no lo decide.
create or replace function public.calcular_total_pedido()
returns trigger
language plpgsql
as $$
begin
  select coalesce(sum((i ->> 'precio_unitario')::numeric * (i ->> 'cantidad')::int), 0)
    into new.total
  from jsonb_array_elements(new.items) as i;
  return new;
end;
$$;

drop trigger if exists al_guardar_pedido on public.pedidos;
create trigger al_guardar_pedido
  before insert or update of items on public.pedidos
  for each row execute function public.calcular_total_pedido();

-- Al entrar el pedido se registra la venta en el kardex; al cancelarlo, la
-- devolucion. El stock lo mueve el trigger del kardex, no este.
create or replace function public.mover_stock()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  item jsonb;
begin
  if tg_op = 'INSERT' then
    -- Si el pedido va al fiado, la deuda se carga aqui. La policy de
    -- movimientos_fiado solo deja escribir al tendero, y esta funcion corre
    -- como security definer: el cliente nunca escribe su propia deuda.
    if new.metodo_pago = 'fiado' then
      insert into public.movimientos_fiado
        (cliente_id, tipo, monto, descripcion, pedido_id, fecha)
      values (
        new.cliente_id, 'cargo',
        (select coalesce(sum((i ->> 'precio_unitario')::numeric * (i ->> 'cantidad')::int), 0)
           from jsonb_array_elements(new.items) as i),
        'Pedido ' || upper(left(new.id::text, 6)),
        new.id, new.creado_en
      );
    end if;

    for item in select * from jsonb_array_elements(new.items) loop
      insert into public.movimientos_inventario
        (producto_id, producto_nombre, tipo, unidades, monto, nota, pedido_id, fecha)
      values (
        (item ->> 'producto_id')::uuid,
        item ->> 'nombre',
        'venta',
        (item ->> 'cantidad')::int,
        (item ->> 'precio_unitario')::numeric * (item ->> 'cantidad')::int,
        'Pedido ' || upper(left(new.id::text, 6)),
        new.id,
        new.creado_en
      );
    end loop;
  elsif tg_op = 'UPDATE'
        and new.estado = 'cancelado'
        and old.estado <> 'cancelado' then
    if new.metodo_pago = 'fiado' then
      insert into public.movimientos_fiado
        (cliente_id, tipo, monto, descripcion, pedido_id)
      values (
        new.cliente_id, 'abono', new.total,
        'Pedido ' || upper(left(new.id::text, 6)) || ' cancelado', new.id
      );
    end if;

    for item in select * from jsonb_array_elements(new.items) loop
      insert into public.movimientos_inventario
        (producto_id, producto_nombre, tipo, unidades, monto, nota, pedido_id)
      values (
        (item ->> 'producto_id')::uuid,
        item ->> 'nombre',
        'devolucion',
        (item ->> 'cantidad')::int,
        (item ->> 'precio_unitario')::numeric * (item ->> 'cantidad')::int,
        'Pedido ' || upper(left(new.id::text, 6)) || ' cancelado',
        new.id
      );
    end loop;
  end if;
  return new;
end;
$$;

drop trigger if exists al_mover_stock on public.pedidos;
create trigger al_mover_stock
  after insert or update of estado on public.pedidos
  for each row execute function public.mover_stock();

-- --------------------------------------------------- kardex de inventario ---
-- Todo lo que entra o sale del inventario deja una fila aqui: produccion,
-- compra, venta, merma, ajuste y devolucion. El stock del producto es el
-- saldo de estos movimientos, y la caja del dia es su suma en soles.
create table if not exists public.movimientos_inventario (
  id              uuid primary key default gen_random_uuid(),
  producto_id     uuid references public.productos on delete set null,
  -- Nombre congelado: el historico no cambia si manana se renombra el producto.
  producto_nombre text not null default '',
  tipo            text not null
                  check (tipo in ('produccion','compra','venta','merma','ajuste','devolucion')),
  unidades        integer not null check (unidades > 0),
  -- Ingreso si fue venta; costo si fue produccion, compra o merma.
  monto           numeric(10,2) not null default 0 check (monto >= 0),
  lotes           numeric(10,2) not null default 0,
  nota            text not null default '',
  pedido_id       uuid references public.pedidos on delete set null,
  -- La produccion gasto insumos ya comprados: vale como costo del lote, pero
  -- no vuelve a salir de la caja (la plata salio al comprar la harina).
  desde_insumos   boolean not null default false,
  fecha           timestamptz not null default now()
);

alter table public.movimientos_inventario
  add column if not exists desde_insumos boolean not null default false;

create index if not exists movimientos_inv_fecha_idx
  on public.movimientos_inventario (fecha desc);
create index if not exists movimientos_inv_producto_idx
  on public.movimientos_inventario (producto_id, fecha desc);

-- Un movimiento del kardex mueve el saldo del producto. Es el unico camino:
-- asi el stock nunca puede quedar desfasado del historico.
create or replace function public.aplicar_movimiento()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  delta integer;
begin
  delta := case
    when new.tipo in ('produccion','compra','devolucion','ajuste') then new.unidades
    else -new.unidades
  end;

  update public.productos
     set stock = greatest(0, stock + delta)
   where id = new.producto_id;

  return new;
end;
$$;

drop trigger if exists al_mover_inventario on public.movimientos_inventario;
create trigger al_mover_inventario
  after insert on public.movimientos_inventario
  for each row execute function public.aplicar_movimiento();

-- ----------------------------------------------------------------- fiado ----
create table if not exists public.movimientos_fiado (
  id           uuid primary key default gen_random_uuid(),
  cliente_id   uuid not null references public.perfiles on delete cascade,
  tipo         text not null check (tipo in ('cargo','abono')),
  monto        numeric(10,2) not null check (monto > 0),
  descripcion  text not null default '',
  pedido_id    uuid references public.pedidos on delete set null,
  fecha        timestamptz not null default now()
);

create index if not exists fiado_cliente_idx on public.movimientos_fiado (cliente_id, fecha desc);

-- ---------------------------------------------------------------- insumos ---
-- Materia prima que se consume para producir. No se vende, por eso vive
-- aparte del catalogo. Se compra en presentacion (saco de 50 kg) pero el
-- stock y el costo se guardan siempre en la unidad base (kg).
create table if not exists public.insumos (
  id                        uuid primary key default gen_random_uuid(),
  nombre                    text not null,
  marca                     text not null default '',
  unidad                    text not null default 'kg'
                            check (unidad in ('g','kg','ml','L','und')),
  stock                     numeric(12,3) not null default 0 check (stock >= 0),
  -- Promedio ponderado de lo comprado, no el ultimo precio.
  costo_unitario            numeric(12,4) not null default 0 check (costo_unitario >= 0),
  nombre_presentacion       text not null default '',
  unidades_por_presentacion numeric(12,3) not null default 0,
  stock_minimo              numeric(12,3) not null default 0,
  activo                    boolean not null default true,
  creado_en                 timestamptz not null default now()
);

create table if not exists public.movimientos_insumo (
  id             uuid primary key default gen_random_uuid(),
  insumo_id      uuid references public.insumos on delete set null,
  insumo_nombre  text not null default '',
  tipo           text not null check (tipo in ('compra','consumo','merma','ajuste')),
  cantidad       numeric(12,3) not null check (cantidad > 0),
  monto          numeric(12,2) not null default 0 check (monto >= 0),
  presentaciones numeric(12,3) not null default 0,
  nota           text not null default '',
  -- Movimiento de produccion que gasto este insumo.
  produccion_id  uuid references public.movimientos_inventario on delete set null,
  fecha          timestamptz not null default now()
);

create index if not exists movimientos_insumo_fecha_idx
  on public.movimientos_insumo (fecha desc);
create index if not exists movimientos_insumo_insumo_idx
  on public.movimientos_insumo (insumo_id, fecha desc);

-- Receta: cuanto de cada insumo lleva un lote del producto.
-- Una plancha de pan frances lleva 2 kg de harina.
create table if not exists public.recetas (
  producto_id       uuid not null references public.productos on delete cascade,
  insumo_id         uuid not null references public.insumos on delete cascade,
  cantidad_por_lote numeric(12,4) not null check (cantidad_por_lote > 0),
  primary key (producto_id, insumo_id)
);

-- Un movimiento de insumo mueve su stock. La compra ademas recalcula el costo
-- promedio: si quedaban 20 kg a 3.60 y entran 50 kg a 4.00, el kilo pasa a 3.89.
create or replace function public.aplicar_movimiento_insumo()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  actual public.insumos%rowtype;
  nuevo_stock numeric;
begin
  select * into actual from public.insumos where id = new.insumo_id;
  if not found then
    return new;
  end if;

  if new.tipo = 'compra' then
    nuevo_stock := actual.stock + new.cantidad;
    update public.insumos
       set stock = nuevo_stock,
           costo_unitario = case
             when nuevo_stock <= 0 then actual.costo_unitario
             else ((actual.stock * actual.costo_unitario) + new.monto) / nuevo_stock
           end
     where id = new.insumo_id;
  elsif new.tipo = 'ajuste' then
    update public.insumos
       set stock = actual.stock + new.cantidad
     where id = new.insumo_id;
  else
    update public.insumos
       set stock = greatest(0, actual.stock - new.cantidad)
     where id = new.insumo_id;
  end if;

  return new;
end;
$$;

drop trigger if exists al_mover_insumo on public.movimientos_insumo;
create trigger al_mover_insumo
  after insert on public.movimientos_insumo
  for each row execute function public.aplicar_movimiento_insumo();

-- Una horneada, en una sola transaccion: descuenta los insumos, mete las
-- unidades al inventario y deja el costo real del lote en el producto.
-- Si algo falla, no queda ni harina descontada ni pan sin costo.
create or replace function public.registrar_produccion(
  p_producto_id     uuid,
  p_producto_nombre text,
  p_lotes           numeric,
  p_unidades        integer,
  p_nota            text,
  p_consumos        jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  consumo      jsonb;
  insumo       public.insumos%rowtype;
  cantidad     numeric;
  costo_total  numeric := 0;
  produccion   uuid;
begin
  if not public.es_tendero() then
    raise exception 'Solo el tendero puede registrar produccion';
  end if;

  if p_unidades <= 0 then
    raise exception 'Indica cuantas unidades salieron';
  end if;

  -- Primero se comprueba que alcance todo: mejor no empezar que dejar el
  -- almacen a medio descontar.
  for consumo in select * from jsonb_array_elements(coalesce(p_consumos, '[]'::jsonb)) loop
    select * into insumo from public.insumos
     where id = (consumo ->> 'insumo_id')::uuid;
    if not found then
      raise exception 'Ese insumo ya no existe';
    end if;
    cantidad := (consumo ->> 'cantidad')::numeric;
    if cantidad > insumo.stock then
      raise exception 'No alcanza %: quedan % % y necesitas %',
        insumo.nombre, insumo.stock, insumo.unidad, cantidad;
    end if;
  end loop;

  insert into public.movimientos_inventario
    (producto_id, producto_nombre, tipo, unidades, monto, lotes, nota, desde_insumos)
  values
    (p_producto_id, p_producto_nombre, 'produccion', p_unidades, 0, p_lotes,
     coalesce(p_nota, ''), jsonb_array_length(coalesce(p_consumos, '[]'::jsonb)) > 0)
  returning id into produccion;

  for consumo in select * from jsonb_array_elements(coalesce(p_consumos, '[]'::jsonb)) loop
    select * into insumo from public.insumos
     where id = (consumo ->> 'insumo_id')::uuid;
    cantidad := (consumo ->> 'cantidad')::numeric;
    costo_total := costo_total + (cantidad * insumo.costo_unitario);

    insert into public.movimientos_insumo
      (insumo_id, insumo_nombre, tipo, cantidad, monto, nota, produccion_id)
    values
      (insumo.id, trim(insumo.marca || ' ' || insumo.nombre), 'consumo',
       cantidad, cantidad * insumo.costo_unitario, coalesce(p_nota, ''), produccion);
  end loop;

  update public.movimientos_inventario
     set monto = costo_total
   where id = produccion;

  -- El costo del producto queda al de esta horneada: si subio la harina, el
  -- margen que ve el tendero se entera hoy.
  if costo_total > 0 then
    update public.productos
       set costo = costo_total / p_unidades
     where id = p_producto_id;
  end if;

  return jsonb_build_object('produccion_id', produccion, 'costo_total', costo_total);
end;
$$;

-- ------------------------------------------------------------------ RLS -----
alter table public.perfiles           enable row level security;
alter table public.categorias         enable row level security;
alter table public.productos          enable row level security;
alter table public.pedidos            enable row level security;
alter table public.movimientos_fiado  enable row level security;
alter table public.tienda             enable row level security;
alter table public.movimientos_inventario enable row level security;
alter table public.insumos              enable row level security;
alter table public.movimientos_insumo   enable row level security;
alter table public.recetas              enable row level security;

-- perfiles: cada quien ve el suyo; el tendero ve a todos sus clientes.
drop policy if exists perfiles_leer on public.perfiles;
create policy perfiles_leer on public.perfiles
  for select using (id = auth.uid() or public.es_tendero());

drop policy if exists perfiles_editar on public.perfiles;
create policy perfiles_editar on public.perfiles
  for update using (id = auth.uid() or public.es_tendero());

-- Vista publica del catalogo: lo que el cliente necesita para comprar y nada
-- mas. Deja fuera costo, margen y datos de produccion, que son informacion
-- del negocio. RLS filtra filas, no columnas: por eso hace falta la vista.
create or replace view public.catalogo
with (security_invoker = true) as
select id, nombre, marca, descripcion, precio, stock, unidad, contenido,
       medida, imagen_url, categoria_id, unidades_por_paquete, activo
  from public.productos
 where activo;

grant select on public.catalogo to authenticated;

-- catálogo: la tabla completa (con costos) solo la ve el tendero; el cliente
-- lee la vista de arriba.
drop policy if exists categorias_leer on public.categorias;
create policy categorias_leer on public.categorias
  for select to authenticated using (true);

drop policy if exists categorias_admin on public.categorias;
create policy categorias_admin on public.categorias
  for all using (public.es_tendero()) with check (public.es_tendero());

drop policy if exists productos_leer on public.productos;
create policy productos_leer on public.productos
  for select to authenticated using (public.es_tendero());

drop policy if exists productos_admin on public.productos;
create policy productos_admin on public.productos
  for all using (public.es_tendero()) with check (public.es_tendero());

-- kardex: es informacion del negocio, solo la ve y la escribe el tendero.
-- El trigger de pedidos corre como security definer del dueno de la funcion,
-- por eso un cliente puede pedir sin tener permiso sobre esta tabla.
drop policy if exists inventario_admin on public.movimientos_inventario;
create policy inventario_admin on public.movimientos_inventario
  for all using (public.es_tendero()) with check (public.es_tendero());

-- insumos, sus movimientos y las recetas: informacion interna del negocio.
-- El cliente no tiene por que saber cuanta harina lleva el pan.
drop policy if exists insumos_admin on public.insumos;
create policy insumos_admin on public.insumos
  for all using (public.es_tendero()) with check (public.es_tendero());

drop policy if exists movimientos_insumo_admin on public.movimientos_insumo;
create policy movimientos_insumo_admin on public.movimientos_insumo
  for all using (public.es_tendero()) with check (public.es_tendero());

drop policy if exists recetas_admin on public.recetas;
create policy recetas_admin on public.recetas
  for all using (public.es_tendero()) with check (public.es_tendero());

-- tienda: el cliente necesita leer el QR para pagar; solo el tendero lo cambia.
drop policy if exists tienda_leer on public.tienda;
create policy tienda_leer on public.tienda
  for select to authenticated using (true);

drop policy if exists tienda_admin on public.tienda;
create policy tienda_admin on public.tienda
  for all using (public.es_tendero()) with check (public.es_tendero());

-- pedidos: el cliente ve y crea los suyos; el tendero ve y gestiona todos.
drop policy if exists pedidos_leer on public.pedidos;
create policy pedidos_leer on public.pedidos
  for select using (cliente_id = auth.uid() or public.es_tendero());

drop policy if exists pedidos_crear on public.pedidos;
create policy pedidos_crear on public.pedidos
  for insert with check (cliente_id = auth.uid());

drop policy if exists pedidos_gestionar on public.pedidos;
create policy pedidos_gestionar on public.pedidos
  for update using (public.es_tendero()) with check (public.es_tendero());

-- fiado: el cliente solo mira; quien carga o abona es el tendero.
drop policy if exists fiado_leer on public.movimientos_fiado;
create policy fiado_leer on public.movimientos_fiado
  for select using (cliente_id = auth.uid() or public.es_tendero());

drop policy if exists fiado_admin on public.movimientos_fiado;
create policy fiado_admin on public.movimientos_fiado
  for all using (public.es_tendero()) with check (public.es_tendero());

-- ------------------------------------------------------- QR de los pagos ----
-- Bucket público: el cliente tiene que poder ver el QR para pagar.
insert into storage.buckets (id, name, public)
values ('tienda', 'tienda', true)
on conflict (id) do nothing;

drop policy if exists qr_leer on storage.objects;
create policy qr_leer on storage.objects
  for select using (bucket_id = 'tienda');

-- Subir o reemplazar el QR es cosa del tendero.
drop policy if exists qr_subir on storage.objects;
create policy qr_subir on storage.objects
  for insert to authenticated
  with check (bucket_id = 'tienda' and public.es_tendero());

drop policy if exists qr_actualizar on storage.objects;
create policy qr_actualizar on storage.objects
  for update to authenticated
  using (bucket_id = 'tienda' and public.es_tendero());

drop policy if exists qr_borrar on storage.objects;
create policy qr_borrar on storage.objects
  for delete to authenticated
  using (bucket_id = 'tienda' and public.es_tendero());

-- Pedidos en vivo en el panel del tendero.
alter publication supabase_realtime add table public.pedidos;

-- ------------------------------------------------------------ datos base ----
insert into public.categorias (nombre, emoji) values
  ('Abarrotes', '🥫'),
  ('Bebidas', '🥤'),
  ('Limpieza', '🧼'),
  ('Snacks', '🍪'),
  ('Panadería', '🥖')
on conflict do nothing;

-- Después de registrarte en la app con el correo del dueño, ascender ese
-- usuario a tendero (reemplaza el correo):
--
--   update public.perfiles set rol = 'tendero'
--    where id = (select id from auth.users where email = 'dueno@tienda.com');
