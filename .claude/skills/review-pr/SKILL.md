---
name: review-pr
description: PRのdiffを読んでレビューし、結果をPRコメントに投稿する
argument-hint: "[PR番号]"
user-invocable: true
allowed-tools: Bash(gh *), Read, Grep, Glob
---

# PR Review

PR #$0 をレビューし、結果をPRコメントに投稿します。

## レビュー手順

### 1. PR情報の取得
以下を並列で実行:
- `gh pr view $0 --json title,body,files,additions,deletions` でPR概要を取得
- `gh pr diff $0` で差分を取得

### 2. 関連コードの調査
diffで変更されたファイルに加え、以下を確認する:
- 変更ファイルがimportしている依存先の型・関数
- 既存の類似パターン（WaitTimeContext, ShowsPanel等）との一貫性
- `shared/firebase-types.ts` の関連する型定義
- `server/routers.ts` の関連するtRPCエンドポイント定義

### 3. レビュー基準

#### 必須チェック項目
1. **型安全性**: TypeScript strict mode準拠。any型の使用は不可
2. **既存パターンとの一貫性**: WaitTimesPanel / ShowsPanel / WaitTimeContext のコード構造を踏襲しているか
3. **エラーハンドリング**: API失敗時のフォールバック（空配列 or 前回キャッシュ）があるか
4. **セキュリティ**: XSS、インジェクション等のOWASP Top 10リスクがないか

#### コード品質
- 不要な抽象化やover-engineeringがないか
- コンポーネントの責務が明確か
- useMemo / useCallback の適切な使用

#### UI/UX（UIコンポーネントの場合）
- 日本語テキストが正しいか
- ローディング・エラー・空状態のハンドリングがあるか
- モバイルでのレイアウト崩れがないか（Tailwind CSS）

#### tRPC（APIルートの場合）
- エンドポイントの入出力型が正しいか
- staleTime / refetchInterval の設定が適切か

### 4. レビュー結果の出力

以下のフォーマットでレビュー結果を出力する:

```
## レビュー結果: PR #$0

### 問題（要修正）
- [ファイル名:行番号] 問題の説明 → 修正案

### 提案（任意）
- [ファイル名:行番号] 改善の説明

### 良い点
- 良かった点の列挙

### 総合判定
✅ LGTM / ⚠️ 軽微な修正後マージ可 / ❌ 要修正
```

### 5. PRコメントへの投稿
レビュー結果を `gh pr comment $0` でPRコメントに投稿する。
