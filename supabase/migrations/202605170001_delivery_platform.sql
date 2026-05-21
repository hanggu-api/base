create extension if not exists pgcrypto;
create extension if not exists postgis;

create type public.app_role as enum ('customer', 'restaurant_owner', 'courier', 'admin');
create type public.order_status as enum (
  'draft',
  'placed',
  'accepted',
  'preparing',
  'ready_for_pickup',
  'picked_up',
  'delivered',
  'canceled'
);
create type public.payment_status as enum ('pending', 'authorized', 'captured', 'refunded', 'failed');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null default 'customer',
  full_name text not null,
  phone text,
  avatar_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  category text not null,
  description text not null default '',
  rating numeric(2,1) not null default 5.0 check (rating between 0 and 5),
  delivery_fee_cents integer not null default 0 check (delivery_fee_cents >= 0),
  eta_minutes integer not null default 30 check (eta_minutes > 0),
  is_open boolean not null default false,
  address jsonb not null,
  location geography(point, 4326) not null,
  created_at timestamptz not null default now()
);

create table public.menu_items (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  name text not null,
  description text not null default '',
  price_cents integer not null check (price_cents > 0),
  available boolean not null default true,
  image_url text,
  created_at timestamptz not null default now()
);

create table public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id) on delete cascade,
  label text not null,
  address jsonb not null,
  location geography(point, 4326) not null,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.profiles(id),
  restaurant_id uuid not null references public.restaurants(id),
  courier_id uuid references public.profiles(id),
  address_id uuid not null references public.customer_addresses(id),
  status public.order_status not null default 'placed',
  subtotal_cents integer not null check (subtotal_cents >= 0),
  delivery_fee_cents integer not null check (delivery_fee_cents >= 0),
  total_cents integer generated always as (subtotal_cents + delivery_fee_cents) stored,
  payment_status public.payment_status not null default 'pending',
  notes text,
  placed_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  menu_item_id uuid not null references public.menu_items(id),
  quantity integer not null check (quantity > 0),
  unit_price_cents integer not null check (unit_price_cents > 0),
  total_cents integer generated always as (quantity * unit_price_cents) stored
);

create table public.courier_locations (
  id bigint generated always as identity primary key,
  courier_id uuid not null references public.profiles(id) on delete cascade,
  order_id uuid references public.orders(id) on delete set null,
  location geography(point, 4326) not null,
  speed_kmh numeric(5,2) not null default 0,
  battery_percent integer check (battery_percent between 0 and 100),
  recorded_at timestamptz not null default now()
);

create table public.audit_events (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id),
  action text not null,
  entity_table text not null,
  entity_id uuid,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create index restaurants_location_idx on public.restaurants using gist(location);
create index customer_addresses_location_idx on public.customer_addresses using gist(location);
create index courier_locations_location_idx on public.courier_locations using gist(location);
create index orders_customer_idx on public.orders(customer_id, placed_at desc);
create index orders_restaurant_idx on public.orders(restaurant_id, placed_at desc);
create index orders_courier_idx on public.orders(courier_id, placed_at desc);

create or replace function public.current_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_role() = 'admin', false)
$$;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_touch_updated_at
before update on public.profiles
for each row execute function public.touch_updated_at();

create trigger orders_touch_updated_at
before update on public.orders
for each row execute function public.touch_updated_at();

