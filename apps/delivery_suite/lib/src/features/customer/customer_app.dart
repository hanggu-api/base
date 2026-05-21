import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/demo_repository.dart';
import '../shared/order_tile.dart';
import '../shared/section_card.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({required this.repository, super.key});

  final DemoRepository repository;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final restaurants = repository.restaurants();
    final selected = restaurants.first;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Cliente'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
          ],
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Entrega inteligente e segura',
            subtitle: 'Endereço demo: Av. Paulista, 1000 · pagamento protegido · rastreio em tempo real.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                Chip(label: Text('Promoções verificadas')),
                Chip(label: Text('Embalagem lacrada')),
                Chip(label: Text('Suporte 24/7')),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Restaurantes próximos',
            child: Column(
              children: [
                for (final restaurant in restaurants)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Icon(restaurant.isOpen ? Icons.storefront : Icons.lock_clock),
                    ),
                    title: Text(restaurant.name),
                    subtitle: Text(
                      '${restaurant.category} · ⭐ ${restaurant.rating} · ${restaurant.etaMinutes} min',
                    ),
                    trailing: Text(money.format(restaurant.deliveryFee)),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Cardápio: ${selected.name}',
            child: Column(
              children: [
                for (final item in repository.menu(selected.id))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: FilledButton.tonal(
                      onPressed: item.available ? () {} : null,
                      child: Text(item.available ? money.format(item.price) : 'Indisponível'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Pedidos acompanhados',
            child: Column(
              children: [
                for (final order in repository.activeOrders()) OrderTile(order: order),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
