import Foundation

/// Domain entity for running workout data from HealthKit
struct RunningWorkout: Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let distance: Double  // meters
    let duration: TimeInterval
    let calories: Double?
    let averageHeartRate: Double?
    let maxHeartRate: Double?

    /// Distance in kilometers
    var distanceInKm: Double {
        distance / 1000
    }

    /// Pace in minutes per kilometer
    var pace: Double {
        guard distanceInKm > 0 else { return 0 }
        return (duration / 60) / distanceInKm
    }

    /// Formatted pace string (e.g., "5:30/km")
    var formattedPace: String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d/km", minutes, seconds)
    }

    /// Formatted duration string (e.g., "1:30:45")
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Formatted distance string (e.g., "5.2km")
    var formattedDistance: String {
        String(format: "%.1fkm", distanceInKm)
    }

    /// Formatted calories string (e.g., "320kcal")
    var formattedCalories: String? {
        guard let calories = calories else { return nil }
        return String(format: "%.0fkcal", calories)
    }

    /// Formatted heart rate string (e.g., "142bpm")
    var formattedAverageHeartRate: String? {
        guard let hr = averageHeartRate else { return nil }
        return String(format: "%.0fbpm", hr)
    }
}
