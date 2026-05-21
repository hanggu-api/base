# Arquitetura

## Clientes Flutter

A primeira entrega usa um app Flutter único (`apps/delivery_suite`) com `NavigationRail` para alternar perfis. Isso acelera validação e mantém componentes compartilhados. Em produção, a mesma base pode ser separada por flavors:

- `customer`: descoberta, carrinho, pagamento e rastreio.
- `restaurant`: pedidos, cardápio, horários e SLA.
- `courier`: disponibilidade, missões e prova de entrega.
- `admin`: auditoria, métricas, suporte e moderação.

## Backend Supabase

O Supabase fornece Auth, Postgres, PostGIS, Realtime e Storage. A migração cria tabelas centrais, índices geográficos e políticas RLS. O app deve usar anon key; automações server-side usam service role.

## Simulação

- `order_simulator.js`: cria pedidos em vários status.
- `gps_simulator.js`: publica pontos geográficos no formato EWKT aceito pelo PostGIS.

## Segurança

- RLS por entidade e papel.
- Funções transacionais `create_order` e `advance_order_status`.
- Auditoria de ações críticas.
- Princípio de menor privilégio para app e scripts.
