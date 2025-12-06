import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'flights_screen.dart';
import 'hotels_screen.dart';
import 'saved_items_screen.dart';
import 'account_screen.dart';
import '../theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;

  List<Widget> get _screens => [
    const FlightsScreen(),
    const HotelsScreen(),
    HomeScreen(onNavigateToTab: _onItemTapped),
    const SavedItemsScreen(),
    const AccountScreen(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.flight, label: 'Flights'),
    NavItem(icon: Icons.hotel, label: 'Hotels'),
    NavItem(icon: Icons.home, label: 'Home'),
    NavItem(icon: Icons.bookmark, label: 'Saved'),
    NavItem(icon: Icons.person, label: 'Account'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.mediumGrey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Stack(
              children: [
                // sliding indicator animation on nav items
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: (_currentIndex * (MediaQuery.of(context).size.width - 16) / _navItems.length) + 8,
                  top: 0,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 16) / _navItems.length - 16,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_navItems.length, (index) {
                    final isSelected = _currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _navItems[index].icon,
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : isDark
                                      ? const Color(0xFF808080)
                                      : AppColors.mediumGrey,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _navItems[index].label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.primaryOrange
                                    : isDark
                                        ? const Color(0xFF808080)
                                        : AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}
