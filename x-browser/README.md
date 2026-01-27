# x-browser Plugin

X/Twitter browser automation skill for Claude Code.

## Overview

X/Twitter（twitter.com, x.com）のURLを自動検出してブラウザで開くスキルプラグインです。
ツイートの内容確認、スクリーンショット取得、データ抽出に使用します。

## Prerequisites

agent-browserがインストールされている必要があります。

## Usage

マーケットプレイス経由で有効化：

```bash
/plugin enable x-browser@gitkado-cc-marketplace
```

## Features

- X/Twitter URLの自動検出
- ツイートの内容取得
- スクリーンショット撮影
- ページ構造の分析

## Supported URLs

- `twitter.com/*`
- `x.com/*`
- `mobile.twitter.com/*`
