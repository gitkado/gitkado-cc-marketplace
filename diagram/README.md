# diagram

draw.io と Excalidraw の MCP サーバーを活用したダイアグラム作成 Claude Code プラグイン。

## 概要

このプラグインは、2つのダイアグラム作成ツールをスキルとして提供します：

- **drawio**: draw.io MCP サーバーを使用した XML / CSV / Mermaid ベースのダイアグラム作成
- **excalidraw**: Excalidraw MCP サーバーを使用した手描き風ダイアグラムの作成・編集

## インストール

### プラグインのインストール

プラグインをインストールすると、MCP サーバー（drawio / excalidraw）も自動的に設定されます。

```bash
# marketplace リポジトリをクローン
git clone https://github.com/gitkado/gitkado-cc-marketplace.git

# Claude Code の設定で plugins に追加
# ~/.claude.json または .claude/settings.json
{
  "plugins": [
    "/path/to/gitkado-cc-marketplace/diagram"
  ]
}
```

## 使用方法

```bash
# draw.io でダイアグラムを作成
/drawio

# Excalidraw でダイアグラムを作成
/excalidraw
```

## スキル比較

| 特徴 | drawio | excalidraw |
|------|--------|------------|
| 入力形式 | XML, CSV, Mermaid | ツールAPI |
| 出力先 | ブラウザ（app.diagrams.net） | Excalidraw キャンバス |
| スタイル | フォーマル | 手描き風 |
| 複雑なダイアグラム | XML で細かく制御 | batch_create_elements で一括作成 |
| テキストベース入力 | Mermaid 記法対応 | convert_mermaid で変換 |
| 適したユースケース | ドキュメント向けの正式な図 | ホワイトボード風のラフな図 |

## ライセンス

MIT
