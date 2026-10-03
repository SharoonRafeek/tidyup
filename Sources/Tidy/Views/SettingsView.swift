import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section {
                Toggle("Enable Tidy", isOn: $model.isEnabled)
            }

            Section("Modes") {
                ForEach(FixMode.allCases) { mode in
                    Button {
                        model.mode = mode
                    } label: {
                        ModeOptionRow(mode: mode, isSelected: model.mode == mode)
                    }
                    .buttonStyle(.plain)
                }
            }

            Section {
                LabeledContent("Trigger") {
                    ShortcutRecorder(model: model)
                }
            } footer: {
                Group {
                    if model.hotKeyFailed {
                        Text("That shortcut is unavailable. Try another one.")
                            .foregroundStyle(.red)
                    } else {
                        Text("Click to record a new shortcut. Press Esc to cancel.")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.callout)
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .frame(width: 440, height: 330)
    }
}
