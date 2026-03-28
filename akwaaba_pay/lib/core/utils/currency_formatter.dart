import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _format = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
    locale: 'en_GH',
  );

  static String format(double amount) {
    return _format.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${AppConstants.currencySymbol}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${AppConstants.currencySymbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
