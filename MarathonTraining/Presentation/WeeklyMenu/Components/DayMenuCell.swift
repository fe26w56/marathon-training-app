import SwiftUI

/// Cell displaying a single day's training menu
struct DayMenuCell: View {
    let date: Date
    let menu: TrainingMenuModel?
    let onToggleCompletion: () -> Void

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d (E)"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.medium)

                if calendar.isDateInToday(date) {
                    Text("今日")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Spacer()
            }

            if let menu = menu {
                HStack {
                    Image(systemName: menu.type.icon)
                        .font(.title2)
                        .foregroundStyle(menu.type == .rest ? Color.secondary : Color.orange)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(menu.type.displayName)
                            .font(.headline)

                        if menu.type != .rest {
                            HStack(spacing: 8) {
                                if let distance = menu.targetDistance {
                                    Text(String(format: "%.0fkm", distance))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let pace = menu.formattedTargetPace {
                                    Text(pace)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    Button(action: onToggleCompletion) {
                        Image(systemName: menu.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(menu.isCompleted ? .green : .secondary)
                    }
                    .disabled(menu.type == .rest)
                }
            } else {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)

                    Text("メニュー未設定")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
