// lib/presentation/shared/layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/transactions/transactions_page.dart';
import '../../features/piggy_banks/piggy_banks_page.dart';
import '../../features/planning/planning_page.dart';
import '../../features/credit_cards/credit_cards_page.dart';
import '../../features/reports/reports_page.dart';
import '../../features/profile/profile_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  static const _pages = [
    DashboardPage(),
    TransactionsPage(),
    PiggyBanksPage(),
    PlanningPage(),
    CreditCardsPage(),
    ReportsPage(),
    ProfilePage(),
  ];

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),       activeIcon: Icon(Icons.home),       label: 'Início'),
    BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_outlined),  activeIcon: Icon(Icons.swap_horiz), label: 'Lançamentos'),
    BottomNavigationBarItem(icon: Icon(Icons.savings_outlined),     activeIcon: Icon(Icons.savings),    label: 'Caixinhas'),
    BottomNavigationBarItem(icon: Icon(Icons.flag_outlined),        activeIcon: Icon(Icons.flag),       label: 'Planejamento'),
    BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), activeIcon: Icon(Icons.credit_card),label: 'Cartões'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),   activeIcon: Icon(Icons.bar_chart),  label: 'Relatórios'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline),       activeIcon: Icon(Icons.person),     label: 'Perfil'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),        selectedIcon: Icon(Icons.home),        label: 'Início'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_outlined),  selectedIcon: Icon(Icons.swap_horiz),  label: 'Lançamentos'),
          NavigationDestination(icon: Icon(Icons.savings_outlined),     selectedIcon: Icon(Icons.savings),     label: 'Caixinhas'),
          NavigationDestination(icon: Icon(Icons.flag_outlined),        selectedIcon: Icon(Icons.flag),        label: 'Planejamento'),
          NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'Cartões'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),   selectedIcon: Icon(Icons.bar_chart),   label: 'Relatórios'),
          NavigationDestination(icon: Icon(Icons.person_outline),       selectedIcon: Icon(Icons.person),      label: 'Perfil'),
        ],
      ),
    );
  }
}