import SwiftUI

/// Sheet for adding/editing a race
struct RaceEditSheet: View {
    let race: RaceModel?
    let onSave: (String, Date, Double, TimeInterval?, String?) -> Void
    let onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var distance: Double = 42.195
    @State private var hasTargetTime: Bool = false
    @State private var targetHours: Int = 4
    @State private var targetMinutes: Int = 0
    @State private var memo: String = ""

    var isEditing: Bool {
        race != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("大会情報") {
                    TextField("大会名", text: $name)

                    DatePicker("開催日", selection: $date, displayedComponents: .date)

                    HStack {
                        Text("距離")
                        Spacer()
                        TextField("距離", value: $distance, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("km")
                    }
                }

                Section("目標タイム") {
                    Toggle("目標タイムを設定", isOn: $hasTargetTime)

                    if hasTargetTime {
                        HStack {
                            Picker("時間", selection: $targetHours) {
                                ForEach(0..<13) { hour in
                                    Text("\(hour)時間").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)

                            Picker("分", selection: $targetMinutes) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)分").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                        }
                        .frame(height: 120)
                    }
                }

                Section("メモ") {
                    TextField("メモ（任意）", text: $memo, axis: .vertical)
                        .lineLimit(3...5)
                }

                if isEditing, let onDelete = onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Text("大会を削除")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "大会を編集" : "大会を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let targetTime = hasTargetTime ? TimeInterval(targetHours * 3600 + targetMinutes * 60) : nil
                        onSave(name, date, distance, targetTime, memo.isEmpty ? nil : memo)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let race = race {
                    name = race.name
                    date = race.date
                    distance = race.distance
                    if let targetTime = race.targetTime {
                        hasTargetTime = true
                        targetHours = Int(targetTime) / 3600
                        targetMinutes = (Int(targetTime) % 3600) / 60
                    }
                    memo = race.memo ?? ""
                }
            }
        }
    }
}

#Preview {
    RaceEditSheet(
        race: nil,
        onSave: { _, _, _, _, _ in },
        onDelete: nil
    )
}
