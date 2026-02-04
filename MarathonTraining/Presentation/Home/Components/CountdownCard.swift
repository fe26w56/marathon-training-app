import SwiftUI

/// Card showing countdown to next race
struct CountdownCard: View {
    let race: RaceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(.orange)
                Text("次回大会")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(race.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(race.date.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()
                VStack {
                    Text("あと")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(race.daysRemaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    Text("日")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

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
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
