# マラソントレーニング管理アプリ - 開発ルール

## ブランチ戦略

```
main ← develop ← feature/issue-XX-description
```

- **main**: 本番デプロイ用。developからのマージのみ
- **develop**: 開発統合ブランチ。全feature PRのマージ先
- **feature/issue-XX-***: 各issue用の作業ブランチ。developから切る

## 開発フロー

### 0. 実装前の準備（★ 必須）
**issueに着手する前に、必ず以下を読んで内容を把握すること:**
1. `docs/implementation-plan.md` — 実装計画の全体像（アーキテクチャ、データモデル、コード例）
2. 対象issueの本文 — `gh issue view XX` で詳細を確認
3. 依存issueが完了済みか確認

これにより、実装計画の設計意図（Clean Architecture、SwiftData、HealthKit連携等）を理解した上でコードを書く。

### 1. ブランチ作成
```bash
git fetch origin main develop
# ★ mainの差分をdevelopに自動マージ（ズレ防止）
git checkout develop
git pull origin develop
git merge origin/main --no-edit  # mainに差分があればマージ、なければno-op
git push origin develop
git checkout -b feature/issue-XX-description
```

### 2. 実装 → コミット → PR作成
- issue番号を参照してコミットメッセージを書く（例: `feat: add HealthKit service (#3)`）
- PRは **develop** ブランチに対して作成する
- PR本文にはissue番号をリンク（`Closes #3`）

### 3. Codex CLIでレビュー（自動）
**PR作成後、確認なしで即座に `/codex-review PR番号` を実行すること。**ユーザーに「レビューしますか？」と聞かない。

これにより:
1. Codex CLIが実装計画 + issue内容を読み取ってからレビュー
2. レビュー結果を `gh pr comment` でPRコメントに投稿
3. 指摘があれば自動修正 → 再レビュー（最大3回ループ）

### 4. レビュー指摘の修正
- Codexの指摘をもとに**同じブランチで修正コミット**を追加
- push後、**必ず再度Codexレビューを実行**する
- **✅ LGTM が出るまでマージしない**（⚠️ や ❌ の状態でマージは禁止）
- LGTM → マージの順序を厳守

### 5. マージ → issueクローズ → 次のissueへ
```bash
gh pr merge PR番号 --merge
gh issue close XX           # ★ マージ完了後、対応issueを必ずクローズする
git checkout develop
git pull origin develop
# 次のissueのブランチを作成
git checkout -b feature/issue-YY-description
```

### 6. develop → main のマージ（リリース時）
一連のissueが完了したらdevelopをmainにマージ:
```bash
gh pr create --base main --head develop --title "release: Marathon Training App v1.0"
```

## issue実行順序

| 順 | Issue | 内容 | 依存 |
|----|-------|------|------|
| 1 | #1 | プロジェクトセットアップ（Xcode, HealthKit Capability, ディレクトリ構造） | なし |
| 2 | #2 | データモデル設計・実装（SwiftData: Race, TrainingMenu, Goal） | #1 |
| 3 | #3 | HealthKit連携 - ランニングデータ取得 | #1 |
| 4 | #4 | HealthKit連携 - 睡眠データ取得 | #1, #3 |
| 5 | #10 | タブナビゲーション実装（Tab enum, ContentView） | #1 |
| 6 | #5 | ホーム画面実装（CountdownCard, WeeklySummary, TodayMenu） | #2, #3, #4, #10 |
| 7 | #6 | 週間メニュー画面実装（WeekCalendar, テンプレート機能） | #2, #10 |
| 8 | #7 | 記録画面実装（ランニング履歴, 睡眠履歴, Charts） | #3, #4, #10 |
| 9 | #8 | 目標管理画面実装（大会一覧, 週間目標, 長期目標） | #2, #10 |
| 10 | #9 | 設定画面実装（HealthKit状態, 通知, プロフィール） | #3, #10 |

詳細: [docs/implementation-plan.md](docs/implementation-plan.md)

## コーディング規約

- 言語: Swift
- フレームワーク: SwiftUI, SwiftData, HealthKit, Charts
- アーキテクチャ: Clean Architecture + MVVM
- Minimum deployment target: iOS 17.0
- ViewModelは `@Observable` マクロを使用
- HealthKitは `async/await` で実装
- 日本語UIテキスト、コード・コメントは英語
- 既存コンポーネントのパターンを踏襲する

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
│           └── HealthKitService.swift
├── Presentation/
│   ├── Home/
│   ├── WeeklyMenu/
│   ├── Records/
│   ├── Goals/
│   ├── Settings/
│   └── Shared/
└── Resources/
```

## 技術スタック

| 技術 | 用途 |
|-----|------|
| iOS 17.0+ | 最小対応バージョン |
| Swift | 開発言語 |
| SwiftUI | UIフレームワーク |
| SwiftData | データ永続化 |
| HealthKit | ヘルスケアデータ取得 |
| Charts | グラフ表示 |
