import SwiftUI

struct UnlockStatusView: View {
    let status: UnlockStatus

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.opacity(0.16))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DS.Typography.cardTitle)
                Text(subtitle)
                    .font(DS.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(pillText)
                .font(.caption.weight(.semibold))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Capsule().fill(color.opacity(0.16)))
                .foregroundStyle(color)
                .transition(.opacity.combined(with: .scale))
        }
        .animation(.easeInOut(duration: 0.25), value: pillText)
    }

    private var color: Color {
        switch status {
        case .locked: return DS.Colors.accentYellow
        case .unlocked: return DS.Colors.teal
        }
    }

    private var icon: String {
        switch status {
        case .locked: return "lock.fill"
        case .unlocked: return "lock.open.fill"
        }
    }

    private var title: String {
        switch status {
        case .locked: return "Locked"
        case .unlocked: return "Unlocked"
        }
    }

    private var subtitle: String {
        switch status {
        case .locked(let reason): return reason
        case .unlocked: return "Enjoy your screen time" 
        }
    }

    private var pillText: String {
        switch status {
        case .locked: return "Earn it"
        case .unlocked: return "Go" 
        }
    }
}
