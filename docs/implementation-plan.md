# マラソントレーニング管理アプリ 実装計画

## 概要
iOS 17+ / SwiftUI / HealthKit / SwiftData を使用したマラソントレーニング管理アプリ

**リポジトリ**: https://github.com/fe26w56/marathon-training-app

---

## アーキテクチャ

**Clean Architecture + MVVM** を採用
- `@Observable` + `@Query` パターン（SwiftData統合）
- HealthKit は `async/await` で実装

---

## ディレクトリ構造

```
MarathonTraining/
├── MarathonTrainingApp.swift
├── App/
│   ├── AppContainer.swift
│   └── ContentView.swift
├── Domain/
│   ├── Entities/
│   │   ├── RunningWorkout.swift
│   │   └── SleepRecord.swift
│   └── UseCases/
├── Data/
│   ├── Models/
│   │   ├── RaceModel.swift
│   │   ├── TrainingMenuModel.swift
│   │   ├── WeeklyGoalModel.swift
│   │   └── LongTermGoalModel.swift
│   ├── Repositories/
│   └── Services/
│       └── HealthKit/
│           ├── HealthKitService.swift
│           └── HealthKitAuthManager.swift
├── Presentation/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   │       ├── CountdownCard.swift
│   │       ├── WeeklySummaryCard.swift
│   │       └── TodayMenuCard.swift
│   ├── WeeklyMenu/
│   │   ├── WeeklyMenuView.swift
│   │   ├── WeeklyMenuViewModel.swift
│   │   └── Components/
│   │       ├── WeekCalendarView.swift
│   │       ├── DayMenuCell.swift
│   │       └── MenuTemplateSheet.swift
│   ├── Records/
│   │   ├── RecordsView.swift
│   │   ├── RecordsViewModel.swift
│   │   └── Components/
│   │       ├── RunningHistoryList.swift
│   │       ├── SleepHistoryList.swift
│   │       └── StatsChartView.swift
│   ├── Goals/
│   │   ├── GoalsView.swift
│   │   ├── GoalsViewModel.swift
│   │   └── Components/
│   │       ├── RaceListView.swift
│   │       ├── RaceEditSheet.swift
│   │       ├── WeeklyGoalCard.swift
│   │       └── ProgressChartView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── SettingsViewModel.swift
│   │   └── Components/
│   │       ├── HealthKitSettingsRow.swift
│   │       ├── NotificationSettingsView.swift
│   │       └── ProfileSettingsView.swift
│   └── Shared/
│       ├── Components/
│       │   ├── ProgressRing.swift
│       │   ├── EmptyStateView.swift
│       │   └── LoadingView.swift
│       └── Extensions/
│           ├── Date+Extensions.swift
│           ├── Double+Formatting.swift
│           └── Color+Theme.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

---

## 実装フェーズ

### Phase 1: 基盤構築 (Issue #1)

**タスク:**
1. Xcodeプロジェクト作成（SwiftUI + SwiftData）
2. iOS 17.0 minimum deployment target 設定
3. HealthKit Capability 追加
4. Info.plist に使用理由記載
5. ディレクトリ構造作成

**Info.plist 設定:**
```xml
<key>NSHealthShareUsageDescription</key>
<string>トレーニング記録と睡眠データを表示するために、ヘルスケアデータへのアクセスが必要です。</string>
```

---

### Phase 2: データモデル (Issue #2)

SwiftData `@Model` で以下を実装：

| モデル | 主要プロパティ | 関係性 |
|--------|--------------|--------|
| RaceModel | id, name, date, distance, targetTime, memo | → TrainingMenuModel (1:N) |
| TrainingMenuModel | id, date, type, targetDistance, isCompleted | → RaceModel, WeeklyGoalModel |
| WeeklyGoalModel | id, weekStartDate, targetDistance, targetTrainingDays | → TrainingMenuModel (1:N) |
| LongTermGoalModel | id, type, targetDate, isAchieved | - |

**TrainingType enum:**
- easy (イージーラン)
- tempo (テンポ走)
- interval (インターバル)
- longRun (ロング走)
- recovery (リカバリー)
- rest (休息)
- crossTraining (クロストレーニング)

**GoalType enum:**
- finishMarathon (フルマラソン完走)
- sub5, sub4, sub3_5, sub3
- personalBest (自己ベスト更新)
- custom (カスタム)

---

### Phase 3: HealthKit連携 (Issue #3, #4)

**HealthKitService 主要メソッド:**
```swift
// 認証
func requestAuthorization() async throws

// ランニングデータ取得 (Issue #3)
func fetchRunningWorkouts(from: Date, to: Date) async throws -> [RunningWorkout]
func fetchHeartRate(for workout: HKWorkout) async throws -> (average: Double?, max: Double?)

