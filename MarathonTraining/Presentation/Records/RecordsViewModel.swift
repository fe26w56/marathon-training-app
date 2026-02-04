import Foundation
import Observation

/// Date range filter options
enum DateRange: String, CaseIterable {
    case week
    case month
    case threeMonths

    var displayName: String {
        switch self {
        case .week: return "1週間"
        case .month: return "1ヶ月"
        case .threeMonths: return "3ヶ月"
        }
    }

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

/// Record tab selection
enum RecordTab: String, CaseIterable {
    case running
    case sleep

    var displayName: String {
        switch self {
        case .running: return "ランニング"
        case .sleep: return "睡眠"
        }
    }
}

/// ViewModel for Records screen
@Observable
final class RecordsViewModel {
    private var healthKitService: HealthKitService?

    var selectedTab: RecordTab = .running
    var dateRange: DateRange = .week
    var runningWorkouts: [RunningWorkout] = []
    var sleepRecords: [SleepRecord] = []
    var isLoading: Bool = false
    var errorMessage: String?

    func configure(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
    }

    @MainActor
    func loadData() async {
        guard let healthKitService = healthKitService else { return }

        isLoading = true
        errorMessage = nil

        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -dateRange.days, to: now) else { return }

        do {
            try await healthKitService.requestAuthorization()

            async let workoutsTask = healthKitService.fetchRunningWorkouts(from: startDate, to: now)
            async let sleepTask = healthKitService.fetchSleepData(from: startDate, to: now)

            runningWorkouts = try await workoutsTask
            sleepRecords = try await sleepTask
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func setDateRange(_ range: DateRange) {
        dateRange = range
        Task {
            await loadData()
        }
    }

    // MARK: - Running Stats

    var totalDistance: Double {
        runningWorkouts.reduce(0) { $0 + $1.distanceInKm }
    }

    var totalDuration: TimeInterval {
        runningWorkouts.reduce(0) { $0 + $1.duration }
    }

    var averagePace: Double {
        guard totalDistance > 0 else { return 0 }
        return (totalDuration / 60) / totalDistance
    }

    var dailyDistances: [(date: Date, distance: Double)] {
        let calendar = Calendar.current
        var distances: [Date: Double] = [:]

        for workout in runningWorkouts {
            let day = calendar.startOfDay(for: workout.startDate)
            distances[day, default: 0] += workout.distanceInKm
        }

        return distances.map { ($0.key, $0.value) }.sorted { $0.date < $1.date }
    }

    // MARK: - Sleep Stats

    var averageSleepDuration: TimeInterval {
        guard !sleepRecords.isEmpty else { return 0 }
        let total = sleepRecords.reduce(0) { $0 + $1.totalSleepDuration }
        return total / Double(sleepRecords.count)
    }

    var averageSleepQuality: Double {
        guard !sleepRecords.isEmpty else { return 0 }
        let total = sleepRecords.reduce(0) { $0 + $1.sleepQualityScore }
        return total / Double(sleepRecords.count)
    }
}
