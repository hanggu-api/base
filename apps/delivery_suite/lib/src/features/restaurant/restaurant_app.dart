import 'package:flutter/material.dart';

import '../../models/domain.dart';
import '../../services/demo_repository.dart';
import '../shared/order_tile.dart';
import '../shared/section_card.dart';

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({required this.repository, super.key});

  final DemoRepository repository;

  @override
  Widget build(BuildContext context) {
    final orders = repository.activeOrders();
    final queue = orders.where((order) => order.status != OrderStatus.delivered).toList();

    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Restaurante')),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Operação da loja',
            subtitle: 'Controle tempo de preparo, disponibilidade do cardápio e aceite de pedidos.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(label: 'Pedidos na fila', value: '${queue.length}'),
                const _Metric(label: 'SLA médio', value: '18 min'),
                const _Metric(label: 'Cancelamentos', value: '0,7%'),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Fila de pedidos',
            child: Column(
              children: [
                for (final order in queue)
                  Column(
                    children: [
                      OrderTile(order: order),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: () {},
                              child: const Text('Aceitar / avançar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Reportar problema'),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Cardápio operacional',
            child: Column(
              children: [
                for (final item in repository.menu('restaurant-demo-1'))
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: item.available,
                    onChanged: (_) {},
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
