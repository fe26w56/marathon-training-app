import Foundation
import SwiftData

/// Weekly goal model for tracking weekly training targets
@Model
final class WeeklyGoalModel {
    @Attribute(.unique) var id: UUID
    var weekStartDate: Date
    var targetDistance: Double  // km
    var targetTrainingDays: Int

    @Relationship(deleteRule: .nullify, inverse: \TrainingMenuModel.weeklyGoal)
    var trainingMenus: [TrainingMenuModel]?

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        targetDistance: Double,
        targetTrainingDays: Int
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.targetDistance = targetDistance
        self.targetTrainingDays = targetTrainingDays
    }

    /// Week end date (Sunday)
    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
    }

    /// Total completed distance for the week
    var completedDistance: Double {
        trainingMenus?
            .filter { $0.isCompleted }
            .compactMap { $0.targetDistance }
            .reduce(0, +) ?? 0
    }

    /// Number of completed training days
    var completedTrainingDays: Int {
        trainingMenus?.filter { $0.isCompleted && $0.type != .rest }.count ?? 0
    }

    /// Distance achievement rate (0.0 - 1.0)
    var distanceAchievementRate: Double {
        guard targetDistance > 0 else { return 0 }
        return min(completedDistance / targetDistance, 1.0)
    }

    /// Training days achievement rate (0.0 - 1.0)
    var trainingDaysAchievementRate: Double {
        guard targetTrainingDays > 0 else { return 0 }
        return min(Double(completedTrainingDays) / Double(targetTrainingDays), 1.0)
    }
}
