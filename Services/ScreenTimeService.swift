import Foundation

final class ScreenTimeService {
    // Note: Screen Time APIs require entitlements, Family Sharing setup, and iOS device testing.
    // This implementation is intentionally minimal: it wires the real APIs while keeping business rules simple.

    private var sharedStore = ScreenTimeSharedStore()

    func requestAuthorizationIfNeeded() async {
#if canImport(FamilyControls)
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            // Intentionally ignore in scaffolding; surface via UI/logging later.
        }
#else
        // No-op when FamilyControls isn't available.
#endif
    }

    func applyLockedState(_ locked: Bool) {
        sharedStore.isLocked = locked
        applyShieldingFromSharedState()
    }

    private func applyShieldingFromSharedState() {
#if canImport(ManagedSettings) && canImport(FamilyControls)
        let store = ManagedSettingsStore()

        if sharedStore.approvedWindowIsActive {
            let selection = sharedStore.approvedWindowSelection ?? FamilyActivitySelection()
            // Approved-window behavior: shield all apps except the approved selection.
            store.shield.applicationCategories = .all(except: selection.applicationTokens)
            store.shield.applications = nil
            return
        }

        guard sharedStore.isLocked else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            return
        }

        let selection = sharedStore.learningSelection ?? FamilyActivitySelection()
        // Lock behavior: shield all apps except the learning apps selection.
        store.shield.applicationCategories = .all(except: selection.applicationTokens)
        store.shield.applications = nil
#else
        // No-op when ManagedSettings/FamilyControls aren't available.
#endif
    }

    func startMonitoringLearningApps(selection: FamilyActivitySelection) {
        sharedStore.learningSelection = selection

        // If currently locked, immediately re-apply shielding so new learning apps are exempted.
        applyLockedState(sharedStore.isLocked)

#if canImport(DeviceActivity) && canImport(FamilyControls)
        let center = DeviceActivityCenter()

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: DateComponents(minute: 5)
        )

        // Minimal event: triggers when the child has spent N minutes in the selected learning apps.
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(second: ScreenTimeSharedStore.learningEventThresholdSeconds)
        )

        do {
            try center.startMonitoring(
                DeviceActivityName(ScreenTimeSharedStore.activityName),
                during: schedule,
                events: [DeviceActivityEvent.Name(ScreenTimeSharedStore.learningEventName): event]
            )
        } catch {
            // Intentionally ignore in scaffolding; surface via UI/logging later.
        }
#else
        // No-op when DeviceActivity isn't available.
#endif
    }

    func startMonitoringApprovedOnlyWindow(selection: FamilyActivitySelection, startMinutes: Int, endMinutes: Int) {
        sharedStore.approvedWindowSelection = selection

#if canImport(DeviceActivity)
        let center = DeviceActivityCenter()
        let start = max(0, min(23 * 60 + 59, startMinutes))
        let end = max(0, min(23 * 60 + 59, endMinutes))
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: start / 60, minute: start % 60),
            intervalEnd: DateComponents(hour: end / 60, minute: end % 60),
            repeats: true,
            warningTime: nil
        )

        do {
            try center.startMonitoring(DeviceActivityName(ScreenTimeSharedStore.approvedWindowActivityName), during: schedule)
        } catch {
            // Intentionally ignore in scaffolding; surface via UI/logging later.
        }
#else
        // No-op when DeviceActivity isn't available.
#endif
    }
}

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(ManagedSettings)
import ManagedSettings
#endif

#if canImport(DeviceActivity)
import DeviceActivity
#endif
