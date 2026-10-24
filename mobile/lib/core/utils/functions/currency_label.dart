String currencyLabel(String code, String locale) {
  final normalized = code.trim().toUpperCase();
  const labels = <String, Map<String, String>>{
    'SAR': {'en': 'SAR', 'ar': 'ر.س'},
    'EGP': {'en': 'EGP', 'ar': 'ج.م'},
    'AED': {'en': 'AED', 'ar': 'د.إ'},
    'USD': {'en': 'USD', 'ar': 'USD'},
    'QAR': {'en': 'QAR', 'ar': 'ر.ق'},
    'KWD': {'en': 'KWD', 'ar': 'د.ك'},
    'BHD': {'en': 'BHD', 'ar': 'د.ب'},
    'OMR': {'en': 'OMR', 'ar': 'ر.ع'},
  };
  final row = labels[normalized];
  if (row == null) return normalized.isEmpty ? 'SAR' : normalized;
  return locale == 'ar' ? row['ar']! : row['en']!;
}
