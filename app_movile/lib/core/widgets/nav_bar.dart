import 'package:flutter/material.dart';
import 'package:app_movile/core/theme/app_colors.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Aplicamos un Theme local para asegurarnos de que el fondo y los efectos sigan tu diseño oscuro
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xFF0F1115), // Mismo color de fondo de tu app
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1), // Línea sutil superior
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: const Color(0xFF0F1115),
          selectedItemColor: AppColors.green,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          type: BottomNavigationBarType.fixed, // Mantiene los elementos estables
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'INICIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined, size: 28),
              activeIcon: Icon(Icons.bar_chart, size: 28),
              label: 'ESTADÍSTICAS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'PERFIL',
            ),
          ],
        ),
      ),
    );
  }
}