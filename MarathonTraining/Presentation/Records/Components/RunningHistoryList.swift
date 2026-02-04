import SwiftUI

/// List of running workout history
struct RunningHistoryList: View {
    let workouts: [RunningWorkout]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter
    }()

    var body: some View {
        if workouts.isEmpty {
            EmptyStateView(
                icon: "figure.run",
                title: "記録がありません",
                message: "ランニングを記録すると\nここに表示されます"
            )
        } else {
            LazyVStack(spacing: 8) {
                ForEach(workouts) { workout in
                    RunningWorkoutRow(workout: workout, dateFormatter: dateFormatter)
                }
            }
        }
    }
}

struct RunningWorkoutRow: View {
    let workout: RunningWorkout
    let dateFormatter: DateFormatter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: workout.startDate))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(workout.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                // Distance
                HStack(spacing: 4) {
                    Image(systemName: "figure.run")
                        .foregroundStyle(.blue)
                    Text(workout.formattedDistance)
                        .font(.headline)
                }

                Divider()
                    .frame(height: 20)

                // Pace
                HStack(spacing: 4) {
                    Image(systemName: "speedometer")
                        .foregroundStyle(.orange)
                    Text(workout.formattedPace)
                        .font(.subheadline)
                }

                if let hr = workout.formattedAverageHeartRate {
                    Divider()
                        .frame(height: 20)

                    // Heart rate
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text(hr)
                            .font(.subheadline)
                    }
                }

                Spacer()
            }

            if let calories = workout.formattedCalories {
                Text(calories)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
