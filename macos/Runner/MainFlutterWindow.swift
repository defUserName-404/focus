import Cocoa
import FlutterMacOS
import ServiceManagement

class MainFlutterWindow: NSWindow {
  private func configureLaunchAtStartupChannel(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "launch_at_startup", binaryMessenger: binaryMessenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "launchAtStartupIsEnabled":
        if #available(macOS 13.0, *) {
          result(SMAppService.mainApp.status == .enabled)
        } else {
          result(false)
        }

      case "launchAtStartupSetEnabled":
        guard
          let args = call.arguments as? [String: Any],
          let setEnabledValue = args["setEnabledValue"] as? Bool
        else {
          result(
            FlutterError(
              code: "invalid_arguments",
              message: "Expected bool argument: setEnabledValue",
              details: nil
            )
          )
          return
        }

        if #available(macOS 13.0, *) {
          do {
            if setEnabledValue {
              try SMAppService.mainApp.register()
            } else {
              try SMAppService.mainApp.unregister()
            }
            result(nil)
          } catch {
            result(
              FlutterError(
                code: "launch_at_startup_error",
                message: error.localizedDescription,
                details: nil
              )
            )
          }
        } else {
          result(
            FlutterError(
              code: "unsupported_macos_version",
              message: "Launch at startup requires macOS 13.0 or newer.",
              details: nil
            )
          )
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    configureLaunchAtStartupChannel(binaryMessenger: flutterViewController.engine.binaryMessenger)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
