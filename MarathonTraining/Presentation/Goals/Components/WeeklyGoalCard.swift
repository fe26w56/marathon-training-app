import SwiftUI

/// Card showing weekly goal progress
struct WeeklyGoalCard: View {
    let goal: WeeklyGoalModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("週間目標")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let goal = goal {
                // Distance progress
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("走行距離")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.1f / %.0f km", goal.completedDistance, goal.targetDistance))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: goal.distanceAchievementRate)
                        .tint(.blue)
                }

                // Training days progress
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("トレーニング日数")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(goal.completedTrainingDays) / \(goal.targetTrainingDays) 日")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: goal.trainingDaysAchievementRate)
                        .tint(.green)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title)
                        .foregroundStyle(.secondary)

                    Text("週間目標が設定されていません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("メニュータブでテンプレートを適用してください")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
