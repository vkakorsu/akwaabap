class LanguageConstants {
  LanguageConstants._();

  static const Map<String, String> supportedLanguages = {
    'tw': 'Twi',
    'gaa': 'Ga',
    'fat': 'Fante',
    'en': 'English',
  };

  // Transaction keywords per language
  static const Map<String, Map<String, List<String>>> transactionKeywords = {
    'tw': {
      'sell': ['tɔn', 'ton', 'tɔ', 'to'],
      'buy': ['tɔ', 'to'],
      'received': ['gyee', 'gye', 'nya'],
      'paid': ['tuaa', 'tua', 'twa'],
      'expense': ['tuaa', 'tua', 'sika a metuae'],
      'profit': ['mfaso', 'profit'],
      'total': ['nyinaa', 'total'],
    },
    'gaa': {
      'sell': ['yɔɔ', 'yoo'],
      'buy': ['dɛ', 'de'],
      'received': ['yɛ', 'ye'],
      'paid': ['ha', 'haa'],
      'expense': ['ha', 'haa'],
    },
    'fat': {
      'sell': ['tɔn', 'ton'],
      'buy': ['tɔ', 'to'],
      'received': ['nyae', 'nya'],
      'paid': ['tuae', 'tua'],
      'expense': ['tuae', 'tua'],
    },
    'en': {
      'sell': ['sold', 'sell', 'sale'],
      'buy': ['bought', 'buy', 'purchase'],
      'received': ['received', 'got', 'collected'],
      'paid': ['paid', 'pay', 'spent'],
      'expense': ['expense', 'cost', 'spent'],
    },
  };

  // Number words in Twi
  static const Map<String, int> twiNumbers = {
    'baako': 1,
    'mmienu': 2,
    'mmiɛnsa': 3,
    'nan': 4,
    'num': 5,
    'nsia': 6,
    'nson': 7,
    'nwɔtwe': 8,
    'nkron': 9,
    'du': 10,
    'aduonu': 20,
    'aduasa': 30,
    'aduanan': 40,
    'aduonum': 50,
    'ɔha': 100,
  };
}
