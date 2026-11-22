import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:intl/intl.dart';

/// Formats [money] for display, with its currency symbol and the number of
/// decimal places that currency uses, such as `$4.50` or `¥1,200`.
///
/// [locale] sets the separators and symbol placement. When it is null, the
/// current default locale is used.
String formatMoney(Money money, {String? locale}) {
  final format = NumberFormat.simpleCurrency(
    locale: locale,
    name: money.currency,
  );
  final decimalDigits = format.decimalDigits ?? 2;
  return format.format(money.minorUnits / math.pow(10, decimalDigits));
}
