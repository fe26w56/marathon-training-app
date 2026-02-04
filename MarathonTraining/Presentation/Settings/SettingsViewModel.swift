import Foundation
import HealthKit
import Observation
import UIKit

/// HealthKit authorization state
enum HealthKitAuthState: String {
    case notDetermined = "notDetermined"
    case authorized = "authorized"
    case denied = "denied"
    case unavailable = "unavailable"

    var displayName: String {
        switch self {
        case .notDetermined: return "未設定"
        case .authorized: return "許可済み"
        case .denied: return "拒否"
        case .unavailable: return "利用不可"
        }
    }

    var icon: String {
        switch self {
        case .notDetermined: return "questionmark.circle"
        case .authorized: return "checkmark.circle.fill"
        case .denied: return "xmark.circle.fill"
        case .unavailable: return "exclamationmark.triangle.fill"
        }
    }

    var color: String {
        switch self {
        case .notDetermined: return "secondary"
        case .authorized: return "green"
        case .denied: return "red"
        case .unavailable: return "orange"
        }
    }
}

/// ViewModel for Settings screen
@Observable
final class SettingsViewModel {
    private var healthKitService: HealthKitService?

    var healthKitAuthState: HealthKitAuthState = .notDetermined
    var isNotificationEnabled: Bool = false
    var reminderTime: Date = {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var userName: String = ""
    var targetPace: Double = 6.0

    var isLoading: Bool = false

    func configure(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
        checkHealthKitStatus()
        loadUserDefaults()
    }

    func checkHealthKitStatus() {
        guard let healthKitService = healthKitService else {
            healthKitAuthState = .unavailable
            return
        }

        if !healthKitService.isAvailable {
            healthKitAuthState = .unavailable
            return
        }

        let healthStore = HKHealthStore()
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)

        switch status {
        case .notDetermined:
            healthKitAuthState = .notDetermined
        case .sharingAuthorized:
            healthKitAuthState = .authorized
        case .sharingDenied:
            healthKitAuthState = .denied
        @unknown default:
            healthKitAuthState = .notDetermined
        }
    }

    @MainActor
    func requestHealthKitAuthorization() async {
        guard let healthKitService = healthKitService else { return }

        isLoading = true

        do {
            try await healthKitService.requestAuthorization()
            checkHealthKitStatus()
        } catch {
            print("Authorization failed: \(error)")
        }

        isLoading = false
    }

    func openHealthSettings() {
        // Open Health app settings
        if let url = URL(string: "x-apple-health://") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #endif
        }
    }

    func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(targetPace, forKey: "targetPace")
    }

    func saveNotificationSettings() {
        UserDefaults.standard.set(isNotificationEnabled, forKey: "isNotificationEnabled")
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")

        // Schedule notification if enabled
        if isNotificationEnabled {
            scheduleTrainingReminder()
        } else {
            cancelTrainingReminder()
        }
    }

    private func loadUserDefaults() {
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        targetPace = UserDefaults.standard.double(forKey: "targetPace")
        if targetPace == 0 {
            targetPace = 6.0
        }
        isNotificationEnabled = UserDefaults.standard.bool(forKey: "isNotificationEnabled")
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = savedTime
        }
    }

    private func scheduleTrainingReminder() {
        // Note: Actual notification scheduling requires UNUserNotificationCenter
        // This is a placeholder for the notification logic
        print("Scheduling reminder at \(reminderTime)")
    }

    private func cancelTrainingReminder() {
        // Note: Actual notification cancellation requires UNUserNotificationCenter
        print("Cancelling training reminder")
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
