import SwiftUI

/// Card showing long term goals
struct LongTermGoalCard: View {
    let goals: [LongTermGoalModel]
    let onToggleAchievement: (LongTermGoalModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundStyle(.purple)
                Text("長期目標")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if goals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.title)
                        .foregroundStyle(.secondary)

                    Text("長期目標が設定されていません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            } else {
                ForEach(goals) { goal in
                    LongTermGoalRow(goal: goal, onToggle: { onToggleAchievement(goal) })
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LongTermGoalRow: View {
    let goal: LongTermGoalModel
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: goal.isAchieved ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(goal.isAchieved ? .green : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(goal.isAchieved)

                if let daysRemaining = goal.daysRemaining, !goal.isAchieved {
                    Text("あと\(daysRemaining)日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if goal.isAchieved, let achievedAt = goal.achievedAt {
                    Text("達成: \(achievedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()
        }
    }
}
