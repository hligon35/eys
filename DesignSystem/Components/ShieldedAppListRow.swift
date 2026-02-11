import SwiftUI

struct ShieldedAppListRow: View {
    let title: String
    let subtitle: String
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(DS.Colors.softGray)
                    .frame(width: 44, height: 44)
                Image(systemName: "apps.iphone")
                    .foregroundStyle(DS.Colors.deepPurple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.cardTitle)
                Text(subtitle)
                    .font(DS.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Text("Selected")
                    .font(.caption.weight(.semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Capsule().fill(DS.Colors.teal.opacity(0.18)))
                    .foregroundStyle(DS.Colors.teal)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.vertical, 6)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
