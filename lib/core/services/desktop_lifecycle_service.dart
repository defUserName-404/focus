import 'dart:async';
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../features/settings/domain/entities/setting.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../utils/platform_utils.dart';
import 'log_service.dart';

/// Manages desktop runtime behavior: system tray and launch-at-startup.
///
/// This service intentionally runs only on desktop platforms.
class DesktopLifecycleService with TrayListener, WindowListener {
  static const String _menuShow = 'show';
  static const String _menuHide = 'hide';
  static const String _menuQuit = 'quit';

  static const String _trayIconAssetPath = 'assets/images/focus_app_icon.png';
  static const String _windowsPackageName = 'com.defusername.focus';

  final ISettingsRepository _settingsRepository;
  final LogService _log = LogService.instance;

  StreamSubscription<DesktopPreferences>? _desktopPrefsSub;

  bool _initialized = false;
  bool _trayInitialized = false;
  bool _trayEnabled = true;
  bool _launchAtStartupEnabled = true;
  bool _isQuitting = false;

  DesktopLifecycleService(this._settingsRepository);

  Future<void> init({required bool startHidden}) async {
    if (!PlatformUtils.isDesktop || _initialized) return;
    _initialized = true;

    trayManager.addListener(this);
    windowManager.addListener(this);

    final initialPrefs = await _settingsRepository.getDesktopPreferences();
    _trayEnabled = initialPrefs.trayEnabled;
    _launchAtStartupEnabled = initialPrefs.launchAtStartupEnabled;

    await _setTrayCloseBehavior(_trayEnabled);
    await _syncLaunchAtStartup(_launchAtStartupEnabled);

    if (_trayEnabled) {
      await _createTrayIcon();
    }

    if (startHidden && _trayEnabled) {
      await _hideToTray();
    } else {
      await _showMainWindow();
    }

    _desktopPrefsSub = _settingsRepository.watchDesktopPreferences().listen((prefs) {
      unawaited(_applyDesktopPreferences(prefs));
    });
  }

  Future<void> _applyDesktopPreferences(DesktopPreferences prefs) async {
    if (_launchAtStartupEnabled != prefs.launchAtStartupEnabled) {
      _launchAtStartupEnabled = prefs.launchAtStartupEnabled;
      await _syncLaunchAtStartup(_launchAtStartupEnabled);
    }

    if (_trayEnabled == prefs.trayEnabled) return;

    _trayEnabled = prefs.trayEnabled;
    await _setTrayCloseBehavior(_trayEnabled);

    if (_trayEnabled) {
      await _createTrayIcon();
      return;
    }

    if (_trayInitialized) {
      try {
        await trayManager.destroy();
      } catch (e, st) {
        _log.warning('Failed to destroy tray icon', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
      }
      _trayInitialized = false;
    }

    if (!await windowManager.isVisible()) {
      await _showMainWindow();
    }
  }

  Future<void> _setTrayCloseBehavior(bool enabled) async {
    try {
      await windowManager.setPreventClose(enabled);
    } catch (e, st) {
      _log.warning('Failed to update prevent-close behavior', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
    }
  }

  Future<void> _syncLaunchAtStartup(bool enabled) async {
    try {
      launchAtStartup.setup(
        appName: 'Focus',
        appPath: Platform.resolvedExecutable,
        packageName: _windowsPackageName,
        args: const ['--start-hidden'],
      );

      final isEnabled = await launchAtStartup.isEnabled();
      if (enabled && !isEnabled) {
        await launchAtStartup.enable();
      } else if (!enabled && isEnabled) {
        await launchAtStartup.disable();
      }
    } catch (e, st) {
      _log.warning(
        'Failed to apply launch-at-startup setting',
        tag: 'DesktopLifecycleService',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _createTrayIcon() async {
    if (_trayInitialized) return;

    try {
      await trayManager.setIcon(_trayIconAssetPath, isTemplate: PlatformUtils.isMacOS);
      await trayManager.setToolTip('Focus');
      await trayManager.setContextMenu(
        Menu(
          items: <MenuItem>[
            MenuItem(key: _menuShow, label: 'Open Focus'),
            MenuItem(key: _menuHide, label: 'Hide Window'),
            MenuItem.separator(),
            MenuItem(key: _menuQuit, label: 'Quit Focus'),
          ],
        ),
      );

      _trayInitialized = true;
    } catch (e, st) {
      _log.error('Failed to initialize tray icon', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
    }
  }

  Future<void> _showMainWindow() async {
    try {
      await windowManager.setSkipTaskbar(false);
      await windowManager.show();
      await windowManager.focus();
    } catch (e, st) {
      _log.warning('Failed to show main window', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
    }
  }

  Future<void> _hideToTray() async {
    try {
      await windowManager.setSkipTaskbar(true);
      await windowManager.hide();
    } catch (e, st) {
      _log.warning('Failed to hide window to tray', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
    }
  }

  Future<void> _toggleMainWindowVisibility() async {
    if (!await windowManager.isVisible()) {
      await _showMainWindow();
      return;
    }

    await _hideToTray();
  }

  Future<void> _quitApplication() async {
    _isQuitting = true;
    try {
      await windowManager.setPreventClose(false);
      if (_trayInitialized) {
        await trayManager.destroy();
        _trayInitialized = false;
      }
      await windowManager.close();
    } catch (e, st) {
      _log.error('Failed to quit app from tray menu', tag: 'DesktopLifecycleService', error: e, stackTrace: st);
    }
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(_toggleMainWindowVisibility());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _menuShow:
        unawaited(_showMainWindow());
      case _menuHide:
        unawaited(_hideToTray());
      case _menuQuit:
        unawaited(_quitApplication());
      default:
        break;
    }
  }

  @override
  void onWindowClose() {
    if (_isQuitting || !_trayEnabled) return;
    unawaited(_hideToTray());
  }

  Future<void> dispose() async {
    await _desktopPrefsSub?.cancel();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }
}
