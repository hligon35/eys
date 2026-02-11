import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

/// Shared state between the main app and Screen Time extensions.
///
/// IMPORTANT:
/// - This relies on an App Group. Ensure the same group identifier is enabled
///   for the app + extensions in Xcode.
/// - Add this file to the extension targets as well as the app target.
struct ScreenTimeSharedStore {
    // Keep this in sync with your configured App Group.
    static let suiteName = "group.com.yourname.EarnYourScreen"

    static let activityName = "earn_your_screen"
    static let learningEventName = "learning_threshold"

    static let approvedWindowActivityName = "approved_only_window"

    /// Must match the threshold used when creating the `DeviceActivityEvent`.
    static let learningEventThresholdSeconds: Int = 5 * 60

    private enum Key {
        static let isLocked = "eys_is_locked"
        static let learningSelection = "eys_learning_selection"
        static let approvedWindowIsActive = "eys_approved_window_is_active"
        static let approvedWindowSelection = "eys_approved_window_selection"
        static let learningSecondsDate = "eys_learning_seconds_date"
        static let learningSecondsToday = "eys_learning_seconds_today"
        static let lastLearningEventAt = "eys_last_learning_event_at"
    }

    private var defaults: UserDefaults {
        UserDefaults(suiteName: Self.suiteName) ?? .standard
    }

    var isLocked: Bool {
        get { defaults.bool(forKey: Key.isLocked) }
        set { defaults.set(newValue, forKey: Key.isLocked) }
    }

    var approvedWindowIsActive: Bool {
        get { defaults.bool(forKey: Key.approvedWindowIsActive) }
        set { defaults.set(newValue, forKey: Key.approvedWindowIsActive) }
    }

    var lastLearningEventAt: Date? {
        get { defaults.object(forKey: Key.lastLearningEventAt) as? Date }
        set { defaults.set(newValue, forKey: Key.lastLearningEventAt) }
    }

    /// Total learning seconds accumulated today from DeviceActivity events.
    ///
    /// This is placeholder accounting: each threshold event increments by
    /// `learningEventThresholdSeconds`.
    var learningSecondsToday: Int {
        mutating get {
            normalizeLearningDayIfNeeded()
            return defaults.integer(forKey: Key.learningSecondsToday)
        }
        set {
            var copy = self
            copy.normalizeLearningDayIfNeeded()
            defaults.set(max(0, newValue), forKey: Key.learningSecondsToday)
        }
    }

    mutating func incrementLearningSecondsToday(by deltaSeconds: Int) {
        normalizeLearningDayIfNeeded()
        let current = defaults.integer(forKey: Key.learningSecondsToday)
        defaults.set(max(0, current + max(0, deltaSeconds)), forKey: Key.learningSecondsToday)
    }

    private mutating func normalizeLearningDayIfNeeded(now: Date = Date()) {
        let todayKey = Self.dayKey(for: now)
        let storedKey = defaults.string(forKey: Key.learningSecondsDate)
        guard storedKey != todayKey else { return }

        defaults.set(todayKey, forKey: Key.learningSecondsDate)
        defaults.set(0, forKey: Key.learningSecondsToday)
        defaults.removeObject(forKey: Key.lastLearningEventAt)
    }

    private static func dayKey(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        let day = comps.day ?? 0
        return String(format: "%04d%02d%02d", year, month, day)
    }

#if canImport(FamilyControls)
    var learningSelection: FamilyActivitySelection? {
        get {
            guard let data = defaults.data(forKey: Key.learningSelection) else { return nil }
            return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Key.learningSelection)
        }
    }

    var approvedWindowSelection: FamilyActivitySelection? {
        get {
            guard let data = defaults.data(forKey: Key.approvedWindowSelection) else { return nil }
            return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Key.approvedWindowSelection)
        }
    }
#else
    var learningSelection: FamilyActivitySelection? {
        get { nil }
        set { }
    }

    var approvedWindowSelection: FamilyActivitySelection? {
        get { nil }
        set { }
    }
#endif
}
