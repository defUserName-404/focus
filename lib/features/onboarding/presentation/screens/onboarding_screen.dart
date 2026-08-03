import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/log_service.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/name_step.dart';
import '../widgets/tour_step.dart';
import '../widgets/welcome_step.dart';

final _log = LogService.instance;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onPrimary() async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final isFinal = ref.read(onboardingControllerProvider).isFinal;
    if (!isFinal) {
      controller.next();
      await _pageController.nextPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
      return;
    }
    try {
      await controller.complete();
      if (!mounted) return;
      context.go(AppRoutes.home.path);
    } catch (e, st) {
      _log.error('Onboarding completion failed', tag: 'OnboardingScreen', error: e, stackTrace: st);
      if (!mounted) return;
      showFToast(
        context: context,
        title: const Text('Could not finish setup'),
        description: const Text('Please try again.'),
      );
    }
  }

  Future<void> _onBack() async {
    ref.read(onboardingControllerProvider.notifier).back();
    await _pageController.previousPage(duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
  }

  Future<void> _onSkip() async {
    try {
      await ref.read(onboardingControllerProvider.notifier).skip();
      if (!mounted) return;
      context.go(AppRoutes.home.path);
    } catch (e, st) {
      _log.error('Onboarding skip failed', tag: 'OnboardingScreen', error: e, stackTrace: st);
      if (!mounted) return;
      context.go(AppRoutes.home.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return FScaffold(
      header: FHeader(
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.x, size: 20),
            semanticsLabel: 'Skip onboarding',
            onPress: state.isSubmitting ? null : _onSkip,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacing.extraLarge,
                vertical: AppConstants.spacing.regular,
              ),
              child: FDeterminateProgress(value: state.progress),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const WelcomeStep(),
                  TourStep(
                    icon: FLucideIcons.timer,
                    title: 'Deep work sessions',
                    body: 'Start a focus session, stay in flow, and keep your streak alive.',
                  ),
                  TourStep(
                    icon: FLucideIcons.folder,
                    title: 'Projects & tasks',
                    body: 'Organise your work into projects and break them into clear next steps.',
                  ),
                  TourStep(
                    icon: FLucideIcons.lineChart,
                    title: 'Insights that matter',
                    body: 'See your patterns over time — daily, weekly, and yearly.',
                  ),
                  NameStep(initialValue: state.enteredName, onChanged: controller.updateName),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing.extraLarge),
              child: Row(
                children: [
                  if (state.canGoBack)
                    FButton(variant: .ghost, onPress: state.isSubmitting ? null : _onBack, child: const Text('Back')),
                  const Spacer(),
                  FButton(
                    onPress: state.isSubmitting ? null : _onPrimary,
                    child: Text(state.isFinal ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
