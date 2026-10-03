import AppKit
import SwiftUI

@main
struct TidyApp: App {
    @StateObject private var model = AppModel.shared

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        HotKeyManager.shared.onHotKey = {
            AppModel.shared.triggerFixSelectedText()
        }
        AppModel.shared.registerHotKey()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            Image(nsImage: MenuBarIcon.image(enabled: model.isEnabled))
        }
        .menuBarExtraStyle(.window)

        Window("Tidy Settings", id: "settings") {
            SettingsView(model: model)
        }
        .windowResizability(.contentSize)
        .restorationBehavior(.disabled)
        .defaultLaunchBehavior(.suppressed)
    }
}
