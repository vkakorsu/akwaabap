import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/expenses_provider.dart';

class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_outlined,
                      size: 80, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No expenses yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textTertiary,
                          )),
                  const SizedBox(height: 8),
                  Text('Tap the mic button to record an expense',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Group by date
          final grouped = <String, List<Expense>>{};
          for (final expense in expenses) {
            final key = DateFormatter.formatDayHeader(expense.createdAt);
            grouped.putIfAbsent(key, () => []).add(expense);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final entry = grouped.entries.elementAt(index);
              final dayTotal = entry.value.fold(0.0, (sum, e) => sum + e.amount);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.textTertiary,
                                )),
                        Text(CurrencyFormatter.format(dayTotal),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                )),
                      ],
                    ),
                  ),
                  ...entry.value.map((expense) => Dismissible(
                        key: ValueKey(expense.id),
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
                              title: const Text('Delete Expense'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: AppColors.error))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          ref.read(expensesNotifierProvider.notifier).deleteExpense(expense.id);
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
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.arrow_downward_rounded,
                                      color: AppColors.error, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.description,
                                          style: Theme.of(context).textTheme.titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(DateFormatter.formatTime(expense.createdAt),
                                          style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                Text(
                                  '- ${CurrencyFormatter.format(expense.amount)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
