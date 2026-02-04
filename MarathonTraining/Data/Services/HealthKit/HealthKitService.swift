import Foundation
import HealthKit
import Observation

/// Service for interacting with HealthKit to fetch running and health data
@Observable
final class HealthKitService {
    private let healthStore: HKHealthStore

    /// Whether HealthKit is available on this device
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    init() {
        self.healthStore = HKHealthStore()
    }

    // MARK: - Authorization

    /// Request authorization to read health data
    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate),
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    // MARK: - Running Workouts

    /// Fetch running workouts within a date range
    func fetchRunningWorkouts(from startDate: Date, to endDate: Date) async throws -> [RunningWorkout] {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        let workoutType = HKWorkoutType.workoutType()
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let datePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        let compoundPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [predicate, datePredicate]
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        let workouts = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkout], Error>) in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: compoundPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let workouts = samples as? [HKWorkout] ?? []
                continuation.resume(returning: workouts)
            }
            healthStore.execute(query)
        }

        var runningWorkouts: [RunningWorkout] = []
        for workout in workouts {
            let heartRate = try await fetchHeartRate(for: workout)
            let runningWorkout = RunningWorkout(
                id: workout.uuid,
                startDate: workout.startDate,
                endDate: workout.endDate,
                distance: workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
                duration: workout.duration,
                calories: workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()),
                averageHeartRate: heartRate.average,
                maxHeartRate: heartRate.max
            )
            runningWorkouts.append(runningWorkout)
        }

        return runningWorkouts
    }

    /// Fetch heart rate data for a specific workout
    func fetchHeartRate(for workout: HKWorkout) async throws -> (average: Double?, max: Double?) {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let quantitySamples = samples as? [HKQuantitySample] ?? []
                continuation.resume(returning: quantitySamples)
            }
            healthStore.execute(query)
        }

        guard !samples.isEmpty else {
            return (nil, nil)
        }

        let heartRates = samples.map {
            $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        }

        let average = heartRates.reduce(0, +) / Double(heartRates.count)
        let max = heartRates.max()

        return (average, max)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case queryFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "ヘルスケアはこのデバイスで利用できません"
        case .authorizationDenied:
            return "ヘルスケアへのアクセスが拒否されました"
        case .queryFailed(let error):
            return "データの取得に失敗しました: \(error.localizedDescription)"
        }
    }
}
