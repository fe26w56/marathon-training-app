import Foundation
import SwiftData
import Observation

/// ViewModel for the Home screen
@Observable
final class HomeViewModel {
    private var modelContext: ModelContext?
    private var healthKitService: HealthKitService?

    var upcomingRace: RaceModel?
    var thisWeekDistance: Double = 0
    var thisWeekGoalDistance: Double = 0
    var thisWeekAchievementRate: Double = 0
    var todayMenu: TrainingMenuModel?
    var recentWorkouts: [RunningWorkout] = []
    var isLoading: Bool = false
    var errorMessage: String?

    func configure(modelContext: ModelContext, healthKitService: HealthKitService) {
        self.modelContext = modelContext
        self.healthKitService = healthKitService
    }

    @MainActor
    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            await loadUpcomingRace()
            await loadWeeklyProgress()
            await loadTodayMenu()
            try await loadRecentWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    private func loadUpcomingRace() async {
        guard let modelContext = modelContext else { return }

        let now = Date()
        let descriptor = FetchDescriptor<RaceModel>(
            predicate: #Predicate { race in
                race.date > now
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let races = try modelContext.fetch(descriptor)
            upcomingRace = races.first
        } catch {
            print("Failed to fetch races: \(error)")
        }
    }

    @MainActor
    private func loadWeeklyProgress() async {
        guard let modelContext = modelContext else { return }

        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return }
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return }

        // Fetch weekly goal
        let goalDescriptor = FetchDescriptor<WeeklyGoalModel>(
            predicate: #Predicate { goal in
                goal.weekStartDate >= weekStart && goal.weekStartDate < weekEnd
            }
        )

        do {
            let goals = try modelContext.fetch(goalDescriptor)
            if let goal = goals.first {
                thisWeekGoalDistance = goal.targetDistance
            } else {
                thisWeekGoalDistance = 30  // Default 30km
            }
        } catch {
            thisWeekGoalDistance = 30
        }

        // Fetch completed training menus for this week
        let menuDescriptor = FetchDescriptor<TrainingMenuModel>(
            predicate: #Predicate { menu in
                menu.date >= weekStart && menu.date < weekEnd && menu.isCompleted
            }
        )

        do {
            let menus = try modelContext.fetch(menuDescriptor)
            thisWeekDistance = menus.compactMap { $0.targetDistance }.reduce(0, +)
            thisWeekAchievementRate = thisWeekGoalDistance > 0 ? min(thisWeekDistance / thisWeekGoalDistance, 1.0) : 0
        } catch {
            thisWeekDistance = 0
            thisWeekAchievementRate = 0
        }
    }

    @MainActor
    private func loadTodayMenu() async {
        guard let modelContext = modelContext else { return }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        guard let todayEnd = calendar.date(byAdding: .day, value: 1, to: todayStart) else { return }

        let descriptor = FetchDescriptor<TrainingMenuModel>(
            predicate: #Predicate { menu in
                menu.date >= todayStart && menu.date < todayEnd
            }
        )

        do {
            let menus = try modelContext.fetch(descriptor)
            todayMenu = menus.first
        } catch {
            print("Failed to fetch today's menu: \(error)")
        }
    }

    private func loadRecentWorkouts() async throws {
        guard let healthKitService = healthKitService else { return }

        let calendar = Calendar.current
        let now = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return }

        recentWorkouts = try await healthKitService.fetchRunningWorkouts(from: weekAgo, to: now)
    }

    @MainActor
    func markTodayMenuAsCompleted() async {
        guard let todayMenu = todayMenu else { return }

        todayMenu.markAsCompleted()

        do {
            try modelContext?.save()
            await loadWeeklyProgress()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
