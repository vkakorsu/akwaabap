import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllExpenses();
});

final todayExpensesTotalProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTotalExpensesForDate(DateTime.now());
});

class ExpensesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> addExpense({
    required String description,
    required double amount,
    String category = 'other',
    String? notes,
    String? voiceTranscription,
    String language = 'tw',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _db.insertExpense(ExpensesCompanion.insert(
        description: description,
        amount: amount,
        category: Value(category),
        notes: Value(notes),
        voiceTranscription: Value(voiceTranscription),
        language: Value(language),
      ));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExpense(int id) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteExpense(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final expensesNotifierProvider =
    NotifierProvider<ExpensesNotifier, AsyncValue<void>>(
        ExpensesNotifier.new);
