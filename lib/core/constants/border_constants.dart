part of 'app_constants.dart';

final class _Border {
  _Border();

  final radius = _BorderRadius();
  final width = _BorderWidth();
}

final class _BorderWidth {
  const _BorderWidth();

  final double small = 0.5;
  final double regular = 1.0;
  final double large = 2.0;
}

final class _BorderRadius {
  const _BorderRadius();

  final double small = 4.0;
  final double regular = 8.0;
  final double large = 16.0;
  final double circular = 999.0;
}
