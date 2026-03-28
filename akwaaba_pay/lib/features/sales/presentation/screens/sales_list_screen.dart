import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/sales_provider.dart';

class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(filteredSalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return _EmptyState();
          }
          return _SalesListView(sales: sales, ref: ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _DateFilterSheet(
        selectedRange: ref.read(selectedDateRangeProvider),
        onSelected: (range) {
          ref.read(selectedDateRangeProvider.notifier).set(range);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No sales yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the mic button to record your first sale',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SalesListView extends StatelessWidget {
  final List<Sale> sales;
  final WidgetRef ref;

  const _SalesListView({required this.sales, required this.ref});

  @override
  Widget build(BuildContext context) {
    // Group sales by date
    final grouped = <String, List<Sale>>{};
    for (final sale in sales) {
      final key = DateFormatter.formatDayHeader(sale.createdAt);
      grouped.putIfAbsent(key, () => []).add(sale);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        final dayTotal = entry.value.fold(0.0, (sum, s) => sum + s.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  Text(
                    CurrencyFormatter.format(dayTotal),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            ...entry.value.map((sale) => _SaleCard(sale: sale, ref: ref)),
          ],
        );
      },
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final WidgetRef ref;

  const _SaleCard({required this.sale, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(sale.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Sale'),
            content: const Text('Are you sure you want to delete this sale?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(salesNotifierProvider.notifier).deleteSale(sale.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getCategoryColor(sale.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(sale.category),
                  color: _getCategoryColor(sale.category),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.itemName,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sale.quantity > 1 ? '${sale.quantity}x • ' : ''}${DateFormatter.formatTime(sale.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(sale.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & drinks':
        return Icons.restaurant_rounded;
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'services':
        return Icons.handyman_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

class _DateFilterSheet extends StatelessWidget {
  final DateRange? selectedRange;
  final void Function(DateRange?) onSelected;

  const _DateFilterSheet({
    required this.selectedRange,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final options = [
      (
        'All Time',
        null as DateRange?,
        selectedRange == null,
      ),
      (
        'Today',
        DateRange(start: today, end: today.add(const Duration(days: 1))),
        _isSameRange(selectedRange, today, today.add(const Duration(days: 1))),
      ),
      (
        'Last 7 Days',
        DateRange(
          start: today.subtract(const Duration(days: 6)),
          end: today.add(const Duration(days: 1)),
        ),
        _isSameRange(
          selectedRange,
          today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)),
        ),
      ),
      (
        'Last 30 Days',
        DateRange(
          start: today.subtract(const Duration(days: 29)),
          end: today.add(const Duration(days: 1)),
        ),
        _isSameRange(
          selectedRange,
          today.subtract(const Duration(days: 29)),
          today.add(const Duration(days: 1)),
        ),
      ),
      (
        'This Month',
        DateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 1),
        ),
        _isSameRange(
          selectedRange,
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter by Date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final (label, range, isSelected) = option;
            return ListTile(
              title: Text(label),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              onTap: () => onSelected(range),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  bool _isSameRange(DateRange? range, DateTime start, DateTime end) {
    if (range == null) return false;
    return range.start.year == start.year &&
        range.start.month == start.month &&
        range.start.day == start.day &&
        range.end.year == end.year &&
        range.end.month == end.month &&
        range.end.day == end.day;
  }
}
