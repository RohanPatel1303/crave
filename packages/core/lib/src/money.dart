import 'package:meta/meta.dart';

/// Represents a monetary value in a specific currency.
@immutable
final class Money implements Comparable<Money> {
  /// Creates a monetary amount from its smallest currency units.
  Money(this.minorUnits, {required this.currency}) {
    _validateCurrency(currency);
  }

  /// Creates a zero amount in [currency].
  Money.zero({required String currency}) : this(0, currency: currency);

  /// Adds [amounts], requiring each amount to use [currency].
  factory Money.sum(Iterable<Money> amounts, {required String currency}) {
    var total = 0;
    for (final amount in amounts) {
      if (amount.currency != currency) {
        throw ArgumentError('Cannot combine amounts in different currencies.');
      }
      total += amount.minorUnits;
    }
    return Money(total, currency: currency);
  }

  /// The amount in the currency's smallest units.
  final int minorUnits;

  /// The ISO currency code for this monetary amount.
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  /// Adds [other] to this amount.
  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  /// Subtracts [other] from this amount.
  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  /// Multiplies this amount by [quantity].
  Money operator *(int quantity) =>
      Money(minorUnits * quantity, currency: currency);

  static void _validateCurrency(String currency) {
    if (currency.length != 3 ||
        currency.codeUnits.any((unit) => unit < 0x41 || unit > 0x5a)) {
      throw ArgumentError.value(
        currency,
        'currency',
        'Must be three uppercase letters.',
      );
    }
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Cannot combine amounts in different currencies.');
    }
  }
}
