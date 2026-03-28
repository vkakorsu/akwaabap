enum TransactionType { sale, expense, unknown }

class VoiceCommand {
  final String rawTranscription;
  final TransactionType type;
  final String? itemName;
  final double? amount;
  final int quantity;
  final String? category;
  final String? personName;
  final String language;
  final double confidence;

  const VoiceCommand({
    required this.rawTranscription,
    required this.type,
    this.itemName,
    this.amount,
    this.quantity = 1,
    this.category,
    this.personName,
    required this.language,
    this.confidence = 0.0,
  });

  bool get isValid => type != TransactionType.unknown && amount != null && amount! > 0;

  String get displayType {
    switch (type) {
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.unknown:
        return 'Unknown';
    }
  }

  VoiceCommand copyWith({
    String? rawTranscription,
    TransactionType? type,
    String? itemName,
    double? amount,
    int? quantity,
    String? category,
    String? personName,
    String? language,
    double? confidence,
  }) {
    return VoiceCommand(
      rawTranscription: rawTranscription ?? this.rawTranscription,
      type: type ?? this.type,
      itemName: itemName ?? this.itemName,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      personName: personName ?? this.personName,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  String toString() {
    return 'VoiceCommand(type: $type, item: $itemName, amount: $amount, qty: $quantity)';
  }
}
