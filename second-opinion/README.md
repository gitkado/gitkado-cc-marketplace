# second-opinion

codex（OpenAI CLI）を使用してセカンドオピニオンを得るための Claude Code プラグイン。

## 概要

このプラグインは、Claude Code から codex（OpenAI CLI）を呼び出し、第三者視点でのコードレビューや設計相談を行います。

## インストール

### 前提条件

以下のツールが必要です：

```bash
# codex (OpenAI CLI)
npm install -g @openai/codex

# tmux (ターミナルマルチプレクサ)
brew install tmux

# jq (JSONプロセッサ)
brew install jq
```

### プラグインのインストール

```bash
# marketplace リポジトリをクローン
git clone https://github.com/gitkado/gitkado-cc-marketplace.git

# Claude Code の設定で plugins に追加
# ~/.claude.json または .claude/settings.json
{
  "plugins": [
    "/path/to/gitkado-cc-marketplace/second-opinion"
  ]
}
```

## 使用方法

### クイックスタート

```bash
# tmux セッション内で実行
tmux new -s dev

# ワンショット実行（単発の質問）
/second-opinion exec "このコードの問題点を教えて"

# git diff のレビュー
/second-opinion review

# 設計相談
/second-opinion design auth-system
```

### 対話モード（コンテキスト維持）

```bash
# セッション開始
/second-opinion start

# 質問を送信（コンテキストが維持される）
/second-opinion ask "このアーキテクチャについて意見をください"
/second-opinion ask "さっきの点をもう少し詳しく"

# セッション終了
/second-opinion stop
```

## コマンド一覧

| コマンド | 説明 |
|----------|------|
| `/second-opinion start` | 対話セッションを開始 |
| `/second-opinion stop` | 対話セッションを終了 |
| `/second-opinion status` | セッション状態を確認 |
| `/second-opinion ask <prompt>` | セッション内で質問（コンテキスト維持） |
| `/second-opinion exec <prompt>` | ワンショット実行 |
| `/second-opinion review` | git diff のレビュー |
| `/second-opinion design <topic>` | 設計相談 |

## 特徴

- **重要度付きレビュー**: `[BLOCKER]`, `[WARNING]`, `[INFO]` で指摘を分類
- **コンテキスト自動付与**: `ai/specs/<feature>/` のドキュメントを自動参照
- **セッション継続**: `codex exec resume` による対話コンテキスト維持
- **安全性**: `--sandbox read-only` モードで実行

## ライセンス

MIT
