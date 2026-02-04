import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var healthKitService = HealthKitService()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if let race = viewModel.upcomingRace {
                    // Countdown Card
                    CountdownCard(race: race)
                        .padding(.horizontal)

                    // Weekly Summary Card
                    WeeklySummaryCard(
                        currentDistance: viewModel.thisWeekDistance,
                        goalDistance: viewModel.thisWeekGoalDistance,
                        achievementRate: viewModel.thisWeekAchievementRate
                    )
                    .padding(.horizontal)

                    // Today's Menu Card
                    TodayMenuCard(
                        menu: viewModel.todayMenu,
                        onComplete: {
                            Task {
                                await viewModel.markTodayMenuAsCompleted()
                            }
                        }
                    )
                    .padding(.horizontal)
                } else {
                    // Empty state when no race registered
                    EmptyStateView(
                        icon: "flag",
                        title: "大会が登録されていません",
                        message: "目標の大会を登録して\nトレーニングを始めましょう",
                        actionTitle: "目標タブへ",
                        action: nil
                    )
                    .padding(.top, 40)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadData()
        }
        .task {
            viewModel.configure(modelContext: modelContext, healthKitService: healthKitService)
            await viewModel.loadData()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [RaceModel.self, TrainingMenuModel.self, WeeklyGoalModel.self])
}
