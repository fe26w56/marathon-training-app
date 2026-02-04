import Foundation
import SwiftData

/// Race model for storing marathon/race information
@Model
final class RaceModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var date: Date
    var distance: Double  // km
    var targetTime: TimeInterval?
    var memo: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TrainingMenuModel.race)
    var trainingMenus: [TrainingMenuModel]?

    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        distance: Double,
        targetTime: TimeInterval? = nil,
        memo: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.distance = distance
        self.targetTime = targetTime
        self.memo = memo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Days remaining until race
    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }

    /// Formatted target time string
    var formattedTargetTime: String? {
        guard let targetTime = targetTime else { return nil }
        let hours = Int(targetTime) / 3600
        let minutes = (Int(targetTime) % 3600) / 60
        let seconds = Int(targetTime) % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}
