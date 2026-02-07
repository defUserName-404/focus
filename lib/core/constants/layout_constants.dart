part 'animation_constants.dart';
part 'radius_constants.dart';
part 'spacing_constants.dart';

abstract final class LayoutConstants {
  const LayoutConstants._();

  static const spacing = _Spacing();
  static const radius = _Radius();
  static const animation = _Animation();
}
