# CLAUDE.md

## バージョニングルール

プラグインを更新する際は、以下の2箇所のバージョンを必ずインクリメントすること:

1. **`<plugin>/.claude-plugin/plugin.json`** の `version`
2. **`.claude-plugin/marketplace.json`** の該当プラグインの `version`

両者のバージョンは常に一致させること。

### semver 準拠

- **patch (0.0.x)**: バグ修正、ドキュメント修正、軽微な変更（基本はこれ）
- **minor (0.x.0)**: 新機能の追加、既存機能の拡張
- **major (x.0.0)**: 破壊的変更（スキルの削除、MCP サーバーの入れ替え等）
