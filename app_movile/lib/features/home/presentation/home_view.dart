import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/home/data/model/trip_statistics.dart';
import 'package:app_movile/features/statistics/presentation/statistics_view.dart';
import 'package:app_movile/features/home/presentation/widgets/home/home_content.dart';
import 'package:app_movile/features/profile/presentation/profile_view.dart';
import 'package:app_movile/features/route/presentation/route_view.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart'; // Importa tu nueva barra
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0; 

  // Mas adelante cambiar esto para que sean parametros que recibe de la base de datos
  TripStatistics stats = TripStatistics(
    weeklyDistance: 142,
    calories: 3240,
    goalPercentage: 85,
    isDeviceConnected: true,
  );

  // Cambiar esto para recibirlo en algun lugar
  final String userName = "Alessandro";
  final bool isConnected = true;

  List<Widget> _buildScreens() {
    return [
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido $userName',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            welcomeMessage(context, isConnected),
            const SizedBox(height: 24),
            metrics(context, stats.weeklyDistance, stats.calories.toString(), stats.goalPercentage),
            const SizedBox(height: 24),
            startTravel(context)
          ],
        ),
      ),
      const StatisticsView(),      
      const ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: topBar(context, isConnected),
      body: _buildScreens()[_selectedIndex],
      
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RouteView()),
          );
        },
        backgroundColor: AppColors.green,
        shape: const CircleBorder(),
        child: const Icon(Icons.directions_bike, color: Colors.black, size: 40),
      ),

      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}