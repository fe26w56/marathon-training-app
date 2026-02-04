import SwiftUI
import SwiftData

struct WeeklyMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WeeklyMenuViewModel()
    @State private var selectedDate: Date?

    var body: some View {
        VStack(spacing: 0) {
            // Week navigation header
            HStack {
                Button(action: viewModel.previousWeek) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }

                Spacer()

                Text(viewModel.weekTitle)
                    .font(.headline)

                Spacer()

                Button(action: viewModel.nextWeek) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
            }
            .padding()

            // Week calendar
            WeekCalendarView(
                dates: viewModel.weekDates(),
                menuForDate: { viewModel.menu(for: $0) },
                selectedDate: $selectedDate
            )
            .padding(.bottom)

            Divider()

            // Daily menu list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.weekDates(), id: \.self) { date in
                        DayMenuCell(
                            date: date,
                            menu: viewModel.menu(for: date),
                            onToggleCompletion: {
                                if let menu = viewModel.menu(for: date) {
                                    Task {
                                        await viewModel.toggleMenuCompletion(menu)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showingTemplateSheet = true
                } label: {
                    Image(systemName: "square.grid.2x2")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingTemplateSheet) {
            MenuTemplateSheet { level in
                Task {
                    await viewModel.applyTemplate(level)
                }
            }
        }
        .task {
            viewModel.configure(modelContext: modelContext)
            await viewModel.loadWeekData()
        }
    }
}

#Preview {
    NavigationStack {
        WeeklyMenuView()
            .modelContainer(for: [TrainingMenuModel.self, WeeklyGoalModel.self])
    }
}
