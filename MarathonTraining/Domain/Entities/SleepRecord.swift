import Foundation

/// Sleep stage classification
enum SleepStage: String, CaseIterable {
    case inBed = "inBed"
    case asleepUnspecified = "asleepUnspecified"
    case awake = "awake"
    case asleepCore = "asleepCore"
    case asleepDeep = "asleepDeep"
    case asleepREM = "asleepREM"

    var displayName: String {
        switch self {
        case .inBed: return "ベッド上"
        case .asleepUnspecified: return "睡眠"
        case .awake: return "覚醒"
        case .asleepCore: return "コア睡眠"
        case .asleepDeep: return "深い睡眠"
        case .asleepREM: return "レム睡眠"
        }
    }

    var icon: String {
        switch self {
        case .inBed: return "bed.double"
        case .asleepUnspecified: return "moon.zzz"
        case .awake: return "sun.max"
        case .asleepCore: return "moon"
        case .asleepDeep: return "moon.fill"
        case .asleepREM: return "sparkles"
        }
    }
}

/// Individual sleep segment within a sleep record
struct SleepSegment: Identifiable {
    let id: UUID
    let stage: SleepStage
    let startDate: Date
    let endDate: Date

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

/// Domain entity for sleep data from HealthKit
struct SleepRecord: Identifiable {
    let id: UUID
    let date: Date  // The night date (e.g., sleep starting on Feb 3 belongs to Feb 3)
    let bedTime: Date
    let wakeTime: Date
    let segments: [SleepSegment]

    /// Total sleep duration (excluding awake time)
    var totalSleepDuration: TimeInterval {
        segments
            .filter { $0.stage != .awake && $0.stage != .inBed }
            .map { $0.duration }
            .reduce(0, +)
    }

    /// Deep sleep duration
    var deepSleepDuration: TimeInterval {
        segments
            .filter { $0.stage == .asleepDeep }
            .map { $0.duration }
            .reduce(0, +)
    }

    /// REM sleep duration
    var remSleepDuration: TimeInterval {
        segments
            .filter { $0.stage == .asleepREM }
            .map { $0.duration }
            .reduce(0, +)
    }

    /// Core sleep duration
    var coreSleepDuration: TimeInterval {
        segments
            .filter { $0.stage == .asleepCore || $0.stage == .asleepUnspecified }
            .map { $0.duration }
            .reduce(0, +)
    }

    /// Sleep quality score (0-100)
    var sleepQualityScore: Double {
        guard totalSleepDuration > 0 else { return 0 }

        // Base score from duration (7-9 hours is ideal)
        let hours = totalSleepDuration / 3600
        let durationScore: Double
        if hours >= 7 && hours <= 9 {
            durationScore = 40
        } else if hours >= 6 && hours < 7 {
            durationScore = 30
        } else if hours > 9 && hours <= 10 {
            durationScore = 35
        } else {
            durationScore = max(0, 40 - abs(hours - 8) * 5)
        }

        // Deep sleep score (15-25% is ideal)
        let deepSleepRatio = deepSleepDuration / totalSleepDuration
        let deepSleepScore = min(30, deepSleepRatio * 150)

        // REM sleep score (20-25% is ideal)
        let remSleepRatio = remSleepDuration / totalSleepDuration
        let remSleepScore = min(30, remSleepRatio * 150)

        return min(100, durationScore + deepSleepScore + remSleepScore)
    }

    /// Formatted total sleep duration
    var formattedTotalSleep: String {
        let hours = Int(totalSleepDuration) / 3600
        let minutes = (Int(totalSleepDuration) % 3600) / 60
        return String(format: "%d時間%02d分", hours, minutes)
    }

    /// Formatted bed time
    var formattedBedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: bedTime)
    }

    /// Formatted wake time
    var formattedWakeTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: wakeTime)
    }
}
