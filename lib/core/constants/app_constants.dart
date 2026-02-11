part 'animation_constants.dart';
part 'border_constants.dart';
part 'size_constants.dart';
part 'spacing_constants.dart';

abstract final class AppConstants {
  const AppConstants._();

  static const spacing = _Spacing();
  static final size = _SizeConstants();
  static final border = _Border();
  static const animation = _Animation();
}
