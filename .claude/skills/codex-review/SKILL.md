---
name: codex-review
description: Codex CLIにPRレビューを依頼し、結果をPRコメントに投稿する。指摘があれば修正→再レビューをLGTMまでループする。
argument-hint: "[PR番号]"
user-invocable: true
allowed-tools: Bash(gh *), Bash(codex *), Bash(cat *), Bash(jq *), Bash(wc *), Read, Edit, Write, Glob, Grep
---

# Codex PR Review + Auto-Fix Loop

PR #$0 のレビューをCodex CLIに依頼し、指摘があれば修正→再レビューを **✅ LGTM が出るまで自動ループ** する。

## ループフロー

```
実装計画+issue読み取り → codex review → 結果読み取り → LGTM? → Yes → PRコメント投稿 → 完了
                                                          ↓ No
                                                  指摘を修正 → commit → push → codex review（ループ）
```

**最大ループ回数: 3回**（無限ループ防止）

## 実行手順

### Step 1: PR情報 + issue番号を取得
```bash
gh pr view $0 --json title,body,headRefName,baseRefName -q '"PR: " + .title + "\nBranch: " + .headRefName + " → " + .baseRefName + "\n" + .body'
```

PRのbodyから `Closes #XXX` のissue番号を抽出する。

### Step 2: issue内容を取得してレビュー用コンテキストを作成

issueの詳細仕様を取得:
```bash
gh issue view XXX --json title,body -q '"# Issue #XXX: " + .title + "\n\n" + .body' > /tmp/pr-$0-context.txt
```

実装計画の内容を追加:
```bash
cat docs/ai-magic-plan-implementation.md >> /tmp/pr-$0-context.txt
```

### Step 3: Codex review 実行

`codex exec review` を実行。`--json` モードで `agent_message` のみ抽出。
Codexは `AGENTS.md` を自動参照し、実装計画とissue内容を読んだ上でレビューする。

```bash
codex exec review --base develop --json "以下のissue仕様と実装計画に基づいてレビューしてください。AGENTS.md のレビュー基準に従うこと。\n\n$(cat /tmp/pr-$0-context.txt | head -500)" 2>/dev/null | jq -r 'select(.type == "item.completed") | select(.item.type == "agent_message") | .item.text' > /tmp/pr-$0-review.txt
```

もしコンテキストが大きすぎてエラーになる場合は、プロンプトなしで実行:
```bash
codex exec review --base develop --json 2>/dev/null | jq -r 'select(.type == "item.completed") | select(.item.type == "agent_message") | .item.text' > /tmp/pr-$0-review.txt
```

### Step 4: レビュー結果を読み取って判定

`/tmp/pr-$0-review.txt` を Read ツールで読み取り、以下を判定する:

- **問題指摘がゼロ** or **No issues** or **LGTM** → Step 6 へ（投稿して完了）
- **P1/P2 の指摘あり** or **要修正** → Step 5 へ（修正ループ）

### Step 5: 指摘を修正（ループ）

1. レビュー結果から指摘を抽出（ファイル名:行番号と問題内容）
2. 各指摘を修正する（Edit ツールでコード修正）
3. 修正をコミット + プッシュ:
   ```bash
   git add -A && git commit -m "fix: address codex review feedback (#$0)" && git push
   ```
4. **Step 3 に戻る**（再レビュー）

**ループは最大3回まで。** 3回で問題が残る場合、現状の結果をPRコメントに投稿して終了する。

### Step 6: PRコメントに投稿

レビュー結果を PR コメントに投稿する:
```bash
gh pr comment $0 --body "$(cat <<'COMMENT_EOF'
## 🤖 Codex Review

$(cat /tmp/pr-$0-review.txt)
COMMENT_EOF
)"
```

### Step 7: 結果サマリー

以下を出力する:
- 総合判定（✅ LGTM / ⚠️ 軽微な修正後マージ可 / ❌ 要修正）
- ループ回数
- 修正した内容のサマリー（ループした場合）

## 注意
- Codex CLIが未インストールの場合: `npm install -g @openai/codex`
- Codexは `AGENTS.md` を自動参照する（実装計画読み取り、issue整合性チェックの指示が含まれている）
- ループ中のcommitは `fix: address codex review feedback` で統一
