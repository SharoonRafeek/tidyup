import SwiftUI
import AppKit

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var model: AppModel

    var body: some View {
        panelContent
            .frame(width: 324)
            .onAppear { model.refreshModelStatus() }
    }

    private var panelContent: some View {
        VStack(spacing: 0) {
            headerRow
            Divider()
            if model.modelStatus == .ready {
                sectionHeader
                modeRows
            } else {
                AppleIntelligenceSetupView(model: model)
                    .padding(14)
            }
            if showsStatus {
                Divider()
                Text(model.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
            }
        }
    }

    private var showsStatus: Bool {
        !model.statusMessage.isEmpty && (model.modelStatus == .ready || !model.isEnabled)
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("TidyUp")
                    .font(.system(size: 16, weight: .semibold))

                Text(model.isBusy ? "Working..." : model.hotKey.displayString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button {
                openWindow(id: "settings")
                NSApplication.shared.activate(ignoringOtherApps: true)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Settings")
            .accessibilityLabel("Settings")

            Toggle("Enabled", isOn: $model.isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.regular)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var sectionHeader: some View {
        Text("Modes")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }

    private var modeRows: some View {
        VStack(spacing: 0) {
            ForEach(Array(FixMode.allCases.enumerated()), id: \.element.id) { index, mode in
                modeRow(for: mode)

                if index < FixMode.allCases.count - 1 {
                    Divider()
                        .padding(.leading, 42)
                }
            }
        }
        .padding(.bottom, 8)
    }

    private func modeRow(for mode: FixMode) -> some View {
        let isSelected = model.mode == mode

        return Button {
            model.mode = mode
        } label: {
            ModeOptionRow(mode: mode, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
