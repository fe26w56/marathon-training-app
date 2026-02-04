import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GoalsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    // Races section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("大会")
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel.showingAddRaceSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }

                        RaceListView(
                            races: viewModel.races,
                            onSelect: { race in
                                viewModel.selectedRace = race
                                viewModel.showingEditRaceSheet = true
                            },
                            onDelete: { race in
                                Task {
                                    await viewModel.deleteRace(race)
                                }
                            }
                        )
                    }

                    // Weekly goal section
                    WeeklyGoalCard(goal: viewModel.currentWeeklyGoal)

                    // Long term goals section
                    LongTermGoalCard(
                        goals: viewModel.longTermGoals,
                        onToggleAchievement: { goal in
                            Task {
                                await viewModel.toggleLongTermGoalAchievement(goal)
                            }
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadData()
        }
        .sheet(isPresented: $viewModel.showingAddRaceSheet) {
            RaceEditSheet(
                race: nil,
                onSave: { name, date, distance, targetTime, memo in
                    Task {
                        await viewModel.addRace(name: name, date: date, distance: distance, targetTime: targetTime, memo: memo)
                    }
                },
                onDelete: nil
            )
        }
        .sheet(isPresented: $viewModel.showingEditRaceSheet) {
            if let race = viewModel.selectedRace {
                RaceEditSheet(
                    race: race,
                    onSave: { name, date, distance, targetTime, memo in
                        Task {
                            await viewModel.updateRace(race, name: name, date: date, distance: distance, targetTime: targetTime, memo: memo)
                        }
                    },
                    onDelete: {
                        Task {
                            await viewModel.deleteRace(race)
                        }
                    }
                )
            }
        }
        .task {
            viewModel.configure(modelContext: modelContext)
            await viewModel.loadData()
        }
    }
}

#Preview {
    NavigationStack {
        GoalsView()
            .modelContainer(for: [RaceModel.self, WeeklyGoalModel.self, LongTermGoalModel.self])
    }
}
