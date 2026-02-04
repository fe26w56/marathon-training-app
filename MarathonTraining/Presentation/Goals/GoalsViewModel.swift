import Foundation
import SwiftData
import Observation

/// ViewModel for Goals screen
@Observable
final class GoalsViewModel {
    private var modelContext: ModelContext?

    var races: [RaceModel] = []
    var currentWeeklyGoal: WeeklyGoalModel?
    var longTermGoals: [LongTermGoalModel] = []
    var isLoading: Bool = false

    // Sheet states
    var showingAddRaceSheet: Bool = false
    var showingEditRaceSheet: Bool = false
    var selectedRace: RaceModel?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor
    func loadData() async {
        guard let modelContext = modelContext else { return }

        isLoading = true

        // Fetch races (future races first)
        let now = Date()
        let raceDescriptor = FetchDescriptor<RaceModel>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let allRaces = try modelContext.fetch(raceDescriptor)
            races = allRaces.filter { $0.date > now }
        } catch {
            print("Failed to fetch races: \(error)")
            races = []
        }

        // Fetch current weekly goal
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            isLoading = false
            return
        }
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            isLoading = false
            return
        }

        let goalDescriptor = FetchDescriptor<WeeklyGoalModel>(
            predicate: #Predicate { goal in
                goal.weekStartDate >= weekStart && goal.weekStartDate < weekEnd
            }
        )

        do {
            let goals = try modelContext.fetch(goalDescriptor)
            currentWeeklyGoal = goals.first
        } catch {
            print("Failed to fetch weekly goal: \(error)")
            currentWeeklyGoal = nil
        }

        // Fetch long term goals
        let longTermDescriptor = FetchDescriptor<LongTermGoalModel>(
            sortBy: [SortDescriptor(\.targetDate, order: .forward)]
        )

        do {
            longTermGoals = try modelContext.fetch(longTermDescriptor)
        } catch {
            print("Failed to fetch long term goals: \(error)")
            longTermGoals = []
        }

        isLoading = false
    }

    @MainActor
    func addRace(name: String, date: Date, distance: Double, targetTime: TimeInterval?, memo: String?) async {
        guard let modelContext = modelContext else { return }

        let race = RaceModel(
            name: name,
            date: date,
            distance: distance,
            targetTime: targetTime,
            memo: memo
        )

        modelContext.insert(race)

        do {
            try modelContext.save()
            await loadData()
        } catch {
            print("Failed to save race: \(error)")
        }

        showingAddRaceSheet = false
    }

    @MainActor
    func updateRace(_ race: RaceModel, name: String, date: Date, distance: Double, targetTime: TimeInterval?, memo: String?) async {
        race.name = name
        race.date = date
        race.distance = distance
        race.targetTime = targetTime
        race.memo = memo
        race.updatedAt = Date()

        do {
            try modelContext?.save()
            await loadData()
        } catch {
            print("Failed to update race: \(error)")
        }

        showingEditRaceSheet = false
        selectedRace = nil
    }

    @MainActor
    func deleteRace(_ race: RaceModel) async {
        guard let modelContext = modelContext else { return }

        modelContext.delete(race)

        do {
            try modelContext.save()
            await loadData()
        } catch {
            print("Failed to delete race: \(error)")
        }
    }

    @MainActor
    func toggleLongTermGoalAchievement(_ goal: LongTermGoalModel) async {
        if goal.isAchieved {
            goal.isAchieved = false
            goal.achievedAt = nil
        } else {
            goal.markAsAchieved()
        }

        do {
            try modelContext?.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}
