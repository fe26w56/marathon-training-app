import Foundation
import SwiftData
import Observation

/// Training level for menu templates
enum TrainingLevel: String, CaseIterable {
    case beginner
    case intermediate
    case advanced

    var displayName: String {
        switch self {
        case .beginner: return "初心者（週30km）"
        case .intermediate: return "中級者（週50km）"
        case .advanced: return "上級者（週70km）"
        }
    }

    var weeklyDistance: Double {
        switch self {
        case .beginner: return 30
        case .intermediate: return 50
        case .advanced: return 70
        }
    }

    var trainingDays: Int {
        switch self {
        case .beginner: return 4
        case .intermediate: return 5
        case .advanced: return 6
        }
    }
}

/// ViewModel for Weekly Menu screen
@Observable
final class WeeklyMenuViewModel {
    private var modelContext: ModelContext?

    var currentWeekStart: Date = Date()
    var weeklyMenus: [TrainingMenuModel] = []
    var weeklyGoal: WeeklyGoalModel?
    var isLoading: Bool = false
    var showingTemplateSheet: Bool = false

    init() {
        // Set to Monday of current week
        let calendar = Calendar.current
        if let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) {
            currentWeekStart = weekStart
        }
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor
    func loadWeekData() async {
        guard let modelContext = modelContext else { return }

        isLoading = true

        let calendar = Calendar.current
        let weekStart = currentWeekStart
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return }

        // Fetch weekly menus
        let menuDescriptor = FetchDescriptor<TrainingMenuModel>(
            predicate: #Predicate { menu in
                menu.date >= weekStart && menu.date < weekEnd
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            weeklyMenus = try modelContext.fetch(menuDescriptor)
        } catch {
            print("Failed to fetch menus: \(error)")
            weeklyMenus = []
        }

        // Fetch weekly goal
        let goalDescriptor = FetchDescriptor<WeeklyGoalModel>(
            predicate: #Predicate { goal in
                goal.weekStartDate >= weekStart && goal.weekStartDate < weekEnd
            }
        )

        do {
            let goals = try modelContext.fetch(goalDescriptor)
            weeklyGoal = goals.first
        } catch {
            print("Failed to fetch goal: \(error)")
            weeklyGoal = nil
        }

        isLoading = false
    }

    func previousWeek() {
        let calendar = Calendar.current
        if let newStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) {
            currentWeekStart = newStart
            Task {
                await loadWeekData()
            }
        }
    }

    func nextWeek() {
        let calendar = Calendar.current
        if let newStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart) {
            currentWeekStart = newStart
            Task {
                await loadWeekData()
            }
        }
    }

    @MainActor
    func applyTemplate(_ level: TrainingLevel) async {
        guard let modelContext = modelContext else { return }

        let calendar = Calendar.current
        let weekStart = currentWeekStart
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return }

        // Fetch fresh data for the current week to avoid race conditions
        let menuDescriptor = FetchDescriptor<TrainingMenuModel>(
            predicate: #Predicate { menu in
                menu.date >= weekStart && menu.date < weekEnd
            }
        )
        let existingMenus = (try? modelContext.fetch(menuDescriptor)) ?? []

        let goalDescriptor = FetchDescriptor<WeeklyGoalModel>(
            predicate: #Predicate { goal in
                goal.weekStartDate >= weekStart && goal.weekStartDate < weekEnd
            }
        )
        let existingGoal = (try? modelContext.fetch(goalDescriptor))?.first

        // Delete existing menus for this week
        for menu in existingMenus {
            modelContext.delete(menu)
        }

        // Create or update weekly goal
        let goalToUse: WeeklyGoalModel
        if let existingGoal = existingGoal {
            existingGoal.targetDistance = level.weeklyDistance
            existingGoal.targetTrainingDays = level.trainingDays
            goalToUse = existingGoal
        } else {
            goalToUse = WeeklyGoalModel(
                weekStartDate: weekStart,
                targetDistance: level.weeklyDistance,
                targetTrainingDays: level.trainingDays
            )
            modelContext.insert(goalToUse)
        }

        // Create menus based on template
        let template = getTemplate(for: level)
        for (dayOffset, menuType) in template.enumerated() {
            guard let menuDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }

            let menu = TrainingMenuModel(
                date: menuDate,
                type: menuType.type,
                targetDistance: menuType.distance,
                targetPace: menuType.pace
            )
            menu.weeklyGoal = goalToUse
            modelContext.insert(menu)
        }

        do {
            try modelContext.save()
            await loadWeekData()
        } catch {
            print("Failed to save template: \(error)")
        }

        showingTemplateSheet = false
    }

    @MainActor
    func toggleMenuCompletion(_ menu: TrainingMenuModel) async {
        if menu.isCompleted {
            menu.isCompleted = false
            menu.completedAt = nil
        } else {
            menu.markAsCompleted()
        }

        do {
            try modelContext?.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func getTemplate(for level: TrainingLevel) -> [(type: TrainingType, distance: Double?, pace: Double?)] {
        switch level {
        case .beginner:
            return [
                (type: .easy, distance: 5, pace: 6.5),
                (type: .rest, distance: nil, pace: nil),
                (type: .easy, distance: 5, pace: 6.5),
                (type: .rest, distance: nil, pace: nil),
                (type: .easy, distance: 3, pace: 7.0),
                (type: .longRun, distance: 10, pace: 7.0),
                (type: .rest, distance: nil, pace: nil),
            ]
        case .intermediate:
            return [
                (type: .easy, distance: 8, pace: 5.5),
                (type: .tempo, distance: 6, pace: 5.0),
                (type: .easy, distance: 8, pace: 5.5),
                (type: .rest, distance: nil, pace: nil),
                (type: .interval, distance: 6, pace: 4.5),
                (type: .longRun, distance: 15, pace: 6.0),
                (type: .recovery, distance: 5, pace: 6.5),
            ]
        case .advanced:
            return [
                (type: .easy, distance: 10, pace: 5.0),
                (type: .tempo, distance: 10, pace: 4.5),
                (type: .easy, distance: 10, pace: 5.0),
                (type: .interval, distance: 8, pace: 4.0),
                (type: .easy, distance: 8, pace: 5.0),
                (type: .longRun, distance: 20, pace: 5.5),
                (type: .recovery, distance: 6, pace: 6.0),
            ]
        }
    }

    func menu(for date: Date) -> TrainingMenuModel? {
        let calendar = Calendar.current
        return weeklyMenus.first { menu in
            calendar.isDate(menu.date, inSameDayAs: date)
        }
    }

    func weekDates() -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: currentWeekStart)
        }
    }

    var weekTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"

        let calendar = Calendar.current
        let weekOfMonth = calendar.component(.weekOfMonth, from: currentWeekStart)

        return "\(formatter.string(from: currentWeekStart)) 第\(weekOfMonth)週"
    }
}
