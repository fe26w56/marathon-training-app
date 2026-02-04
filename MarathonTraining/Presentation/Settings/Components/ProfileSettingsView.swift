import SwiftUI

/// View for profile settings
struct ProfileSettingsView: View {
    @Binding var userName: String
    @Binding var targetPace: Double
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
                Text("プロフィール")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("名前")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("ランナー", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: userName) { _, _ in
                        onSave()
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("目標ペース")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(formatPace(targetPace))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Slider(
                    value: $targetPace,
                    in: 3.0...10.0,
                    step: 0.5
                )
                .onChange(of: targetPace) { _, _ in
                    onSave()
                }

                HStack {
                    Text("速い")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("ゆっくり")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatPace(_ pace: Double) -> String {
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d/km", minutes, seconds)
    }
}
