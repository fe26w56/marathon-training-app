import SwiftUI

/// Row displaying HealthKit settings
struct HealthKitSettingsRow: View {
    let authState: HealthKitAuthState
    let onRequestAuth: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("ヘルスケア連携")
                    .font(.headline)
            }

            HStack {
                Image(systemName: authState.icon)
                    .foregroundStyle(authColor)

                Text("ステータス: \(authState.displayName)")
                    .font(.subheadline)

                Spacer()
            }

            if authState == .notDetermined {
                Button(action: onRequestAuth) {
                    Text("アクセスを許可する")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else if authState == .denied {
                Button(action: onOpenSettings) {
                    Text("設定で許可する")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Text("ランニングと睡眠のデータを取得するために、ヘルスケアへのアクセスが必要です。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var authColor: Color {
        switch authState {
        case .notDetermined: return .secondary
        case .authorized: return .green
        case .denied: return .red
        case .unavailable: return .orange
        }
    }
}
