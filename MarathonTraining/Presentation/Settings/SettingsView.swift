import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var healthKitService = HealthKitService()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // HealthKit settings
                HealthKitSettingsRow(
                    authState: viewModel.healthKitAuthState,
                    onRequestAuth: {
                        Task {
                            await viewModel.requestHealthKitAuthorization()
                        }
                    },
                    onOpenSettings: viewModel.openHealthSettings
                )

                // Notification settings
                NotificationSettingsView(
                    isEnabled: $viewModel.isNotificationEnabled,
                    reminderTime: $viewModel.reminderTime,
                    onSave: viewModel.saveNotificationSettings
                )

                // Profile settings
                ProfileSettingsView(
                    userName: $viewModel.userName,
                    targetPace: $viewModel.targetPace,
                    onSave: viewModel.saveProfile
                )

                // App info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.secondary)
                        Text("アプリ情報")
                            .font(.headline)
                    }

                    HStack {
                        Text("バージョン")
                            .font(.subheadline)
                        Spacer()
                        Text(viewModel.appVersion)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.configure(healthKitService: healthKitService)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
