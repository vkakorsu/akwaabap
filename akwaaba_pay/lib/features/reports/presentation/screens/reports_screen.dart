import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

enum ReportPeriod { today, week, month, custom }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.week;

  DateTimeRange get _dateRange {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case ReportPeriod.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case ReportPeriod.week:
        return DateTimeRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now,
        );
      case ReportPeriod.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case ReportPeriod.custom:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final range = _dateRange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ReportPeriod.values.map((period) {
                  final isSelected = period == _selectedPeriod;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_periodLabel(period)),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedPeriod = period),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Summary cards
            FutureBuilder(
              future: Future.wait([
                db.getSalesByCategoryForRange(range.start, range.end),
                db.getDailySalesForRange(range.start, range.end),
              ]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categoryData = snapshot.data![0];
                final dailyData = snapshot.data![1];

                final totalSales = categoryData.fold(
                    0.0, (sum, item) => sum + (item['total'] as double));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total sales card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.secondary, AppColors.secondaryLight],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Sales',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(totalSales),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${categoryData.length} categories • ${dailyData.length} days',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white60,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category breakdown
                    if (categoryData.isNotEmpty) ...[
                      Text('Sales by Category',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _CategoryPieChart(
                        data: categoryData,
                        total: totalSales,
                      ),
                      const SizedBox(height: 16),
                      ...categoryData.map((item) {
                        final category = item['category'] as String? ?? 'Other';
                        final total = item['total'] as double;
                        final pct = totalSales > 0
                            ? (total / totalSales * 100).toStringAsFixed(1)
                            : '0';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _categoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(category,
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ),
                              Text(
                                '$pct%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                CurrencyFormatter.format(total),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    if (categoryData.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart_rounded,
                                  size: 64,
                                  color: AppColors.textTertiary.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                'No data for this period',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.today:
        return 'Today';
      case ReportPeriod.week:
        return 'This Week';
      case ReportPeriod.month:
        return 'This Month';
      case ReportPeriod.custom:
        return 'Last 30 Days';
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & drinks':
        return AppColors.categoryFood;
      case 'clothing':
        return AppColors.categoryClothing;
      case 'electronics':
        return AppColors.categoryElectronics;
      case 'services':
        return AppColors.categoryServices;
      default:
        return AppColors.categoryOther;
    }
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double total;

  const _CategoryPieChart({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.categoryFood,
      AppColors.categoryClothing,
      AppColors.categoryElectronics,
      AppColors.categoryServices,
      AppColors.categoryOther,
      AppColors.primary,
      AppColors.secondary,
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: data.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final value = item['total'] as double;
            return PieChartSectionData(
              value: value,
              color: colors[idx % colors.length],
              radius: 50,
              showTitle: false,
            );
          }).toList(),
        ),
      ),
    );
  }
}
