import SwiftUI

/// Week calendar header view
struct WeekCalendarView: View {
    let dates: [Date]
    let menuForDate: (Date) -> TrainingMenuModel?
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(dates, id: \.self) { date in
                let menu = menuForDate(date)
                let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                let isToday = calendar.isDateInToday(date)

                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text("\(calendar.component(.day, from: date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .regular)

                    if let menu = menu {
                        Image(systemName: menu.type.icon)
                            .font(.caption)
                            .foregroundStyle(menu.isCompleted ? .green : .orange)
                    } else {
                        Image(systemName: "minus")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal)
    }
}
