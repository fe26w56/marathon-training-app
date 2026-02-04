import SwiftUI

/// Sheet for selecting training template
struct MenuTemplateSheet: View {
    let onSelectTemplate: (TrainingLevel) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(TrainingLevel.allCases, id: \.self) { level in
                        Button {
                            onSelectTemplate(level)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text("週\(level.trainingDays)日トレーニング")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("テンプレートを選択")
                } footer: {
                    Text("選択すると今週のメニューが上書きされます")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("週間メニュー設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MenuTemplateSheet { level in
        print("Selected: \(level)")
    }
}
