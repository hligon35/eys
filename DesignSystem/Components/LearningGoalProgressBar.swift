import SwiftUI

struct LearningGoalProgressBar: View {
    let title: String
    let progress: Double
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(DS.Typography.cardTitle)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(DS.Colors.softGray)
                    Capsule().fill(DS.Colors.teal)
                        .frame(width: proxy.size.width * max(0, min(1, progress)))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 12)

            Text(caption)
                .font(DS.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }
}
