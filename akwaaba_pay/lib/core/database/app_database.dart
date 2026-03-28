import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemName => text()();
  RealColumn get amount => real()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get category => text().withDefault(const Constant('other'))();
  TextColumn get notes => text().nullable()();
  TextColumn get voiceTranscription => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('tw'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  TextColumn get notes => text().nullable()();
  TextColumn get voiceTranscription => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('tw'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  IntColumn get colorValue => integer().withDefault(const Constant(0xFF607D8B))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Sales, Expenses, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'akwaaba_pay_db');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedCategories();
      },
    );
  }

  Future<void> _seedCategories() async {
    final defaults = [
      CategoriesCompanion.insert(
        name: 'Food & Drinks',
        icon: const Value('restaurant'),
        colorValue: const Value(0xFF4CAF50),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Clothing',
        icon: const Value('checkroom'),
        colorValue: const Value(0xFF2196F3),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Electronics',
        icon: const Value('devices'),
        colorValue: const Value(0xFF9C27B0),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Services',
        icon: const Value('handyman'),
        colorValue: const Value(0xFFFF9800),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Transport',
        icon: const Value('directions_bus'),
        colorValue: const Value(0xFFE91E63),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Utilities',
        icon: const Value('bolt'),
        colorValue: const Value(0xFFFFEB3B),
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Other',
        icon: const Value('category'),
        colorValue: const Value(0xFF607D8B),
        isDefault: const Value(true),
      ),
    ];
    for (final cat in defaults) {
      await into(categories).insert(cat);
    }
  }

  // --- Sales Queries ---
  Future<List<Sale>> getAllSales() => (select(sales)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<Sale>> watchAllSales() => (select(sales)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Stream<List<Sale>> watchSalesByDateRange(DateTime start, DateTime end) {
    return (select(sales)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertSale(SalesCompanion sale) => into(sales).insert(sale);

  Future<bool> updateSale(Sale sale) => update(sales).replace(sale);

  Future<int> deleteSale(int id) => (delete(sales)..where((t) => t.id.equals(id))).go();

  // --- Expenses Queries ---
  Future<List<Expense>> getAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<Expense>> watchAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Stream<List<Expense>> watchExpensesByDateRange(DateTime start, DateTime end) {
    return (select(expenses)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertExpense(ExpensesCompanion expense) => into(expenses).insert(expense);

  Future<bool> updateExpense(Expense expense) => update(expenses).replace(expense);

  Future<int> deleteExpense(int id) => (delete(expenses)..where((t) => t.id.equals(id))).go();

  // --- Categories Queries ---
  Future<List<Category>> getAllCategories() => select(categories).get();

  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // --- Aggregations ---
  Stream<double> watchTotalSalesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final query = selectOnly(sales)
      ..addColumns([sales.amount.sum()])
      ..where(sales.createdAt.isBetweenValues(start, end));
    return query.map((row) => row.read(sales.amount.sum()) ?? 0.0).watchSingle();
  }

  Stream<double> watchTotalExpensesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final query = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.createdAt.isBetweenValues(start, end));
    return query.map((row) => row.read(expenses.amount.sum()) ?? 0.0).watchSingle();
  }

  Future<List<Map<String, dynamic>>> getSalesByCategoryForRange(DateTime start, DateTime end) async {
    final query = selectOnly(sales)
      ..addColumns([sales.category, sales.amount.sum()])
      ..where(sales.createdAt.isBetweenValues(start, end))
      ..groupBy([sales.category]);
    final results = await query.get();
    return results.map((row) {
      return {
        'category': row.read(sales.category),
        'total': row.read(sales.amount.sum()) ?? 0.0,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDailySalesForRange(DateTime start, DateTime end) async {
    final allSales = await (select(sales)
          ..where((t) => t.createdAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    final Map<String, double> dailyTotals = {};
    for (final sale in allSales) {
      final key = '${sale.createdAt.year}-${sale.createdAt.month.toString().padLeft(2, '0')}-${sale.createdAt.day.toString().padLeft(2, '0')}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + sale.amount;
    }

    return dailyTotals.entries.map((e) => {'date': e.key, 'total': e.value}).toList();
  }
}
