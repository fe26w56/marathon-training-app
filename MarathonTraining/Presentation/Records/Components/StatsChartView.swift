import SwiftUI
import Charts

/// Chart view for weekly distance stats
struct WeeklyDistanceChart: View {
    let data: [(date: Date, distance: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("走行距離")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if data.isEmpty {
                Text("データがありません")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart(data, id: \.date) { item in
                    BarMark(
                        x: .value("日付", item.date, unit: .day),
                        y: .value("距離", item.distance)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(dayLabel(for: date))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let distance = value.as(Double.self) {
                                Text(String(format: "%.0f", distance))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

/// Summary stats card
struct StatsSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
