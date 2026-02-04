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
            HKCategoryType(.sleepAnalysis),
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

        // Check authorization status for workout type
        let workoutType = HKObjectType.workoutType()
        let status = healthStore.authorizationStatus(for: workoutType)
        if status == .sharingDenied {
            throw HealthKitError.authorizationDenied
        }
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

    // MARK: - Sleep Data

    /// Fetch sleep data within a date range
    /// Note: Sleep data is queried from 6PM the previous day to 6AM next day for accurate tracking
    func fetchSleepData(from startDate: Date, to endDate: Date) async throws -> [SleepRecord] {
        guard isAvailable else {
            throw HealthKitError.notAvailable
        }

        let sleepType = HKCategoryType(.sleepAnalysis)

        // Expand date range to capture overnight sleep
        // Sleep starting at 10PM on day 1 should be included when querying day 1
        let calendar = Calendar.current
        let adjustedStartDate = calendar.date(byAdding: .hour, value: -6, to: startDate) ?? startDate
        let adjustedEndDate = calendar.date(byAdding: .hour, value: 12, to: endDate) ?? endDate

        let predicate = HKQuery.predicateForSamples(
            withStart: adjustedStartDate,
            end: adjustedEndDate,
            options: .strictStartDate
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: true
        )

        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKCategorySample], Error>) in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let categorySamples = samples as? [HKCategorySample] ?? []
                continuation.resume(returning: categorySamples)
            }
            healthStore.execute(query)
        }

        return groupSleepSamplesIntoRecords(samples, from: startDate, to: endDate)
    }

    /// Group sleep samples into daily sleep records
    private func groupSleepSamplesIntoRecords(
        _ samples: [HKCategorySample],
        from startDate: Date,
        to endDate: Date
    ) -> [SleepRecord] {
        guard !samples.isEmpty else { return [] }

        let calendar = Calendar.current

        // Group samples by sleep session (gaps > 2 hours indicate new session)
        var sleepSessions: [[HKCategorySample]] = []
        var currentSession: [HKCategorySample] = []

        for sample in samples {
            if let lastSample = currentSession.last {
                let gap = sample.startDate.timeIntervalSince(lastSample.endDate)
                if gap > 2 * 3600 {  // 2 hours gap
                    if !currentSession.isEmpty {
                        sleepSessions.append(currentSession)
                    }
                    currentSession = [sample]
                } else {
                    currentSession.append(sample)
                }
            } else {
                currentSession.append(sample)
            }
        }
        if !currentSession.isEmpty {
            sleepSessions.append(currentSession)
        }

        // Convert sessions to SleepRecord
        var records: [SleepRecord] = []
        for session in sleepSessions {
            guard let firstSample = session.first,
                  let lastSample = session.last else { continue }

            // Determine the date for this sleep record
            // Only assign to previous day for overnight sleep (started between 6PM-midnight, ended after midnight)
            // Naps and morning sleep stay on their actual date
            let sleepDate: Date
            let startHour = calendar.component(.hour, from: firstSample.startDate)
            let sleepDuration = lastSample.endDate.timeIntervalSince(firstSample.startDate)

            // Consider it overnight sleep if:
            // 1. Started between 6PM and midnight (18-23)
            // 2. OR started after midnight but before 6AM AND duration > 3 hours (main sleep, not nap)
            let isOvernightSleep = (startHour >= 18) ||
                (startHour < 6 && sleepDuration > 3 * 3600)

            if startHour < 6 && isOvernightSleep {
                // Sleep started after midnight but is part of main overnight sleep
                sleepDate = calendar.date(byAdding: .day, value: -1, to: firstSample.startDate) ?? firstSample.startDate
            } else {
                // Naps, daytime sleep, or sleep that started before midnight
                sleepDate = firstSample.startDate
            }

            // Only include records within the requested date range
            let recordDateStart = calendar.startOfDay(for: sleepDate)
            let queryDateStart = calendar.startOfDay(for: startDate)
            let queryDateEnd = calendar.startOfDay(for: endDate)

            guard recordDateStart >= queryDateStart && recordDateStart <= queryDateEnd else { continue }

            let segments = session.map { sample in
                SleepSegment(
                    id: sample.uuid,
                    stage: mapSleepValue(sample.value),
                    startDate: sample.startDate,
                    endDate: sample.endDate
                )
            }

            let record = SleepRecord(
                id: UUID(),
                date: calendar.startOfDay(for: sleepDate),
                bedTime: firstSample.startDate,
                wakeTime: lastSample.endDate,
                segments: segments
            )
            records.append(record)
        }

        return records.sorted { $0.date > $1.date }
    }

    /// Map HealthKit sleep value to SleepStage
    private func mapSleepValue(_ value: Int) -> SleepStage {
        switch value {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return .inBed
        case HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue:
            return .asleepUnspecified
        case HKCategoryValueSleepAnalysis.awake.rawValue:
            return .awake
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return .asleepCore
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return .asleepDeep
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return .asleepREM
        default:
            return .asleepUnspecified
        }
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
