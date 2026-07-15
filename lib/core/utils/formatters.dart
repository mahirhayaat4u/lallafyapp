import '../constants/app_constants.dart';

/// Number / price formatting utilities
class Formatters {
  Formatters._();

  /// Format price with ₹ symbol: ₹1,299
  static String price(double amount) {
    final formatted = amount.toStringAsFixed(0);
    // Add comma separators for Indian numbering
    return '${AppConstants.currencySymbol}${_addCommas(formatted)}';
  }

  /// Format price with decimals: ₹1,299.00
  static String priceWithDecimals(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    return '${AppConstants.currencySymbol}${_addCommas(parts[0])}.${parts[1]}';
  }

  /// Indian number format: 1,23,456
  static String _addCommas(String number) {
    if (number.length <= 3) return number;
    final lastThree = number.substring(number.length - 3);
    final rest = number.substring(0, number.length - 3);
    final formatted = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
      (match) => '${match[1]},',
    );
    return '$formatted,$lastThree';
  }

  /// Compact number: 1.2K, 15K, 1.5M
  static String compact(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format date: 15 Jun 2026
  static String date(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format date with time: 15 Jun 2026, 2:30 PM
  static String dateTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${Formatters.date(date)}, $hour:$minute $period';
  }

  /// Relative time: "2 hours ago", "3 days ago"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
