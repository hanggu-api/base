import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/domain.dart';

class DemoRepository {
  DemoRepository() : _random = Random(7);

  final Random _random;

  bool get hasSupabase => Supabase.instance.client.supabaseUrl.isNotEmpty;

  List<Restaurant> restaurants() => const [
        Restaurant(
          id: 'restaurant-demo-1',
          name: 'Cantina Aurora',
          category: 'Italiana',
          rating: 4.8,
          etaMinutes: 28,
          deliveryFee: 6.9,
          isOpen: true,
        ),
        Restaurant(
          id: 'restaurant-demo-2',
          name: 'Bowl Verde',
          category: 'Saudável',
          rating: 4.7,
          etaMinutes: 22,
          deliveryFee: 4.9,
          isOpen: true,
        ),
        Restaurant(
          id: 'restaurant-demo-3',
          name: 'Brasa Central',
          category: 'Churrasco',
          rating: 4.6,
          etaMinutes: 38,
          deliveryFee: 8.5,
          isOpen: false,
        ),
      ];

  List<MenuItem> menu(String restaurantId) => [
        MenuItem(
          id: 'item-1',
          restaurantId: restaurantId,
          name: 'Combo Peregrino',
          description: 'Prato principal, bebida e sobremesa com embalagem lacrada.',
          price: 42.9,
          available: true,
        ),
        MenuItem(
          id: 'item-2',
          restaurantId: restaurantId,
          name: 'Especial da Casa',
          description: 'Receita autoral com ingredientes rastreados.',
          price: 34.5,
          available: true,
        ),
        MenuItem(
          id: 'item-3',
          restaurantId: restaurantId,
          name: 'Entrega Econômica',
          description: 'Opção compacta para almoço rápido.',
          price: 24.9,
          available: false,
        ),
      ];

  List<DeliveryOrder> activeOrders() => const [
        DeliveryOrder(
          id: 'order-demo-1001',
          customerName: 'Ana Souza',
          restaurantName: 'Cantina Aurora',
          courierName: 'Rafa Entregas',
          status: OrderStatus.preparing,
          total: 73.8,
          distanceKm: 3.2,
          createdMinutesAgo: 14,
        ),
        DeliveryOrder(
          id: 'order-demo-1002',
          customerName: 'Bruno Lima',
          restaurantName: 'Bowl Verde',
          courierName: 'Lia Moto',
          status: OrderStatus.pickedUp,
          total: 51.4,
          distanceKm: 5.7,
          createdMinutesAgo: 26,
        ),
        DeliveryOrder(
          id: 'order-demo-1003',
          customerName: 'Carla Nunes',
          restaurantName: 'Cantina Aurora',
          courierName: 'Aguardando aceite',
          status: OrderStatus.placed,
          total: 39.9,
          distanceKm: 1.9,
          createdMinutesAgo: 3,
        ),
      ];

  Stream<CourierLocation> simulatedCourierTrack() async* {
    var lat = -23.5617;
    var lng = -46.6559;
    while (true) {
      lat += (_random.nextDouble() - 0.45) / 2000;
      lng += (_random.nextDouble() - 0.45) / 2000;
      yield CourierLocation(
        courierName: 'Rafa Entregas',
        latitude: lat,
        longitude: lng,
        speedKmh: 25 + _random.nextDouble() * 18,
        updatedSecondsAgo: 0,
      );
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}
