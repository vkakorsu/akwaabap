import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';

final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllSales();
});

final todaySalesTotalProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTotalSalesForDate(DateTime.now());
});

final salesByDateRangeProvider =
    StreamProvider.family<List<Sale>, DateRange>((ref, range) {
  final db = ref.watch(databaseProvider);
  return db.watchSalesByDateRange(range.start, range.end);
});

// Selected date range provider for filtering
class SelectedDateRangeNotifier extends Notifier<DateRange?> {
  @override
  DateRange? build() => null; // null means all time

  void set(DateRange? range) {
    state = range;
  }
}

final selectedDateRangeProvider =
    NotifierProvider<SelectedDateRangeNotifier, DateRange?>(
        SelectedDateRangeNotifier.new);

// Filtered sales provider that uses selected date range
final filteredSalesProvider = StreamProvider<List<Sale>>((ref) {
  final selectedRange = ref.watch(selectedDateRangeProvider);
  final db = ref.watch(databaseProvider);

  if (selectedRange == null) {
    return db.watchAllSales();
  }
  return db.watchSalesByDateRange(selectedRange.start, selectedRange.end);
});

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});
}

class SalesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  AppDatabase get _db => ref.read(databaseProvider);

  Future<void> addSale({
    required String itemName,
    required double amount,
    int quantity = 1,
    String category = 'other',
    String? notes,
    String? voiceTranscription,
    String language = 'tw',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _db.insertSale(SalesCompanion.insert(
        itemName: itemName,
        amount: amount,
        quantity: Value(quantity),
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

  Future<void> deleteSale(int id) async {
    state = const AsyncValue.loading();
    try {
      await _db.deleteSale(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSale(Sale sale) async {
    state = const AsyncValue.loading();
    try {
      await _db.updateSale(sale);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final salesNotifierProvider =
    NotifierProvider<SalesNotifier, AsyncValue<void>>(SalesNotifier.new);
