import SwiftUI

/// View for notification settings
struct NotificationSettingsView: View {
    @Binding var isEnabled: Bool
    @Binding var reminderTime: Date
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.orange)
                Text("通知")
                    .font(.headline)
            }

            Toggle("トレーニングリマインダー", isOn: $isEnabled)
                .onChange(of: isEnabled) { _, _ in
                    onSave()
                }

            if isEnabled {
                HStack {
                    Text("リマインド時刻")
                        .font(.subheadline)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .onChange(of: reminderTime) { _, _ in
                        onSave()
                    }
                }
            }

            Text("毎日指定した時刻にトレーニングのリマインダーを受け取ります。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
