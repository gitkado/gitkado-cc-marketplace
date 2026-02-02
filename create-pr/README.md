# create-pr Plugin

PR作成・更新スキル for Claude Code.

## Overview

コミット済みの変更をGitHubにpushし、PRを作成または更新します。

## Usage

```bash
/create-pr          # 新規PR作成
/create-pr update   # 既存PRの本文更新
```

## Features

- PR本文の自動生成（テンプレート準拠）
- フロントエンド変更時のスクリーンショットセクション自動生成
- 既存PRの本文更新
- ユーザー確認後にpush + PR作成
