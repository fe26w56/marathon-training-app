import SwiftUI

/// List of sleep record history
struct SleepHistoryList: View {
    let records: [SleepRecord]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter
    }()

    var body: some View {
        if records.isEmpty {
            EmptyStateView(
                icon: "bed.double",
                title: "記録がありません",
                message: "睡眠を記録すると\nここに表示されます"
            )
        } else {
            LazyVStack(spacing: 8) {
                ForEach(records) { record in
                    SleepRecordRow(record: record, dateFormatter: dateFormatter)
                }
            }
        }
    }
}

struct SleepRecordRow: View {
    let record: SleepRecord
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: record.date))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                // Sleep quality indicator
                HStack(spacing: 4) {
                    Image(systemName: qualityIcon)
                        .foregroundStyle(qualityColor)
                    Text(String(format: "%.0f点", record.sleepQualityScore))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                // Total sleep
                HStack(spacing: 4) {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundStyle(.purple)
                    Text(record.formattedTotalSleep)
                        .font(.headline)
                }

                Divider()
                    .frame(height: 20)

                // Bed time
                VStack(alignment: .leading, spacing: 2) {
                    Text("就寝")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(record.formattedBedTime)
                        .font(.subheadline)
                }

                // Wake time
                VStack(alignment: .leading, spacing: 2) {
                    Text("起床")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(record.formattedWakeTime)
                        .font(.subheadline)
                }

                Spacer()
            }

            // Sleep stages
            HStack(spacing: 12) {
                SleepStageIndicator(
                    label: "深い睡眠",
                    duration: record.deepSleepDuration,
                    color: .indigo
                )

                SleepStageIndicator(
                    label: "レム睡眠",
                    duration: record.remSleepDuration,
                    color: .cyan
                )

                SleepStageIndicator(
                    label: "コア睡眠",
                    duration: record.coreSleepDuration,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var qualityIcon: String {
        if record.sleepQualityScore >= 80 {
            return "star.fill"
        } else if record.sleepQualityScore >= 60 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    private var qualityColor: Color {
        if record.sleepQualityScore >= 80 {
            return .yellow
        } else if record.sleepQualityScore >= 60 {
            return .orange
        } else {
            return .secondary
        }
    }
}

struct SleepStageIndicator: View {
    let label: String
    let duration: TimeInterval
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(formattedDuration)
                    .font(.caption)
            }
        }
    }

    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
