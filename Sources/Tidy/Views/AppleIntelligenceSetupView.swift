import AppKit
import SwiftUI

struct AppleIntelligenceSetupView: View {
    @ObservedObject var model: AppModel
    @State private var settingsOpenFailed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(model.modelStatus.title, systemImage: model.modelStatus == .ready ? "checkmark.circle.fill" : "sparkles")
                .font(.subheadline.weight(.semibold))

            Text(model.modelStatus.message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if model.modelStatus != .ready {
                ForEach(Array(model.modelStatus.setupSteps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                        Text(step)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.caption)
                }

                if model.modelStatus != .unsupported {
                    Text("macOS manages the download automatically. You don't need to download a model file yourself.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("Open System Settings") { openSystemSettings() }
                        .buttonStyle(.borderedProminent)

                    if settingsOpenFailed {
                        Text("Open System Settings from the Apple menu, then find Apple Intelligence or Siri.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Button("Check Again") { model.refreshModelStatus() }
                    Spacer()
                    Link("Apple's Setup Guide", destination: URL(string: "https://support.apple.com/en-us/121115")!)
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            while !Task.isCancelled {
                model.refreshModelStatus()
                do {
                    try await Task.sleep(for: .seconds(5))
                } catch {
                    return
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.refreshModelStatus()
        }
    }

    private func openSystemSettings() {
        let workspace = NSWorkspace.shared
        let paneURL = URL(string: "x-apple.systempreferences:com.apple.Siri-Settings.extension")!
        if workspace.open(paneURL) {
            settingsOpenFailed = false
        } else {
            settingsOpenFailed = !workspace.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
        }
    }
}
