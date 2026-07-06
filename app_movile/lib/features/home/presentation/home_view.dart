import 'package:app_movile/core/ble/ble_state_notifier.dart';
import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/home/presentation/widgets/home/home_content.dart';
import 'package:app_movile/features/profile/presentation/profile_view.dart';
import 'package:app_movile/features/route/presentation/route_view.dart';
import 'package:app_movile/features/statistics/presentation/statistics_view.dart';
import 'package:app_movile/core/network/supabase_service.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  String _userName = 'Ciclista';
  double totalDistance = 0.0;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchAndCalculateStatistics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUsage();
    });
  }
  Future<void> _loadUserName() async {
    final name = await supabaseService.getUserName();
    if (mounted) setState(() => _userName = name);
  }
  
  Future<void> _checkFirstTimeUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding && mounted) {
      _showWelcomePopup(context);
    }
  }

  void _showWelcomePopup(BuildContext context) {
    final nameController = TextEditingController();
    double selectedRadius = 29.0; 
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2128),
              title: const Text(
                '¡Bienvenido a AccelerBike!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para comenzar, necesitamos algunos datos básicos.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Tu Nombre',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Radio de la rueda (Pulgadas)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: selectedRadius,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E2128),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 26.0, child: Text('26"')),
                          DropdownMenuItem(value: 27.5, child: Text('27.5"')),
                          DropdownMenuItem(value: 29.0, child: Text('29"')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRadius = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                isSaving 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        setState(() => isSaving = true);

                        await supabaseService.saveInitialUserName(
                          name: nameController.text.trim(),
                        );

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('wheel_radius', selectedRadius);
                        await prefs.setBool('has_seen_onboarding', true);

                        setState(() => isSaving = false);
                        if (mounted) Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Comenzar'),
                    ),
              ],
            );
          }
        );
      },
    );
  }
  
  Future<void> _fetchAndCalculateStatistics() async {
    final trips = await supabaseService.getUserTrips();
    if (trips.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    double tempDistance = 0;
    for (var trip in trips) {
      tempDistance += (trip['total_distance_km'] ?? 0);
    }

    setState(() {
      totalDistance = tempDistance; 
      isLoading = false;
    });
  }

  List<Widget> _buildScreens(bool isConnected) {
    return [
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido $_userName',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold
                ),
            ),
            const SizedBox(height: 24),
            welcomeMessage(context, isConnected), 
            const SizedBox(height: 16),
            Divider(
              color: const Color(0xFF004407),
              thickness: 2, 
              indent: 20,   
              endIndent: 20,
            ),
            const SizedBox(height: 16),
            startTravel(context),
            const SizedBox(height: 28),     
            metrics(context, totalDistance.toStringAsFixed(1)),
            const SizedBox(height: 16),
            Divider(
              color: const Color(0xFF004407),
              thickness: 2, 
              indent: 20,  
              endIndent: 20,
            ),
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
          backgroundColor: Color(0xFFB34343),
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