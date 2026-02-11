// DeviceActivity Monitor Extension
// Add this file to a DeviceActivityMonitor extension target in Xcode.

#if canImport(DeviceActivity) && canImport(ManagedSettings) && canImport(FamilyControls)
import DeviceActivity
import FamilyControls
import ManagedSettings

final class EarnYourScreenDeviceActivityMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()
    private var sharedStore = ScreenTimeSharedStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        if activity.rawValue == ScreenTimeSharedStore.approvedWindowActivityName {
            sharedStore.approvedWindowIsActive = true
        }
        applyShieldingIfNeeded(for: activity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        if activity.rawValue == ScreenTimeSharedStore.approvedWindowActivityName {
            sharedStore.approvedWindowIsActive = false
        }
        applyShieldingIfNeeded(for: activity)
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Minimal placeholder: count each threshold event as fixed learning time.
        if event.rawValue == ScreenTimeSharedStore.learningEventName {
            sharedStore.lastLearningEventAt = Date()
            sharedStore.incrementLearningSecondsToday(by: ScreenTimeSharedStore.learningEventThresholdSeconds)
        }
    }

    private func applyShieldingIfNeeded(for activity: DeviceActivityName) {
        let isLearningActivity = activity.rawValue == ScreenTimeSharedStore.activityName
        let isApprovedWindowActivity = activity.rawValue == ScreenTimeSharedStore.approvedWindowActivityName
        guard isLearningActivity || isApprovedWindowActivity else { return }

        if sharedStore.approvedWindowIsActive {
            let selection = sharedStore.approvedWindowSelection ?? FamilyActivitySelection()
            store.shield.applicationCategories = .all(except: selection.applicationTokens)
            store.shield.applications = nil
            return
        }

        if sharedStore.isLocked {
            let selection = sharedStore.learningSelection ?? FamilyActivitySelection()
            store.shield.applicationCategories = .all(except: selection.applicationTokens)
            store.shield.applications = nil
        } else {
            store.shield.applicationCategories = nil
            store.shield.applications = nil
        }
    }
}
#endif
