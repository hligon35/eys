// DeviceActivity Report Extension stub
// Add this file to a DeviceActivityReport extension target in Xcode.

#if canImport(DeviceActivity)
import DeviceActivity
import SwiftUI

@main
struct EarnYourScreenReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Placeholder: supply a minimal report scene.
        DeviceActivityReportScene(DeviceActivityReport.Name("earn_your_screen_report")) { context in
            let store = ScreenTimeSharedStore()
            let minutes = max(0, store.learningSecondsToday) / 60
            VStack(alignment: .leading, spacing: 8) {
                Text("Earn Your Screen")
                    .font(.headline)
                Text(store.isLocked ? "Locked" : "Unlocked")
                    .font(.caption.weight(.semibold))
                Text("Learning today: \(minutes)m")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
#endif
