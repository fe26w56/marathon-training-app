import SwiftUI

/// Card showing today's training menu
struct TodayMenuCard: View {
    let menu: TrainingMenuModel?
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
                Text("本日のメニュー")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let menu = menu {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: menu.type.icon)
                            .font(.title2)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(menu.type.displayName)
                                .font(.headline)

                            if let distance = menu.targetDistance {
                                Text(String(format: "%.1f km", distance))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let pace = menu.formattedTargetPace {
                                Text("ペース: \(pace)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        if menu.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                        }
                    }

                    if let description = menu.menuDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if !menu.isCompleted {
                        Button(action: onComplete) {
                            Text("完了する")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 4)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("本日のメニューはありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("週間メニューで設定してください")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
