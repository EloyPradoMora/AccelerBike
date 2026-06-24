import 'package:app_movile/features/home/presentation/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AccelerBike());
}

class AccelerBike extends StatelessWidget {
  const AccelerBike({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccelerBike',
      initialRoute: '/home',
      routes: {
          '/home': (context) => const HomeView()
      },
    );
  }
}
