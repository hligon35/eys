import SwiftUI

struct CardContainer<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DS.Colors.cardBackground)
                    .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(DS.Colors.subtleBorder.opacity(0.5), lineWidth: 0.5)
            )
    }
}
