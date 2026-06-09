import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendly/models/transaction.dart';
import 'package:spendly/screens/add_transaction_screen.dart';
import 'package:spendly/screens/analytics_screen.dart';
import 'package:spendly/screens/budget_screen.dart';
import 'package:spendly/screens/profile_screen.dart';
import 'package:spendly/services/ad_service.dart';
import 'package:spendly/services/storage_service.dart';
import 'package:spendly/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  Map<String, double> _stats = {};
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    AdService.initialize();
    AdService.loadBannerAd(onLoaded: () {
      setState(() => _adLoaded = true);
    });
  }

  Future<void> _loadData() async {
    final transactions = await StorageService.getTransactions();
    final stats = await StorageService.getMonthlyStats();
    setState(() {
      _transactions = transactions;
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(
        transactions: _transactions,
        stats: _stats,
        onRefresh: _loadData,
        adLoaded: _adLoaded,
      ),
      const AnalyticsScreen(),
      const AddTransactionScreen(),
      const BudgetScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AdMob Banner
          if (_adLoaded)
            Container(
              color: Colors.white,
              child: AdService.getBannerWidget(),
            ),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) async {
              setState(() => _currentIndex = i);
              await _loadData();
            },
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFEEF2FF),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded,
                    color: Color(0xFF6366F1)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded,
                    color: Color(0xFF6366F1)),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded,
                    color: Color(0xFF6366F1)),
                label: 'Add',
              ),
              NavigationDestination(
                icon: Icon(Icons.track_changes_outlined),
                selectedIcon: Icon(Icons.track_changes_rounded,
                    color: Color(0xFF6366F1)),
                label: 'Budget',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded,
                    color: Color(0xFF6366F1)),
                label: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, double> stats;
  final VoidCallback onRefresh;
  final bool adLoaded;

  const _HomeTab({
    required this.transactions,
    required this.stats,
    required this.onRefresh,
    required this.adLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    final income = stats['income'] ?? 0;
    final spent = stats['spent'] ?? 0;
    final balance = income - spent;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF6366F1),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24, right: 24, bottom: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning 👋',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Your Finances',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'June Balance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${formatter.format(balance)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatChip(
                                label: 'Income',
                                value: '₹${formatter.format(income)}',
                                color: const Color(0xFF4ADE80),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatChip(
                                label: 'Spent',
                                value: '₹${formatter.format(spent)}',
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No transactions yet\nAdd your first one! 💰',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }
                  final t = transactions[index - 1];
                  return TransactionCard(
                    transaction: t,
                    onDelete: () async {
                      await StorageService.deleteTransaction(t.id);
                      onRefresh();
                    },
                  );
                },
                childCount: transactions.isEmpty ? 2 : transactions.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                 fdf fr fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}
