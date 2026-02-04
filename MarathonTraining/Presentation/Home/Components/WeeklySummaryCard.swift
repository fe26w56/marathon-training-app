import SwiftUI

/// Card showing weekly training progress
struct WeeklySummaryCard: View {
    let currentDistance: Double
    let goalDistance: Double
    let achievementRate: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("今週のサマリー")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("走行距離")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f km / %.0f km", currentDistance, goalDistance))
                        .font(.headline)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * achievementRate, height: 12)
                    }
                }
                .frame(height: 12)

                HStack {
                    Spacer()
                    Text(String(format: "%.0f%%", achievementRate * 100))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(achievementRate >= 1.0 ? .green : .secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
