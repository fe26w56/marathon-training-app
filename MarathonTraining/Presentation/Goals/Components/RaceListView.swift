import SwiftUI

/// List view for races
struct RaceListView: View {
    let races: [RaceModel]
    let onSelect: (RaceModel) -> Void
    let onDelete: (RaceModel) -> Void

    var body: some View {
        if races.isEmpty {
            EmptyStateView(
                icon: "flag",
                title: "大会が登録されていません",
                message: "目標の大会を登録して\nトレーニングを始めましょう"
            )
        } else {
            LazyVStack(spacing: 12) {
                ForEach(races) { race in
                    RaceCard(race: race)
                        .onTapGesture {
                            onSelect(race)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(race)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

struct RaceCard: View {
    let race: RaceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(.orange)

                Text(race.name)
                    .font(.headline)

                Spacer()

                Text("\(race.daysRemaining)日")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }

            HStack {
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text(race.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }

                Spacer()

                // Distance
                HStack(spacing: 4) {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1fkm", race.distance))
                        .font(.subheadline)
                }
            }
            .foregroundStyle(.secondary)

            if let targetTime = race.formattedTargetTime {
                HStack {
                    Text("目標タイム")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(targetTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            if let memo = race.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
