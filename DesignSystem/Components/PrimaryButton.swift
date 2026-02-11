import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isEnabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isEnabled ? DS.Colors.deepPurple : DS.Colors.deepPurple.opacity(0.35))
            )
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
            .scaleEffect(isEnabled ? 1.0 : 0.98)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isEnabled)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityAddTraits(.isButton)
    }
}
