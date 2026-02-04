# DLR Trip Planner - Codex Review Guide

## プロジェクト概要
ディズニーランド・リゾート（アナハイム）旅行プランナーアプリ。React + TypeScript + tRPC + Tailwind CSS。

## ★ レビュー前の必須準備

**レビューを始める前に、必ず以下の2つを読むこと:**

1. **実装計画**: `docs/ai-magic-plan-implementation.md` を読んで、実装の全体設計を把握する
   - 型定義（AiPlanInput, AiPlanOutput, AiPlanItem等）
   - アーキテクチャ（tRPC + GAS の3段階構成）
   - セキュリティ（HMAC署名、APIキー認証）
   - バリデーションルール（Park Hopper 13時チェック、メンテ中施設notes等）
   - データ圧縮（TSV形式）

2. **対象issue**: PRに紐づくissue番号を確認し、`gh issue view XX` でissueの詳細仕様を把握する
   - 完了条件を満たしているか
   - 実装計画のコード例と一致しているか

**実装計画に記載された設計判断に反する変更は「問題（要修正）」として指摘すること。**

## レビュー基準

### 必須チェック項目
1. **実装計画との整合性**: `docs/ai-magic-plan-implementation.md` の型定義・アーキテクチャ・バリデーションルールに準拠しているか
2. **issue完了条件**: issueに記載されたチェックリストを全て満たしているか
3. **型安全性**: TypeScript strict mode準拠。any型の使用は不可
4. **既存パターンとの一貫性**: WaitTimesPanel / ShowsPanel のコード構造を踏襲しているか
5. **エラーハンドリング**: API失敗時のフォールバック（空配列 or 前回キャッシュ）があるか
6. **セキュリティ**: XSS、インジェクション等のOWASP Top 10リスクがないか

### コード品質
- 不要な抽象化やover-engineeringがないか
- コンポーネントの責務が明確か
- useMemo / useCallback の適切な使用

### UI/UX
- 日本語テキストが正しいか
- ローディング・エラー・空状態のハンドリングがあるか
- モバイルでのレイアウト崩れがないか（Tailwind CSS）
- AI Magic Plan UI: モックのデザインを踏襲しているか

### tRPC
- エンドポイントの入出力型が正しいか
- staleTime / refetchInterval の設定が適切か

### AI Magic Plan 固有チェック
- HMAC署名の実装が正しいか（GAS側付与 → tRPC側検証）
- GAS APIキー認証が初期から有効か
- Park Hopper 13時チェックが全itemタイプ対象か（moveだけでなく）
- メンテ中施設のnotes自動付与があるか
- TSV圧縮形式が正しいか
- Multi Pass OFF時にisLightningLane=trueが0個か

## ファイル構成
```
server/
  wait-times.ts         — ThemeParks.wiki API クライアント
  routers.ts            — tRPC ルーター定義
  ai-plan/              — AI Magic Plan サーバーサイド（Phase 3）
    router.ts           — prepareData + save mutation
    collect-data.ts     — データ収集
    validate-output.ts  — 出力バリデーション（9ルール）
client/src/
  components/           — UIコンポーネント
  components/ai-plan/   — AI Magic Plan ウィザードUI（Phase 2）
  pages/                — ページコンポーネント
  hooks/                — カスタムhooks（useGeneratePlan等）
  lib/                  — ユーティリティ
shared/
  ai-plan-types.ts      — 型定義（Phase 1）
  ai-plan-constants.ts  — 定数（Phase 1）
  firebase-types.ts     — Firestore型定義
gas/ai-plan/            — GAS プロジェクト（Phase 3b）
docs/
  ai-magic-plan-implementation.md  — ★ 実装計画（必読）
  ai-magic-plan-requirements.md    — 要件定義
```

## レビュー出力フォーマット
レビュー結果は以下の形式で出力してください:

```
## レビュー結果: PR #XX

### 問題（要修正）
- [ファイル名:行番号] 問題の説明 → 修正案

### 提案（任意）
- [ファイル名:行番号] 改善の説明

### 良い点
- 良かった点の列挙

### 総合判定
✅ LGTM / ⚠️ 軽微な修正後マージ可 / ❌ 要修正
```
