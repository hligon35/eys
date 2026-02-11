import SwiftUI

struct FloatingActionButton: View {
    var systemImage: String = "plus"
    var accessibilityLabel: String = "Add"
    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(DS.Colors.deepPurple)
                        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 10)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
