import SwiftUI

struct ModeOptionRow: View {
    let mode: FixMode
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: mode.symbolName)
                .frame(width: 18, height: 18)
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(mode.title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Text(mode.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .contentShape(Rectangle())
    }
}
