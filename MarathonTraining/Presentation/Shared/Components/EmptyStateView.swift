import SwiftUI

/// Reusable empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
}

#Preview {
    EmptyStateView(
        icon: "flag",
        title: "大会が登録されていません",
        message: "目標の大会を登録して\nトレーニングを始めましょう",
        actionTitle: "大会を追加",
        action: {}
    )
}
