import 'dart:math';

class EfficientNumber {
  final double mantissa;
  final int exponent;

  const EfficientNumber._(this.mantissa, this.exponent);

  const EfficientNumber.zero()
      : mantissa = 0.0,
        exponent = 0;

  const EfficientNumber.one()
      : mantissa = 1.0,
        exponent = 0;

  static EfficientNumber fromValues(double m, int e) {
    if (m == 0) return const EfficientNumber.zero();

    while (m.abs() >= 10) {
      m /= 10;
      e += 1;
    }
    while (m.abs() < 1 && m != 0) {
      m *= 10;
      e -= 1;
    }

    return EfficientNumber._(m, e);
  }

  static EfficientNumber fromDouble(double value) {
    if (value == 0) return const EfficientNumber.zero();
    if (value.isNaN) {
      throw ArgumentError('NaN is not representable as EfficientNumber');
    }
    if (value.isInfinite) {
      final double sign = value.isNegative ? -1.0 : 1.0;
      return EfficientNumber._(sign, 309);
    }

    final String str = value.toStringAsExponential();
    final int eIndex = str.indexOf('e');
    if (eIndex == -1) return const EfficientNumber.zero();
    final double m = double.parse(str.substring(0, eIndex));
    final int e = int.parse(str.substring(eIndex + 1));

    return EfficientNumber.fromValues(m, e);
  }

  static EfficientNumber fromPower(double base, double power) {
    if (base <= 0 || power == 0) return const EfficientNumber.one();
    if (power < 0) return EfficientNumber.fromDouble(pow(base, power).toDouble());

    final double logValue = power * log(base) / ln10;
    final int intExponent = logValue.floor();
    final double remainingMantissa = logValue - intExponent;

    final double mantissa = exp(remainingMantissa * ln10);

    return EfficientNumber.fromValues(mantissa, intExponent);
  }

  static const double ln10 = 2.302585092994046;

  static EfficientNumber parse(String value) {
    if (value.isEmpty || value == '0') return const EfficientNumber.zero();

    final String v = value.trim();
    final bool hasE = v.contains('e') || v.contains('E');
    if (hasE) {
      final int eIndex = v.toLowerCase().lastIndexOf('e');
      final double m = double.parse(v.substring(0, eIndex));
      final int e = int.parse(v.substring(eIndex + 1));

      return EfficientNumber.fromValues(m, e);
    }

    return EfficientNumber.fromDouble(double.parse(v));
  }

  EfficientNumber operator +(EfficientNumber other) {
    if (exponent == other.exponent) {
      return EfficientNumber.fromValues(mantissa + other.mantissa, exponent);
    }

    if (exponent < other.exponent) {
      final int diff = other.exponent - exponent;
      if (diff > 15) return other;

      final double adjustedM = mantissa / pow(10, diff);
      return EfficientNumber.fromValues(adjustedM + other.mantissa,
          other.exponent);
    }

    final int diff = exponent - other.exponent;
    if (diff > 15) return this;

    final double adjustedM = other.mantissa / pow(10, diff);
    return EfficientNumber.fromValues(mantissa + adjustedM, exponent);
  }

  EfficientNumber operator -(EfficientNumber other) {
    if (exponent == other.exponent) {
      return EfficientNumber.fromValues(mantissa - other.mantissa, exponent);
    }

    if (exponent < other.exponent) {
      final int diff = other.exponent - exponent;
      if (diff > 15) return -other;

      final double adjustedM = mantissa / pow(10, diff);
      return EfficientNumber.fromValues(adjustedM - other.mantissa,
          other.exponent);
    }

    final int diff = exponent - other.exponent;
    if (diff > 15) return this;

    final double adjustedM = other.mantissa / pow(10, diff);
    return EfficientNumber.fromValues(mantissa - adjustedM, exponent);
  }

  EfficientNumber operator *(EfficientNumber other) {
    if (mantissa == 0 || other.mantissa == 0) return const EfficientNumber.zero();

    return EfficientNumber.fromValues(
        mantissa * other.mantissa, exponent + other.exponent);
  }

  EfficientNumber operator /(EfficientNumber other) {
    if (other.mantissa == 0) {
      throw ArgumentError('Division by zero');
    }
    if (mantissa == 0) return const EfficientNumber.zero();

    return EfficientNumber.fromValues(
        mantissa / other.mantissa, exponent - other.exponent);
  }

  EfficientNumber operator -() {
    return EfficientNumber._(-mantissa, exponent);
  }

  bool operator <(EfficientNumber other) {
    if (exponent != other.exponent) return exponent < other.exponent;
    return mantissa < other.mantissa;
  }

  bool operator <=(EfficientNumber other) {
    return this < other || this == other;
  }

  bool operator >(EfficientNumber other) {
    return !(this <= other);
  }

  bool operator >=(EfficientNumber other) {
    return !(this < other);
  }

  int compareTo(EfficientNumber other) {
    if (exponent != other.exponent) {
      return exponent.compareTo(other.exponent);
    }
    return mantissa.compareTo(other.mantissa);
  }

  EfficientNumber abs() {
    return EfficientNumber._(mantissa.abs(), exponent);
  }

  double toDouble() {
    if (exponent == 0) return mantissa;
    if (exponent.abs() > 308) {
      return exponent > 0 ? double.infinity : 0.0;
    }

    return mantissa * pow(10, exponent);
  }

  String toPlainString() {
    if (exponent == 0) return mantissa.toString();

    final double value = toDouble();
    if (value == double.infinity) return 'Infinity';
    if (value == 0) return '0';

    return value.toString();
  }

  String toScientificString() {
    return '${mantissa.toStringAsFixed(6)}e$exponent';
  }

  @override
  String toString() {
    return toScientificString();
  }

  @override
  bool operator ==(Object other) {
    if (other is! EfficientNumber) return false;
    if (mantissa == 0 && other.mantissa == 0) return true;
    return exponent == other.exponent &&
        (mantissa - other.mantissa).abs() < 1e-10;
  }

  @override
  int get hashCode {
    if (mantissa == 0.0) return 0;
    final int quantizedMantissa = (mantissa * 1e10).round();
    return Object.hash(quantizedMantissa, exponent);
  }

  Map<String, dynamic> toJson() {
    return {
      'mantissa': mantissa,
      'exponent': exponent,
    };
  }

  factory EfficientNumber.fromJson(Map<String, dynamic> json) {
    return EfficientNumber.fromValues(
      (json['mantissa'] as num).toDouble(),
      (json['exponent'] as num).toInt(),
    );
  }
}

