import 'package:flutter/material.dart';

import '../../services/demo_repository.dart';
import '../shared/order_tile.dart';
import '../shared/section_card.dart';

class CourierApp extends StatelessWidget {
  const CourierApp({required this.repository, super.key});

  final DemoRepository repository;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Entregador')),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Missão atual',
            subtitle: 'Coleta segura, rota simulada e prova de entrega protegida.',
            child: Column(
              children: [
                OrderTile(order: repository.activeOrders()[1]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.route),
                        label: const Text('Iniciar rota'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.verified_user),
                        label: const Text('Validar coleta'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: StreamBuilder(
            stream: repository.simulatedCourierTrack(),
            builder: (context, snapshot) {
              final location = snapshot.data;
              return SectionCard(
                title: 'GPS simulado',
                subtitle: 'Use scripts/gps_simulator.js para alimentar o backend em tempo real.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: ${location?.latitude.toStringAsFixed(6) ?? '--'}'),
                    Text('Longitude: ${location?.longitude.toStringAsFixed(6) ?? '--'}'),
                    Text('Velocidade: ${location?.speedKmh.toStringAsFixed(1) ?? '--'} km/h'),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: location == null ? null : 0.62),
                  ],
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SectionCard(
            title: 'Ganhos e segurança',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                Chip(label: Text('Hoje: R$ 126,40')),
                Chip(label: Text('Score: 98/100')),
                Chip(label: Text('Check-in facial pendente')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
