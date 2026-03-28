import '../../../../core/constants/language_constants.dart';
import '../entities/voice_command.dart';

class VoiceCommandParser {
  /// Parse a transcribed text into a structured VoiceCommand
  VoiceCommand parse(String transcription, String language) {
    final text = transcription.toLowerCase().trim();
    final type = _detectTransactionType(text, language);
    final amount = _extractAmount(text);
    final quantity = _extractQuantity(text, language);
    final itemName = _extractItemName(text, language, type);
    final personName = _extractPersonName(text, language);

    return VoiceCommand(
      rawTranscription: transcription,
      type: type,
      itemName: itemName,
      amount: amount,
      quantity: quantity,
      personName: personName,
      language: language,
      confidence: _calculateConfidence(type, amount, itemName),
    );
  }

  TransactionType _detectTransactionType(String text, String language) {
    final lowerText = text.toLowerCase();
    final keywords =
        LanguageConstants.transactionKeywords[language] ??
        LanguageConstants.transactionKeywords['en']!;

    // Check for sale keywords with more flexible matching
    final sellKeywords = keywords['sell'] ?? [];
    for (final keyword in sellKeywords) {
      if (lowerText.contains(keyword.toLowerCase()))
        return TransactionType.sale;
    }

    // Check for expense keywords
    final expenseKeywords = keywords['expense'] ?? [];
    final paidKeywords = keywords['paid'] ?? [];
    for (final keyword in [...expenseKeywords, ...paidKeywords]) {
      if (lowerText.contains(keyword.toLowerCase()))
        return TransactionType.expense;
    }

    // Check for received (treat as sale/income)
    final receivedKeywords = keywords['received'] ?? [];
    for (final keyword in receivedKeywords) {
      if (lowerText.contains(keyword.toLowerCase()))
        return TransactionType.sale;
    }

    // Check for buy keywords (expense)
    final buyKeywords = keywords['buy'] ?? [];
    for (final keyword in buyKeywords) {
      if (lowerText.contains(keyword.toLowerCase()))
        return TransactionType.expense;
    }

    return TransactionType.unknown;
  }

  double? _extractAmount(String text) {
    final lowerText = text.toLowerCase();

    // First check for word numbers (English) - with or without currency
    for (final entry in LanguageConstants.englishNumbers.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value.toDouble();
      }
    }

    // Check for Twi number words
    for (final entry in LanguageConstants.twiNumbers.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value.toDouble();
      }
    }

    // Match patterns like: GH₵5, GH₵5.00, ₵5, ₵5.00, GHC5, 5 cedis, 5 ghana cedis
    final patterns = [
      RegExp(r'gh[₵c]\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false),
      RegExp(r'[₵]\s*(\d+(?:\.\d{1,2})?)'),
      RegExp(
        r'(\d+(?:\.\d{1,2})?)\s*(?:cedis?|ghana\s*cedis?|ghc|gh₵)',
        caseSensitive: false,
      ),
      RegExp(r'(\d+(?:\.\d{1,2})?)\s*(?:sidi|sika)', caseSensitive: false),
      // Just find any standalone number as last resort
      RegExp(r'\b(\d+(?:\.\d{1,2})?)\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1) ?? '');
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  int _extractQuantity(String text, String language) {
    // Check for Twi number words
    if (language == 'tw') {
      for (final entry in LanguageConstants.twiNumbers.entries) {
        if (text.contains(entry.key)) return entry.value;
      }
    }

    // Check for numeric quantities with item context
    final qtyPatterns = [
      RegExp(
        r'(\d+)\s*(?:bottles?|pieces?|bags?|boxes?|packs?|items?)',
        caseSensitive: false,
      ),
      RegExp(r'(\d+)\s*(?:no\b|number)', caseSensitive: false),
    ];

    for (final pattern in qtyPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final qty = int.tryParse(match.group(1) ?? '');
        if (qty != null && qty > 0) return qty;
      }
    }

    return 1;
  }

  String? _extractItemName(String text, String language, TransactionType type) {
    final keywords =
        LanguageConstants.transactionKeywords[language] ??
        LanguageConstants.transactionKeywords['en']!;

    // Get all action keywords to remove from text
    final allKeywords = <String>[];
    keywords.forEach((key, value) => allKeywords.addAll(value));

    String cleaned = text;

    // Remove keywords
    for (final keyword in allKeywords) {
      cleaned = cleaned.replaceAll(keyword, '');
    }

    // Remove amount patterns including Twi number words
    for (final number in LanguageConstants.twiNumbers.keys) {
      cleaned = cleaned.replaceAll(number, '');
    }
    cleaned = cleaned.replaceAll(
      RegExp(r'gh[₵c]\s*\d+(?:\.\d{1,2})?', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'[₵]\s*\d+(?:\.\d{1,2})?'), '');
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\d+(?:\.\d{1,2})?\s*(?:cedis?|ghana\s*cedis?|ghc|gh₵)',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\d+\s*(?:bottles?|pieces?|bags?|boxes?|packs?)',
        caseSensitive: false,
      ),
      '',
    );

    // Remove common filler words
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(me|mi|ma|a|the|for|fi|na|to)\b', caseSensitive: false),
      '',
    );

    // Clean up whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.isNotEmpty ? _capitalize(cleaned) : null;
  }

  String? _extractPersonName(String text, String language) {
    // Look for "fi/from [Name]" pattern
    final patterns = [
      RegExp(r'fi\s+(\w+)', caseSensitive: false), // Twi: from
      RegExp(r'from\s+(\w+)', caseSensitive: false), // English
      RegExp(r'ma\s+(\w+)', caseSensitive: false), // Twi: to/for
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final name = match.group(1) ?? '';
        if (name.isNotEmpty && name[0] == name[0].toUpperCase()) {
          return name;
        }
        return _capitalize(name);
      }
    }
    return null;
  }

  double _calculateConfidence(
    TransactionType type,
    double? amount,
    String? itemName,
  ) {
    double confidence = 0.0;
    if (type != TransactionType.unknown) confidence += 0.4;
    if (amount != null && amount > 0) confidence += 0.4;
    if (itemName != null && itemName.isNotEmpty) confidence += 0.2;
    return confidence;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
