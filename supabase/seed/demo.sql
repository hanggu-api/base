-- Demo identities use deterministic UUIDs for local development only.
insert into auth.users (id, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at)
values
  ('00000000-0000-4000-8000-000000000001', 'ana.cliente@example.com', crypt('Demo123456!', gen_salt('bf')), now(), '{"full_name":"Ana Souza"}', now(), now()),
  ('00000000-0000-4000-8000-000000000002', 'dono.restaurante@example.com', crypt('Demo123456!', gen_salt('bf')), now(), '{"full_name":"Marco Rossi"}', now(), now()),
  ('00000000-0000-4000-8000-000000000003', 'rafa.entregas@example.com', crypt('Demo123456!', gen_salt('bf')), now(), '{"full_name":"Rafa Entregas"}', now(), now()),
  ('00000000-0000-4000-8000-000000000004', 'admin@example.com', crypt('Demo123456!', gen_salt('bf')), now(), '{"full_name":"Admin Operações"}', now(), now())
on conflict (id) do nothing;

insert into public.profiles (id, role, full_name, phone)
values
  ('00000000-0000-4000-8000-000000000001', 'customer', 'Ana Souza', '+5511999990001'),
  ('00000000-0000-4000-8000-000000000002', 'restaurant_owner', 'Marco Rossi', '+5511999990002'),
  ('00000000-0000-4000-8000-000000000003', 'courier', 'Rafa Entregas', '+5511999990003'),
  ('00000000-0000-4000-8000-000000000004', 'admin', 'Admin Operações', '+5511999990004')
on conflict (id) do nothing;

insert into public.restaurants (id, owner_id, name, category, description, rating, delivery_fee_cents, eta_minutes, is_open, address, location)
values
  ('10000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000002', 'Cantina Aurora', 'Italiana', 'Massas artesanais e combos familiares.', 4.8, 690, 28, true, '{"street":"Rua Augusta","number":"1200","city":"São Paulo","state":"SP"}', st_setsrid(st_makepoint(-46.6559, -23.5617), 4326)::geography),
  ('10000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000002', 'Bowl Verde', 'Saudável', 'Saladas, bowls e sucos prensados.', 4.7, 490, 22, true, '{"street":"Alameda Santos","number":"900","city":"São Paulo","state":"SP"}', st_setsrid(st_makepoint(-46.6602, -23.5653), 4326)::geography)
on conflict (id) do nothing;

insert into public.menu_items (id, restaurant_id, name, description, price_cents, available)
values
  ('20000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'Combo Peregrino', 'Massa, bebida e sobremesa.', 4290, true),
  ('20000000-0000-4000-8000-000000000002', '10000000-0000-4000-8000-000000000001', 'Especial da Casa', 'Nhoque artesanal ao molho rústico.', 3450, true),
  ('20000000-0000-4000-8000-000000000003', '10000000-0000-4000-8000-000000000002', 'Bowl Proteico', 'Grãos, folhas, frango e molho cítrico.', 3650, true)
on conflict (id) do nothing;

insert into public.customer_addresses (id, customer_id, label, address, location, is_default)
values
  ('30000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', 'Casa', '{"street":"Av. Paulista","number":"1000","city":"São Paulo","state":"SP"}', st_setsrid(st_makepoint(-46.6520, -23.5640), 4326)::geography, true)
on conflict (id) do nothing;

insert into public.orders (id, customer_id, restaurant_id, courier_id, address_id, status, subtotal_cents, delivery_fee_cents, payment_status, notes)
values
  ('40000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', 'preparing', 7740, 690, 'authorized', 'Sem cebola'),
  ('40000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000002', '00000000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-000000000001', 'picked_up', 3650, 490, 'captured', null)
on conflict (id) do nothing;

insert into public.order_items (order_id, menu_item_id, quantity, unit_price_cents)
values
  ('40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 1, 4290),
  ('40000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000002', 1, 3450),
  ('40000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000003', 1, 3650)
on conflict do nothing;

insert into public.courier_locations (courier_id, order_id, location, speed_kmh, battery_percent)
values
  ('00000000-0000-4000-8000-000000000003', '40000000-0000-4000-8000-000000000002', st_setsrid(st_makepoint(-46.6559, -23.5617), 4326)::geography, 31.5, 92)
on conflict do nothing;
