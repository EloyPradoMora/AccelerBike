import 'package:app_movile/core/ble/ble_state_notifier.dart';
import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/home/data/model/trip_statistics.dart';
import 'package:app_movile/features/home/presentation/widgets/home/home_content.dart';
import 'package:app_movile/features/profile/presentation/profile_view.dart';
import 'package:app_movile/features/route/presentation/route_view.dart';
import 'package:app_movile/features/statistics/presentation/statistics_view.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Remplazar por datos reales desde BD
  final TripStatistics stats = TripStatistics(
    weeklyDistance: 142,
    calories: 3240,
    goalPercentage: 85,
    isDeviceConnected: true,
  );
  final String userName = 'Usuario';

  List<Widget> _buildScreens(bool isConnected) {
    return [
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido $userName',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
            ),
            const SizedBox(height: 8),
            welcomeMessage(context, isConnected), // estado real
            const SizedBox(height: 24),
            metrics(context, stats.weeklyDistance,
                stats.calories.toString(), stats.goalPercentage),
            const SizedBox(height: 24),
            startTravel(context),
          ],
        ),
      ),
      const StatisticsView(),
      const ProfileView(),
    ];
  }

  void _onFabPressed(bool isConnected) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dispositivo no conectado. Espera a que el sensor esté disponible.',
          ),
          backgroundColor: Color.fromARGB(255, 179, 67, 67),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RouteView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BleStateNotifier.instance,
      builder: (context, _) {
        final ble = BleStateNotifier.instance;
        return Scaffold(
          backgroundColor: const Color(0xFF0F1115),
          appBar: topBar(context, ble.isConnected),
          body: _buildScreens(ble.isConnected)[_selectedIndex],
          floatingActionButton: FloatingActionButton.large(
            onPressed: () => _onFabPressed(ble.isConnected),
            // deshabilitado cuando no hay conexión
            backgroundColor:
                ble.isConnected ? AppColors.green : AppColors.grey500,
            shape: const CircleBorder(),
            child: Icon(
              Icons.directions_bike,
              color: ble.isConnected ? Colors.black : Colors.white38,
              size: 40,
            ),
          ),
          bottomNavigationBar: NavBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        );
      },
    );
  }
}