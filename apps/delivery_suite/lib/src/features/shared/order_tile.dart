import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/domain.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(order.id.substring(order.id.length - 2))),
      title: Text('${order.restaurantName} • ${order.status.label}'),
      subtitle: Text(
        '${order.customerName} · ${order.distanceKm.toStringAsFixed(1)} km · ${order.createdMinutesAgo} min',
      ),
      trailing: Text(money.format(order.total)),
    );
  }
}
