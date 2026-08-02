import '../../../../core/utils/result.dart';
import '../../../settings/domain/services/settings_service.dart';

/// Domain service for the first-run onboarding flow.
///
/// Wraps the [SettingsService] and is the only writer of the
/// `onboarding_completed` setting key.
class OnboardingService {
  final SettingsService _settings;

  OnboardingService(this._settings);

  /// Whether onboarding has already been completed by this user.
  Future<bool> isCompleted() => _settings.getOnboardingCompleted();

  /// Marks onboarding complete. If [name] is non-null and non-empty it is
  /// also stored as the display name.
  Future<Result<void>> complete({String? name}) {
    final trimmed = name?.trim();
    return _settings.completeOnboarding(name: (trimmed == null || trimmed.isEmpty) ? null : trimmed);
  }

  /// Marks onboarding as complete without capturing a name.
  /// Used by the "Skip" button.
  Future<Result<void>> skip() => _settings.completeOnboarding();

  /// Updates the in-progress name without committing onboarding completion.
  Future<Result<void>> setName(String? name) => _settings.setDisplayName(name);
}
