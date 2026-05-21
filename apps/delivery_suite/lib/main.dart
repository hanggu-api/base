import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/features/admin/admin_dashboard.dart';
import 'src/features/courier/courier_app.dart';
import 'src/features/customer/customer_app.dart';
import 'src/features/restaurant/restaurant_app.dart';
import 'src/services/demo_repository.dart';
import 'src/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(const PeregrinoApp());
}

class PeregrinoApp extends StatelessWidget {
  const PeregrinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peregrino Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ExperienceShell(),
    );
  }
}

enum Experience { customer, restaurant, courier, admin }

class ExperienceShell extends StatefulWidget {
  const ExperienceShell({super.key});

  @override
  State<ExperienceShell> createState() => _ExperienceShellState();
}

class _ExperienceShellState extends State<ExperienceShell> {
  Experience _selected = Experience.customer;
  final DemoRepository _repository = DemoRepository();

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_selected) {
      Experience.customer => CustomerApp(repository: _repository),
      Experience.restaurant => RestaurantApp(repository: _repository),
      Experience.courier => CourierApp(repository: _repository),
      Experience.admin => AdminDashboard(repository: _repository),
    };

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selected.index,
            extended: MediaQuery.sizeOf(context).width > 980,
            onDestinationSelected: (index) {
              setState(() => _selected = Experience.values[index]);
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: Text('Cliente'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text('Restaurante'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.delivery_dining_outlined),
                selectedIcon: Icon(Icons.delivery_dining),
                label: Text('Entregador'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings),
                label: Text('Admin'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
