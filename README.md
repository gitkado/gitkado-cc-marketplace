# My Claude Code Plugin Marketplace

自分用に作成しているClaude Codeのプラグインを集約させるためのマーケットプレイスです。

## マーケットプレイスの追加

githubのリポジトリを直接指定

```bash
/plugin marketplace add gitkado/gitkado-cc-marketplace
```

手元でpluginを微調整したい場合は、localにcloneしてパス指定する

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
/plugin install x-browser@gitkado-cc-marketplace
```

### ruby-lsp

Ruby language server for Claude Code

Ruby言語のLSPサポートを提供します。

**依存関係:**
- [Ruby](https://www.ruby-lang.org/) >= 3.0
- [ruby-lsp](https://github.com/Shopify/ruby-lsp) gem (`gem install ruby-lsp`)

```bash
/plugin install ruby-lsp@gitkado-cc-marketplace
```

### second-opinion

Get second opinions from codex (OpenAI CLI) for code review and design consultation

codex（OpenAI CLI）を使用して、コードレビューや設計相談のセカンドオピニオンを取得するスキルです。

**依存関係:**
- [codex](https://github.com/openai/codex) - OpenAI CLI (`npm install -g @openai/codex`)
- [tmux](https://github.com/tmux/tmux) - ターミナルマルチプレクサ (`brew install tmux`)
- [jq](https://jqlang.github.io/jq/) - JSONプロセッサ (`brew install jq`)

```bash
/plugin install second-opinion@gitkado-cc-marketplace
```

## プラグインの種類

Claude Codeでは以下のようなプラグインを利用できます：

- **スキル** - 特定のタスクに特化した自動化
- **LSPサーバー** - 言語サーバープロトコルによるコード補完・分析
- **MCPサーバー** - Model Context Protocolを使用した拡張機能
- **フック** - イベント駆動のカスタム処理

## 参考資料

### プラグイン関連
- [Create plugins](https://code.claude.com/docs/en/plugins) - プラグインの作成
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) - プラグインの発見とインストール
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) - プラグインリファレンス
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) - マーケットプレイスの作成と配布

### その他の機能
- [スラッシュコマンド](https://code.claude.com/docs/ja/slash-commands) - カスタムスラッシュコマンドの作成
- [エージェントスキル](https://code.claude.com/docs/ja/skills) - Claudeの機能を拡張するスキル
- [サブエージェント](https://code.claude.com/docs/ja/sub-agents) - 特化型エージェントの設定
- [フック](https://code.claude.com/docs/ja/hooks) - イベント駆動のカスタム処理
- [MCP](https://code.claude.com/docs/ja/mcp) - 外部ツール統合

## ライセンス

MIT License
