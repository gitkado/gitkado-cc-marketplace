# My Claude Code Plugin Marketplace

自分用に作成しているClaude Codeのプラグインを集約させるためのマーケットプレイスです。

## マーケットプレイスの追加

```bash
/plugin marketplace add /path/to/gitkado-cc-marketplace
```

## 含まれるプラグイン

### x-browser

X/Twitter browser automation skill

X/Twitter（twitter.com, x.com）のURLを自動検出してブラウザで開くスキルです。

**依存関係:**
- [agent-browser](https://github.com/anthropics/agent-browser) - ブラウザ自動化ツール

```bash
/plugin enable x-browser@gitkado-cc-marketplace
```

### ruby-lsp

Ruby language server for Claude Code

Ruby言語のLSPサポートを提供します。

**依存関係:**
- [Ruby](https://www.ruby-lang.org/) >= 3.0
- [ruby-lsp](https://github.com/Shopify/ruby-lsp) gem (`gem install ruby-lsp`)

```bash
/plugin enable ruby-lsp@gitkado-cc-marketplace
```

## プラグインの種類

Claude Codeでは以下のようなプラグインを利用できます：

- **スキル** - 特定のタスクに特化した自動化
- **LSPサーバー** - 言語サーバープロトコルによるコード補完・分析
- **MCPサーバー** - Model Context Protocolを使用した拡張機能
- **フック** - イベント駆動のカスタム処理

## 参考資料

### プラグイン関連（英語）
- [Create plugins](https://code.claude.com/docs/en/plugins) - プラグインの作成
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) - プラグインの発見とインストール
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) - プラグインリファレンス
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) - マーケットプレイスの作成と配布

### プラグイン関連（日本語）
- [プラグインを作成する](https://code.claude.com/docs/ja/plugins) - プラグインの作成
- [プラグインを発見してインストールする](https://code.claude.com/docs/ja/discover-plugins) - プラグインの発見とインストール
- [プラグインリファレンス](https://code.claude.com/docs/ja/plugins-reference) - 技術仕様
- [プラグインマーケットプレイス](https://code.claude.com/docs/ja/plugin-marketplaces) - マーケットプレイスの作成と配布

### その他の機能（日本語）
- [スラッシュコマンド](https://code.claude.com/docs/ja/slash-commands) - カスタムスラッシュコマンドの作成
- [エージェントスキル](https://code.claude.com/docs/ja/skills) - Claudeの機能を拡張するスキル
- [サブエージェント](https://code.claude.com/docs/ja/sub-agents) - 特化型エージェントの設定
- [フック](https://code.claude.com/docs/ja/hooks) - イベント駆動のカスタム処理
- [MCP](https://code.claude.com/docs/ja/mcp) - 外部ツール統合

## ライセンス

MIT License
