import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../sales/presentation/providers/sales_provider.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaySales = ref.watch(todaySalesTotalProvider);
    final todayExpenses = ref.watch(todayExpensesTotalProvider);
    final businessName = ref.watch(businessNameProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      businessName.when(
                        data: (name) => Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => Text(
                          'My Business',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's summary cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Sales Today',
                      value: todaySales.when(
                        data: (v) => CurrencyFormatter.format(v),
                        loading: () => '...',
                        error: (_, _) => CurrencyFormatter.format(0),
                      ),
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.success,
                      bgColor: AppColors.success.withValues(alpha: 0.08),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Expenses Today',
                      value: todayExpenses.when(
                        data: (v) => CurrencyFormatter.format(v),
                        loading: () => '...',
                        error: (_, _) => CurrencyFormatter.format(0),
                      ),
                      icon: Icons.trending_down_rounded,
                      iconColor: AppColors.error,
                      bgColor: AppColors.error.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Profit card
              _ProfitCard(salesAsync: todaySales, expensesAsync: todayExpenses),
              const SizedBox(height: 24),

              // Weekly chart
              Text('This Week', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _WeeklyChart(ref: ref),
              const SizedBox(height: 24),

              // Recent sales
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Sales',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              _RecentSalesList(ref: ref),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  final AsyncValue<double> salesAsync;
  final AsyncValue<double> expensesAsync;

  const _ProfitCard({required this.salesAsync, required this.expensesAsync});

  @override
  Widget build(BuildContext context) {
    final sales = salesAsync.value ?? 0;
    final expenses = expensesAsync.value ?? 0;
    final profit = sales - expenses;
    final isPositive = profit >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Profit",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(profit.abs()),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final WidgetRef ref;

  const _WeeklyChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: db.getDailySalesForRange(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
        now.add(const Duration(days: 1)),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        // Build bar data
        final bars = <BarChartGroupData>[];
        for (int i = 0; i < 7; i++) {
          final date = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day,
          ).add(Duration(days: i));
          final key =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final total =
              data
                  .where((d) => d['date'] == key)
                  .map((d) => d['total'] as double)
                  .firstOrNull ??
              0.0;

          bars.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: total,
                  color: i == now.weekday - 1
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: bars.isEmpty
                  ? 100
                  : bars
                            .map((b) => b.barRods.first.toY)
                            .reduce((a, b) => a > b ? a : b) *
                        1.3,
              barGroups: bars,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < 7) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dayNames[value.toInt()],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecentSalesList extends StatelessWidget {
  final WidgetRef ref;

  const _RecentSalesList({required this.ref});

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesStreamProvider);

    return salesAsync.when(
      data: (sales) {
        final recent = sales.take(5).toList();
        if (recent.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No sales recorded today.\nTap the mic to get started!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return Column(
          children: recent.map((sale) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    sale.itemName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    '${sale.quantity > 1 ? '${sale.quantity}x • ' : ''}${sale.category}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(sale.amount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
