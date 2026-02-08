#!/bin/bash
# second-opinion start - codexセッションを開始
# codex exec --json で新規セッションを開始し、セッションIDを保存

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# 前提条件チェック
check_tmux_installed || exit 1
check_tmux_session || exit 1
check_jq_installed || exit 1
build_codex_args || exit 1
get_codex_command || exit 1
check_codex_version_min || exit 1

# 既存セッションの確認
EXISTING_SESSION=$(get_session_id)
if [[ -n "$EXISTING_SESSION" ]]; then
  echo "既にcodexセッションが存在します: $EXISTING_SESSION"
  echo "停止するには: /second-opinion stop"
  exit 0
fi

# 一時ファイル作成
OUTPUT_FILE=$(create_temp_file "so-start-jsonl")
ERROR_FILE=$(create_temp_file "so-start-stderr")
setup_cleanup_trap "$OUTPUT_FILE" "$ERROR_FILE"

echo "新規セッションを開始中..."

# codex exec --json でセッション開始
if ! "${CODEX_BASE_CMD[@]}" exec "${CODEX_EXEC_ARGS[@]}" --json "セッション開始。以降の質問に回答してください。" > "$OUTPUT_FILE" 2> "$ERROR_FILE"; then
  echo "Error: セッション開始に失敗しました" >&2
  echo "--- 詳細 ---"
  if [[ -s "$ERROR_FILE" ]]; then
    cat "$ERROR_FILE"
  fi
  if [[ -s "$OUTPUT_FILE" ]]; then
    cat "$OUTPUT_FILE"
  fi
  exit 1
fi

# セッションIDを抽出
SESSION_ID=$(extract_session_id "$OUTPUT_FILE")
if [[ -z "$SESSION_ID" ]]; then
  echo "Error: セッションIDを取得できませんでした" >&2
  echo "--- JSONL出力 ---"
  cat "$OUTPUT_FILE"
  if [[ -s "$ERROR_FILE" ]]; then
    echo "--- stderr ---"
    cat "$ERROR_FILE"
  fi
  exit 1
fi

# セッションIDを保存
save_session_id "$SESSION_ID"

echo "codexセッションを開始しました"
echo "Session ID: $SESSION_ID"
echo ""
echo "使用方法:"
echo "  /second-opinion ask <prompt>  - 質問を送信"
echo "  /second-opinion status        - 状態確認"
echo "  /second-opinion stop          - セッション終了"
