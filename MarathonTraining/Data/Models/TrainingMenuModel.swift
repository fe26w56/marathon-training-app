import Foundation
import SwiftData

/// Training menu model for daily workout plans
@Model
final class TrainingMenuModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var trainingTypeRaw: String
    var targetDistance: Double?  // km
    var targetDuration: TimeInterval?
    var targetPace: Double?  // minutes per km
    var menuDescription: String?
    var isCompleted: Bool
    var completedAt: Date?

    var race: RaceModel?
    var weeklyGoal: WeeklyGoalModel?

    init(
        id: UUID = UUID(),
        date: Date,
        type: TrainingType,
        targetDistance: Double? = nil,
        targetDuration: TimeInterval? = nil,
        targetPace: Double? = nil,
        description: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.date = date
        self.trainingTypeRaw = type.rawValue
        self.targetDistance = targetDistance
        self.targetDuration = targetDuration
        self.targetPace = targetPace
        self.menuDescription = description
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }

    /// Training type computed property
    var type: TrainingType {
        get { TrainingType(rawValue: trainingTypeRaw) ?? .easy }
        set { trainingTypeRaw = newValue.rawValue }
    }

    /// Formatted target pace string
    var formattedTargetPace: String? {
        guard let pace = targetPace else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d/km", minutes, seconds)
    }

    /// Mark as completed
    func markAsCompleted() {
        isCompleted = true
        completedAt = Date()
    }
}