// 睡眠データ取得 (Issue #4)
func fetchSleepData(from: Date, to: Date) async throws -> [SleepRecord]
```

**取得データ:**

| カテゴリ | データ項目 |
|---------|----------|
| ランニング | 距離, 時間, ペース, カロリー, 平均心拍数, 最大心拍数 |
| 睡眠 | 就寝時刻, 起床時刻, 総睡眠時間, 深い睡眠, レム睡眠, 睡眠品質スコア |

**ドメインエンティティ:**
- `RunningWorkout`: HealthKitから取得したランニングデータ
- `SleepRecord`: HealthKitから取得した睡眠データ
- `SleepSegment`: 睡眠ステージごとのセグメント

---

### Phase 4: タブナビゲーション (Issue #10)

```swift
enum Tab: Int, CaseIterable {
    case home        // house.fill
    case weeklyMenu  // calendar
    case records     // chart.line.uptrend.xyaxis
    case goals       // flag.fill
    case settings    // gearshape.fill
}

TabView(selection: $selectedTab) {
    HomeView()
    WeeklyMenuView()
    RecordsView()
    GoalsView()
    SettingsView()
}
```

---

### Phase 5: ホーム画面 (Issue #5)

**コンポーネント:**
- **CountdownCard**: 次回大会名、開催日、残り日数
- **WeeklySummaryCard**: 今週の走行距離、達成率（プログレスバー）
- **TodayMenuCard**: 本日のトレーニング内容、完了ボタン

**HomeViewModel:**
- 直近の大会取得
- 今週の達成状況計算
- 本日のメニュー取得
- 直近7日間のワークアウト取得

---

### Phase 6: 週間メニュー (Issue #6)

**機能:**
- 週間カレンダービュー（月〜日）
- テンプレート選択（初心者/中級者/上級者）
- メニューカスタマイズ（距離、種類変更）
- 完了チェック機能
- 休息日設定

**テンプレート例（初心者）:**
| 曜日 | 種類 | 距離 |
|-----|------|-----|
| 月 | イージーラン | 5km |
| 火 | 休息 | - |
| 水 | イージーラン | 5km |
| 木 | 休息 | - |
| 金 | 軽いジョグ | 3km |
| 土 | ロング走 | 10km |
| 日 | 完全休養 | - |

---

### Phase 7: 記録画面 (Issue #7)

**タブ構成:**
1. ランニング履歴
2. 睡眠履歴

**機能:**
- 一覧表示（日付降順）
- 詳細表示（タップで展開）
- 期間フィルター
- Charts frameworkでグラフ表示
  - 週間走行距離棒グラフ
  - 睡眠時間推移折れ線グラフ

---

### Phase 8: 目標管理 (Issue #8)

**セクション構成:**
1. **大会一覧**: 登録した大会（カウントダウン付き）
2. **週間目標**: 走行距離、トレーニング日数
3. **長期目標**: サブ4達成など

**機能:**
- 大会の追加/編集/削除
- 目標タイム設定
- 進捗グラフ表示
- 達成時の通知/お祝い表示

---

### Phase 9: 設定画面 (Issue #9)

**項目:**
- ヘルスケア連携状態（許可/拒否/未設定）
- 再認証ボタン
- 通知設定（トレーニングリマインダー）
- プロフィール（名前、目標ペース）
- アプリバージョン

---

### Phase 10: 仕上げ

**共通コンポーネント:**
- ProgressRing（円形プログレス）
- EmptyStateView（データなし時の表示）
- LoadingView（読み込み中）

**Extensions:**
- Date+Extensions（週の開始日取得など）
- Double+Formatting（距離、ペースのフォーマット）
- Color+Theme（テーマカラー定義）

**対応:**
- ダークモード
- アクセシビリティ

---

## 依存関係

```
Phase 1 (基盤構築)
    ↓
Phase 2 (データモデル)
    ↓
Phase 3 (HealthKit連携)
    ↓
Phase 4 (タブナビゲーション)
    ↓
┌───────────────────────────────────┐
│  Phase 5-9 (各画面実装) 並行可能  │
└───────────────────────────────────┘
    ↓
Phase 10 (仕上げ)
```

---

## 技術スタック

| 技術 | 用途 |
|-----|------|
| iOS 17.0+ | 最小対応バージョン |
| Swift | 開発言語 |
| SwiftUI | UIフレームワーク |
| SwiftData | データ永続化 |
| HealthKit | ヘルスケアデータ取得 |
| Charts | グラフ表示 |

---

## 検証方法

1. **HealthKit**: シミュレータでHealthKitデータを追加して動作確認
2. **SwiftData**: アプリ再起動後のデータ永続化確認
3. **UI**: 各画面の表示・遷移テスト
4. **ダークモード**: 外観切り替えで表示確認