create or replace function public.create_order(
  p_restaurant_id uuid,
  p_address_id uuid,
  p_items jsonb,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_order_id uuid;
  v_subtotal integer;
  v_delivery_fee integer;
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  select coalesce(sum((item->>'quantity')::integer * mi.price_cents), 0)
    into v_subtotal
  from jsonb_array_elements(p_items) item
  join public.menu_items mi on mi.id = (item->>'menu_item_id')::uuid
  where mi.restaurant_id = p_restaurant_id and mi.available;

  if v_subtotal <= 0 then
    raise exception 'order must contain available items';
  end if;

  select delivery_fee_cents into v_delivery_fee
  from public.restaurants
  where id = p_restaurant_id and is_open;

  if v_delivery_fee is null then
    raise exception 'restaurant unavailable';
  end if;

  insert into public.orders(customer_id, restaurant_id, address_id, subtotal_cents, delivery_fee_cents, notes)
  values (auth.uid(), p_restaurant_id, p_address_id, v_subtotal, v_delivery_fee, p_notes)
  returning id into v_order_id;

  insert into public.order_items(order_id, menu_item_id, quantity, unit_price_cents)
  select v_order_id, mi.id, (item->>'quantity')::integer, mi.price_cents
  from jsonb_array_elements(p_items) item
  join public.menu_items mi on mi.id = (item->>'menu_item_id')::uuid
  where mi.restaurant_id = p_restaurant_id and mi.available;

  insert into public.audit_events(actor_id, action, entity_table, entity_id, metadata)
  values (auth.uid(), 'order.created', 'orders', v_order_id, jsonb_build_object('subtotal_cents', v_subtotal));

  return v_order_id;
end;
$$;

create or replace function public.advance_order_status(p_order_id uuid, p_status public.order_status)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  update public.orders o
  set status = p_status,
      courier_id = case when p_status in ('picked_up', 'delivered') and public.current_role() = 'courier' then auth.uid() else courier_id end
  where o.id = p_order_id
    and (
      o.customer_id = auth.uid()
      or o.courier_id = auth.uid()
      or exists (select 1 from public.restaurants r where r.id = o.restaurant_id and r.owner_id = auth.uid())
      or public.is_admin()
    );

  if not found then
    raise exception 'order not found or access denied';
  end if;

  insert into public.audit_events(actor_id, action, entity_table, entity_id, metadata)
  values (auth.uid(), 'order.status_changed', 'orders', p_order_id, jsonb_build_object('status', p_status));
end;
$$;

alter table public.profiles enable row level security;
alter table public.restaurants enable row level security;
alter table public.menu_items enable row level security;
alter table public.customer_addresses enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.courier_locations enable row level security;
alter table public.audit_events enable row level security;

create policy profiles_select_self_or_admin on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy profiles_update_self on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy restaurants_public_read on public.restaurants for select using (true);
create policy restaurants_owner_write on public.restaurants for all using (owner_id = auth.uid() or public.is_admin()) with check (owner_id = auth.uid() or public.is_admin());

create policy menu_items_public_read on public.menu_items for select using (true);
create policy menu_items_owner_write on public.menu_items for all using (
  exists (select 1 from public.restaurants r where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin()))
) with check (
  exists (select 1 from public.restaurants r where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin()))
);

create policy addresses_owner on public.customer_addresses for all using (customer_id = auth.uid() or public.is_admin()) with check (customer_id = auth.uid() or public.is_admin());

create policy orders_visible_by_party on public.orders for select using (
  customer_id = auth.uid()
  or courier_id = auth.uid()
  or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  or public.is_admin()
);
create policy orders_customer_insert on public.orders for insert with check (customer_id = auth.uid());
create policy orders_party_update on public.orders for update using (
  customer_id = auth.uid()
  or courier_id = auth.uid()
  or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  or public.is_admin()
);

create policy order_items_visible_by_order_party on public.order_items for select using (
  exists (
    select 1 from public.orders o
    join public.restaurants r on r.id = o.restaurant_id
    where o.id = order_id
      and (o.customer_id = auth.uid() or o.courier_id = auth.uid() or r.owner_id = auth.uid() or public.is_admin())
  )
);

create policy courier_locations_owner_insert on public.courier_locations for insert with check (courier_id = auth.uid() or public.is_admin());
create policy courier_locations_visible_by_delivery_party on public.courier_locations for select using (
  courier_id = auth.uid()
  or public.is_admin()
  or exists (
    select 1 from public.orders o
    join public.restaurants r on r.id = o.restaurant_id
    where o.id = order_id
      and (o.customer_id = auth.uid() or r.owner_id = auth.uid())
  )
);

create policy audit_admin_read on public.audit_events for select using (public.is_admin());
