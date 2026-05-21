import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/domain.dart';
import '../../services/demo_repository.dart';
import '../shared/order_tile.dart';
import '../shared/section_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({required this.repository, super.key});

  final DemoRepository repository;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final orders = repository.activeOrders();
    final revenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final inRoute = orders.where((order) => order.status == OrderStatus.pickedUp).length;

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Painel de controle')),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Visão executiva',
            subtitle: 'Métricas operacionais, risco, auditoria e governança em uma única tela.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Kpi(label: 'GMV demo', value: money.format(revenue)),
                _Kpi(label: 'Pedidos ativos', value: '${orders.length}'),
                _Kpi(label: 'Entregas em rota', value: '$inRoute'),
                const _Kpi(label: 'Alertas críticos', value: '0'),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Pedidos em tempo real',
            child: Column(
              children: [
                for (final order in orders) OrderTile(order: order),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Centro de segurança',
            child: Column(
              children: const [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.policy),
                  title: Text('RLS ativo no Supabase'),
                  subtitle: Text('Políticas por papel para cliente, restaurante, entregador e admin.'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.receipt_long),
                  title: Text('Auditoria transacional'),
                  subtitle: Text('Eventos críticos gravados em audit_events.'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.key),
                  title: Text('Chaves sensíveis fora do app'),
                  subtitle: Text('Service role é usada somente em automações de servidor/simuladores.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Card.filled(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
