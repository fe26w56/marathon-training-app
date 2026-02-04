import Foundation
import SwiftData

/// Long-term goal model for tracking major running goals
@Model
final class LongTermGoalModel {
    @Attribute(.unique) var id: UUID
    var goalTypeRaw: String
    var customDescription: String?
    var targetDate: Date?
    var isAchieved: Bool
    var achievedAt: Date?

    init(
        id: UUID = UUID(),
        type: GoalType,
        customDescription: String? = nil,
        targetDate: Date? = nil,
        isAchieved: Bool = false,
        achievedAt: Date? = nil
    ) {
        self.id = id
        self.goalTypeRaw = type.rawValue
        self.customDescription = customDescription
        self.targetDate = targetDate
        self.isAchieved = isAchieved
        self.achievedAt = achievedAt
    }

    /// Goal type computed property
    var type: GoalType {
        get { GoalType(rawValue: goalTypeRaw) ?? .custom }
        set { goalTypeRaw = newValue.rawValue }
    }

    /// Display name for the goal
    var displayName: String {
        if type == .custom {
            return customDescription ?? "カスタム目標"
        }
        return type.displayName
    }

    /// Days remaining until target date
    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day
    }

    /// Mark as achieved
    func markAsAchieved() {
        isAchieved = true
        achievedAt = Date()
    }
}
