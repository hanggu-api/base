# Peregrino Delivery Suite

Monorepo para uma plataforma moderna de delivery inspirada no fluxo de marketplaces de comida, com quatro experiências em Flutter e backend Supabase:

- **Cliente**: descoberta de restaurantes, carrinho, checkout e rastreamento.
- **Restaurante**: fila de pedidos, preparo, cardápio e operação.
- **Entregador**: missões, GPS simulado, status de coleta/entrega e ganhos.
- **Painel de controle**: métricas, segurança, auditoria, usuários e operações.

> O projeto evita copiar marcas, telas ou ativos proprietários. A implementação é uma base original, segura e expansível para um marketplace próprio.

## Estrutura

```text
apps/delivery_suite/        App Flutter único com seleção de perfil/experiência
supabase/migrations/        Schema PostgreSQL, RLS, funções e políticas
supabase/seed/              Dados demo de pessoas, restaurantes, entregadores e pedidos
scripts/                    Simuladores de GPS e pedidos demo
.github/workflows/          CI de validação estática do repositório
```

## Rodando localmente

### Pré-requisitos

- Flutter 3.22+.
- Supabase CLI.
- Node.js 20+ para os simuladores.

### Backend

```bash
supabase start
supabase db reset
```

### App

```bash
cd apps/delivery_suite
flutter pub get
flutter run --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

A tela inicial permite alternar entre Cliente, Restaurante, Entregador e Admin.

### Simuladores

```bash
node scripts/order_simulator.js --dry-run --orders 12
node scripts/gps_simulator.js --dry-run --courier courier-demo-1
```

Remova `--dry-run` e informe `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` para gravar no Supabase.

## Segurança implementada

- Row Level Security ativado em tabelas de domínio.
- Separação por papéis (`customer`, `restaurant_owner`, `courier`, `admin`).
- Funções `security definer` para criação transacional de pedidos e avanço de status.
- Auditoria com tabela `audit_events`.
- Dados sensíveis isolados em `profiles`, com políticas por dono/admin.
- App usa anon key apenas; simuladores que escrevem em massa exigem service role fora do app.

## Próximos passos sugeridos

1. Adicionar autenticação social/telefone via Supabase Auth.
2. Integrar gateway de pagamento real.
3. Substituir GPS simulado por stream nativo do aparelho.
4. Criar apps separados por flavor quando houver necessidade de distribuição independente.
