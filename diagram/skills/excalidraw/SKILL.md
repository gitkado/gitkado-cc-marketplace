---
name: excalidraw
description: Excalidraw MCP サーバーを使用してダイアグラムを作成・編集する
metadata:
  mcp-server: excalidraw
---

あなたは Excalidraw MCP サーバーを使ってダイアグラムを作成・編集するスキルを持っています。要素の作成、配置、スタイリングを行い、手描き風のダイアグラムを生成してください。

## 前提条件

Excalidraw MCP サーバーがプラグインにより自動設定済みであること。

## 利用可能なツール

### 要素管理

| ツール | 説明 |
|--------|------|
| `create_element` | 新しいダイアグラム要素を作成 |
| `update_element` | 既存要素のプロパティを変更 |
| `remove_element` | キャンバスから要素を削除 |
| `search_elements` | 要素を検索・取得 |
| `batch_create_elements` | 複数要素を一括作成 |

### 高度な操作

| ツール | 説明 |
|--------|------|
| `align_elements` | 要素を整列 |
| `distribute_elements` | 要素を均等配置 |
| `group_elements` | 複数要素をグループ化 |
| `ungroup_elements` | グループを解除 |
| `convert_mermaid` | Mermaid記法をExcalidraw形式に変換 |

## 要素タイプ

| タイプ | 説明 | 主な用途 |
|--------|------|----------|
| `rectangle` | 四角形 | ボックス、コンテナ |
| `diamond` | ひし形 | 条件分岐、判定 |
| `ellipse` | 楕円 | 開始/終了、状態 |
| `text` | テキスト | ラベル、説明 |
| `line` | 線 | 接続線、矢印 |
| `arrow` | 矢印 | フロー方向の表示 |
| `freedraw` | フリーハンド | 手書き風の注釈 |

## 要素プロパティ

### 位置・サイズ

| プロパティ | 型 | 説明 |
|------------|------|------|
| `x` | number | X座標 |
| `y` | number | Y座標 |
| `width` | number | 幅 |
| `height` | number | 高さ |
| `points` | array | 線やパスの制御点（line/arrow用） |

### スタイル

| プロパティ | 型 | 説明 |
|------------|------|------|
| `backgroundColor` | string | 背景色（例: `#e3f2fd`） |
| `strokeColor` | string | 線の色（例: `#1976d2`） |
| `strokeWidth` | number | 線の太さ |
| `roughness` | number | 手描き感の度合い（0: なめらか, 1: 通常, 2: 荒い） |
| `opacity` | number | 不透明度（0-100） |

### テキスト

| プロパティ | 型 | 説明 |
|------------|------|------|
| `text` | string | テキスト内容 |
| `fontSize` | number | フォントサイズ |
| `fontFamily` | number | フォントファミリー（1: Hand-drawn, 2: Normal, 3: Code） |

### その他

| プロパティ | 型 | 説明 |
|------------|------|------|
| `locked` | boolean | ロック状態 |

## 使い方ガイド

### 基本: 単一要素の作成

```json
{
  "tool": "create_element",
  "params": {
    "type": "rectangle",
    "x": 100,
    "y": 100,
    "width": 200,
    "height": 100,
    "backgroundColor": "#e3f2fd",
    "strokeColor": "#1976d2",
    "text": "Hello World"
  }
}
```

### 複数要素の一括作成

`batch_create_elements` を使って複数の要素を一度に作成できます。フローチャートやアーキテクチャ図など、多数の要素を配置する場合に効率的です。

```json
{
  "tool": "batch_create_elements",
  "params": {
    "elements": [
      {
        "type": "rectangle",
        "x": 100,
        "y": 100,
        "width": 200,
        "height": 80,
        "text": "Step 1"
      },
      {
        "type": "rectangle",
        "x": 100,
        "y": 250,
        "width": 200,
        "height": 80,
        "text": "Step 2"
      },
      {
        "type": "arrow",
        "x": 200,
        "y": 180,
        "width": 0,
        "height": 70,
        "points": [[0, 0], [0, 70]]
      }
    ]
  }
}
```

### 要素の整列

```json
{
  "tool": "align_elements",
  "params": {
    "elementIds": ["id1", "id2", "id3"],
    "alignment": "center"
  }
}
```

### Mermaid記法からの変換

テキストベースのダイアグラム定義から Excalidraw 形式に変換できます。

```json
{
  "tool": "convert_mermaid",
  "params": {
    "mermaid": "graph TD\n    A[Start] --> B{Decision}\n    B -->|Yes| C[OK]\n    B -->|No| D[NG]"
  }
}
```

## ワークフロー

1. ユーザーの要件を確認する
2. ダイアグラムの構造を設計する（要素の種類、配置、接続）
3. `batch_create_elements` で要素をまとめて作成する
4. 必要に応じて `align_elements` / `distribute_elements` で配置を調整する
5. `group_elements` で関連要素をグループ化する

## 重要な制約

- **ファイル編集禁止**: このスキルではローカルファイルの作成・編集を行わないこと。ダイアグラムは Excalidraw のキャンバスで表示される
- **git操作禁止**: このスキルの実行中に git コマンドを実行しないこと
- **座標系**: 左上が原点（0, 0）、右方向がX正、下方向がY正
- **要素の重複防止**: 同じ位置に同じ要素を複数作成しないよう注意する

## Tips

- 複数要素を配置する場合は `batch_create_elements` を優先する（個別の `create_element` より効率的）
- 手描き風の見た目を出したい場合は `roughness: 2` を設定する
- きれいな図を作りたい場合は `roughness: 0` を設定する
- 矢印の始点・終点は `points` プロパティで制御する
- テキスト要素は `fontFamily: 3`（Code）にするとモノスペースフォントになる
