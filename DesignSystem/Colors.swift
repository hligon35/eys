import SwiftUI

enum DS {
    enum Colors {
        static let deepPurple = Color(hex: "4B2E83")
        static let teal = Color(hex: "2EC4B6")
        static let softGray = Color(hex: "F5F5F7")
        static let charcoal = Color(hex: "1C1C1E")
        static let accentYellow = Color(hex: "FFD166")

        static let cardBackground = Color(uiColor: .secondarySystemBackground)
        static let pageBackground = Color(uiColor: .systemBackground)
        static let subtleBorder = Color(uiColor: .separator)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
