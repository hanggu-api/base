class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.etaMinutes,
    required this.deliveryFee,
    required this.isOpen,
  });

  final String id;
  final String name;
  final String category;
  final double rating;
  final int etaMinutes;
  final double deliveryFee;
  final bool isOpen;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final bool available;
}

class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.restaurantName,
    required this.courierName,
    required this.status,
    required this.total,
    required this.distanceKm,
    required this.createdMinutesAgo,
  });

  final String id;
  final String customerName;
  final String restaurantName;
  final String courierName;
  final OrderStatus status;
  final double total;
  final double distanceKm;
  final int createdMinutesAgo;
}

enum OrderStatus {
  draft,
  placed,
  accepted,
  preparing,
  readyForPickup,
  pickedUp,
  delivered,
  canceled,
}

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.draft => 'Rascunho',
        OrderStatus.placed => 'Recebido',
        OrderStatus.accepted => 'Aceito',
        OrderStatus.preparing => 'Preparando',
        OrderStatus.readyForPickup => 'Pronto',
        OrderStatus.pickedUp => 'Em rota',
        OrderStatus.delivered => 'Entregue',
        OrderStatus.canceled => 'Cancelado',
      };
}

class CourierLocation {
  const CourierLocation({
    required this.courierName,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.updatedSecondsAgo,
  });

  final String courierName;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final int updatedSecondsAgo;
}
