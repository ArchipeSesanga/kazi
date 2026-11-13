import 'package:intl/intl.dart';

/// Price and date formatters for FR and EN locales (TDD §9.9).
abstract final class KaziFormatters {
  // ---------------------------------------------------------------------------
  // Price
  // ---------------------------------------------------------------------------

  /// Formats a USD price: `10 $` (FR) / `$10` (EN).
  static String usd(double amount, {required String locale}) {
    if (locale.startsWith('fr')) {
      // FR: "10 $" — number then symbol with narrow no-break space
      return '${_formatNumber(amount, locale)} \$';
    }
    return '\$${_formatNumber(amount, locale)}';
  }

  /// Formats a CDF price: `15 000 FC` (FR) / `CDF 15,000` (EN).
  static String cdf(int amount, {required String locale}) {
    final num = _formatNumber(amount.toDouble(), locale);
    if (locale.startsWith('fr')) return '$num FC';
    return 'CDF $num';
  }

  static String _formatNumber(double amount, String locale) =>
      NumberFormat.decimalPattern(locale).format(amount);

  /// Formats a price with the right currency symbol and locale style.
  static String price(
    double? amount,
    String currency,
    String priceType, {
    required String locale,
  }) {
    if (priceType == 'quote' || amount == null) {
      return locale.startsWith('fr') ? 'Sur devis' : 'Quote';
    }
    final prefix = priceType == 'from'
        ? (locale.startsWith('fr') ? 'Dès ' : 'From ')
        : '';
    final formatted = currency == 'USD'
        ? usd(amount, locale: locale)
        : cdf(amount.toInt(), locale: locale);
    return '$prefix$formatted';
  }

  // ---------------------------------------------------------------------------
  // Date / time
  // ---------------------------------------------------------------------------

  /// Short relative date: "Aujourd'hui", "Hier", or "12 nov." (FR).
  static String relativeDate(DateTime date, {required String locale}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return locale.startsWith('fr') ? "Aujourd'hui" : 'Today';
    if (diff == 1) return locale.startsWith('fr') ? 'Hier' : 'Yesterday';
    return DateFormat.MMMd(locale).format(date);
  }

  /// Full date: "12 novembre 2026" (FR) / "November 12, 2026" (EN).
  static String fullDate(DateTime date, {required String locale}) =>
      DateFormat.yMMMMd(locale).format(date);
}
