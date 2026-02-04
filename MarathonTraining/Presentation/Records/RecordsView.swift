import SwiftUI

struct RecordsView: View {
    @State private var viewModel = RecordsViewModel()
    @State private var healthKitService = HealthKitService()

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("記録タイプ", selection: $viewModel.selectedTab) {
                ForEach(RecordTab.allCases, id: \.self) { tab in
                    Text(tab.displayName).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            // Date range picker
            HStack {
                Text("期間:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("期間", selection: $viewModel.dateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(.menu)

                Spacer()
            }
            .padding(.horizontal)

            // Content
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 16) {
                        switch viewModel.selectedTab {
                        case .running:
                            runningContent
                        case .sleep:
                            sleepContent
                        }
                    }
                    .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .onChange(of: viewModel.dateRange) { _, newValue in
            viewModel.setDateRange(newValue)
        }
        .refreshable {
            await viewModel.loadData()
        }
        .task {
            viewModel.configure(healthKitService: healthKitService)
            await viewModel.loadData()
        }
    }

    private var runningContent: some View {
        VStack(spacing: 16) {
            // Stats summary
            HStack(spacing: 12) {
                StatsSummaryCard(
                    title: "総距離",
                    value: String(format: "%.1f km", viewModel.totalDistance),
                    subtitle: nil,
                    icon: "figure.run",
                    color: .blue
                )

                StatsSummaryCard(
                    title: "平均ペース",
                    value: formatPace(viewModel.averagePace),
                    subtitle: nil,
                    icon: "speedometer",
                    color: .orange
                )
            }

            // Chart
            WeeklyDistanceChart(data: viewModel.dailyDistances)

            // History list
            RunningHistoryList(workouts: viewModel.runningWorkouts)
        }
    }

    private var sleepContent: some View {
        VStack(spacing: 16) {
            // Stats summary
            HStack(spacing: 12) {
                StatsSummaryCard(
                    title: "平均睡眠時間",
                    value: formatDuration(viewModel.averageSleepDuration),
                    subtitle: nil,
                    icon: "moon.zzz.fill",
                    color: .purple
                )

                StatsSummaryCard(
                    title: "平均睡眠スコア",
                    value: String(format: "%.0f点", viewModel.averageSleepQuality),
                    subtitle: nil,
                    icon: "star.fill",
                    color: .yellow
                )
            }

            // History list
            SleepHistoryList(records: viewModel.sleepRecords)
        }
    }

    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 else { return "-" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d/km", minutes, seconds)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return String(format: "%d時間%02d分", hours, minutes)
    }
}

#Preview {
    NavigationStack {
        RecordsView()
    }
}
