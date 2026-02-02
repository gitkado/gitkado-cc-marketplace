# browser-dev Plugin

フロントエンド開発時のブラウザ検証スキル for Claude Code.

## Overview

agent-browser CLIを使って、UI確認・デバッグ・操作テストを行います。

## Prerequisites

- `agent-browser` CLIがインストール済みであること

## Usage

```bash
/browser-dev              # dev serverのページを確認
/browser-dev <url>        # 指定URLを確認
```

## Features

- UI表示確認・スクリーンショット取得
- コンソールエラーのデバッグ
- フォーム入力・ボタンクリック等の操作テスト
- 認証フローの自動処理
- レスポンシブ確認
