import 'package:intl/intl.dart';

class Utils {
  // Define the locale
  static String arDateFormat(DateTime date) {
    return DateFormat('yMMMd', 'ar').format(date);
  }
}
