import SwiftUI

struct ChoreListRow: View {
    let title: String
    let points: Int
    let status: ChoreInstance.Status

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(badgeColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: badgeIcon)
                    .foregroundStyle(badgeColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.cardTitle)
                Text("\(points) XP")
                    .font(DS.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(statusLabel)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Capsule().fill(badgeColor.opacity(0.16)))
                .foregroundStyle(badgeColor)
        }
        .padding(.vertical, 6)
        .animation(.easeInOut(duration: 0.25), value: status)
    }

    private var badgeColor: Color {
        switch status {
        case .todo: return .primary
        case .submitted: return DS.Colors.accentYellow
        case .approved: return DS.Colors.teal
        case .rejected: return .red
        }
    }

    private var badgeIcon: String {
        switch status {
        case .todo: return "circle"
        case .submitted: return "clock"
        case .approved: return "checkmark"
        case .rejected: return "xmark"
        }
    }

    private var statusLabel: String {
        switch status {
        case .todo: return "To‑do"
        case .submitted: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Try again"
        }
    }
}
