#!/bin/bash
# second-opinion 共通ライブラリ
# 各スクリプトから source して使用

# 厳格モード（呼び出し元で設定されていない場合に備え）
set -euo pipefail

# --------------------------------------------------------------------------
# 定数
# --------------------------------------------------------------------------

# プラットフォーム互換のMD5ハッシュ関数
_hash_string() {
  local input="$1"
  if command -v md5sum &>/dev/null; then
    echo -n "$input" | md5sum | cut -c1-8
  else
    echo -n "$input" | md5 | cut -c1-8
  fi
}

# プロジェクト固有のtmux user optionキーを生成
_get_tmux_option_key() {
  local project_hash
  # $(pwd -P) を使用してシンボリックリンクを解決した実パスを取得
  project_hash=$(_hash_string "$(pwd -P)")
  echo "@second_opinion_pane_${project_hash}"
}

# tmux user optionキー（セッション共有）
CODEX_PANE_OPTION="$(_get_tmux_option_key)"

# 後方互換のためファイルパスも保持（フォールバック用）
_get_pane_file() {
  local project_hash
  # $(pwd -P) を使用してシンボリックリンクを解決した実パスを取得
  project_hash=$(_hash_string "$(pwd -P)")
  # $TMPDIR を使用（未設定の場合は /tmp にフォールバック）
  local tmp_base="${TMPDIR:-/tmp}"
  # 末尾のスラッシュを除去
  tmp_base="${tmp_base%/}"
  echo "${tmp_base}/second-opinion-pane-${project_hash}"
}

CODEX_PANE_FILE="$(_get_pane_file)"

# codex モデル設定
# 環境変数 CODEX_MODEL で指定可能（未指定時は config.toml のデフォルトを使用）
# 例: CODEX_MODEL="gpt-5.3-codex" /second-opinion start
CODEX_MODEL="${CODEX_MODEL:-}"
# 推論努力（未指定時は config.toml のデフォルトを使用）
CODEX_REASONING_EFFORT="${CODEX_REASONING_EFFORT:-}"
# config.toml の profile（任意）
CODEX_PROFILE="${CODEX_PROFILE:-}"

# codex-cli の最小サポートバージョン
CODEX_MIN_VERSION="0.98.0"

# codex 実行コマンド（codex または npx codex）
declare -a CODEX_BASE_CMD=()
# codex 引数（配列で保持して eval を避ける）
declare -a CODEX_EXEC_ARGS=()
declare -a CODEX_RESUME_ARGS=()

# 配列を表示用文字列に変換
_format_args_for_display() {
  local formatted=""
  local arg
  for arg in "$@"; do
    local quoted
    printf -v quoted "%q" "$arg"
    if [[ -n "$formatted" ]]; then
      formatted+=" "
    fi
    formatted+="$quoted"
  done
  echo "$formatted"
}

CODEX_EXEC_ARGS_DISPLAY=""
CODEX_RESUME_ARGS_DISPLAY=""

# x.y.z 形式のバージョンを比較（$1 >= $2 なら 0 を返す）
version_ge() {
  local left="$1"
  local right="$2"

  local l1=0 l2=0 l3=0
  local r1=0 r2=0 r3=0

  IFS='.' read -r l1 l2 l3 <<< "$left"
  IFS='.' read -r r1 r2 r3 <<< "$right"

  l1=${l1:-0}; l2=${l2:-0}; l3=${l3:-0}
  r1=${r1:-0}; r2=${r2:-0}; r3=${r3:-0}

  if (( l1 > r1 )); then return 0; fi
  if (( l1 < r1 )); then return 1; fi
  if (( l2 > r2 )); then return 0; fi
  if (( l2 < r2 )); then return 1; fi
  if (( l3 >= r3 )); then return 0; fi
  return 1
}

# 推論努力の値を検証
validate_reasoning_effort() {
  if [[ -z "$CODEX_REASONING_EFFORT" ]]; then
    return 0
  fi

  case "$CODEX_REASONING_EFFORT" in
    low|medium|high)
      return 0
      ;;
    *)
      echo "Error: CODEX_REASONING_EFFORT が不正です: $CODEX_REASONING_EFFORT" >&2
      echo "使用可能: low, medium, high" >&2
      return 1
      ;;
  esac
}

# codex 引数を再構築
build_codex_args() {
  validate_reasoning_effort || return 1

  CODEX_EXEC_ARGS=(--sandbox read-only -c 'approval_policy="never"')
  CODEX_RESUME_ARGS=(-c 'approval_policy="never"')

  if [[ -n "$CODEX_PROFILE" ]]; then
    CODEX_EXEC_ARGS+=(-p "$CODEX_PROFILE")
    CODEX_RESUME_ARGS+=(-p "$CODEX_PROFILE")
  fi

  if [[ -n "$CODEX_MODEL" ]]; then
    CODEX_EXEC_ARGS+=(-m "$CODEX_MODEL")
    CODEX_RESUME_ARGS+=(-m "$CODEX_MODEL")
  fi

  if [[ -n "$CODEX_REASONING_EFFORT" ]]; then
    local effort_config
    effort_config="model_reasoning_effort=\"$CODEX_REASONING_EFFORT\""
    CODEX_EXEC_ARGS+=(-c "$effort_config")
    CODEX_RESUME_ARGS+=(-c "$effort_config")
  fi

  CODEX_EXEC_ARGS_DISPLAY=$(_format_args_for_display "${CODEX_EXEC_ARGS[@]}")
  CODEX_RESUME_ARGS_DISPLAY=$(_format_args_for_display "${CODEX_RESUME_ARGS[@]}")
}

# --------------------------------------------------------------------------
# 前提条件チェック
# --------------------------------------------------------------------------

check_tmux_installed() {
  if ! command -v tmux &>/dev/null; then
    echo "Error: tmux がインストールされていません" >&2
    echo "インストール: brew install tmux" >&2
    return 1
  fi
}

check_tmux_session() {
  if [[ -z "${TMUX:-}" ]]; then
    echo "Error: tmuxセッション外で実行されています" >&2
    echo "まず tmux を起動してください: tmux new -s dev" >&2
    return 1
  fi
}

# --------------------------------------------------------------------------
# codex コマンド検出
# --------------------------------------------------------------------------

get_codex_command() {
  if command -v codex &>/dev/null; then
    CODEX_BASE_CMD=(codex)
  elif command -v npx &>/dev/null; then
    CODEX_BASE_CMD=(npx codex)
  else
    echo "Error: codex が見つかりません" >&2
    echo "インストール方法:" >&2
    echo "  npm install -g @openai/codex" >&2
    echo "または npx codex で実行してください" >&2
    return 1
  fi

  return 0
}

# codex-cli のバージョンを取得
get_codex_version() {
  local version_output=""

  version_output=$("${CODEX_BASE_CMD[@]}" --version 2>&1) || true

  echo "$version_output" | grep -Eo 'codex-cli[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}' | head -1
}

# codex-cli の最小バージョンを確認
check_codex_version_min() {
  local current_version
  current_version=$(get_codex_version)

  if [[ -z "$current_version" ]]; then
    echo "Error: codex-cli のバージョンを取得できませんでした" >&2
    echo "必要バージョン: ${CODEX_MIN_VERSION} 以上" >&2
    return 1
  fi

  if ! version_ge "$current_version" "$CODEX_MIN_VERSION"; then
    echo "Error: codex-cli のバージョンが古いです: $current_version" >&2
    echo "必要バージョン: ${CODEX_MIN_VERSION} 以上" >&2
    echo "更新方法: npm install -g @openai/codex" >&2
    return 1
  fi
}

# --------------------------------------------------------------------------
# ペイン管理
# --------------------------------------------------------------------------

# ペインが存在するか確認
pane_exists() {
  local pane_id="${1:-}"
  [[ -n "$pane_id" ]] && tmux list-panes -a -F "#{pane_id}" 2>/dev/null | grep -q "^$pane_id$"
}

# 起動中のペインIDを取得（存在しなければ空文字）
# tmux user optionを優先し、ファイルをフォールバックとして使用
get_running_pane() {
  local pane_id=""

  # 1. tmux user optionから取得（推奨）
  pane_id=$(tmux show-option -gqv "$CODEX_PANE_OPTION" 2>/dev/null || true)

  # 2. フォールバック: ファイルから取得（後方互換）
  if [[ -z "$pane_id" ]] && [[ -f "$CODEX_PANE_FILE" ]]; then
    pane_id=$(cat "$CODEX_PANE_FILE")
    # ファイルから取得した場合、tmux optionに移行
    if [[ -n "$pane_id" ]] && pane_exists "$pane_id"; then
      tmux set-option -gq "$CODEX_PANE_OPTION" "$pane_id"
      rm -f "$CODEX_PANE_FILE"
    fi
  fi

  if [[ -n "$pane_id" ]] && pane_exists "$pane_id"; then
    echo "$pane_id"
  else
    # 古いoption/ファイルをクリーンアップ
    tmux set-option -gqu "$CODEX_PANE_OPTION" 2>/dev/null || true
    rm -f "$CODEX_PANE_FILE"
  fi
}

# ペインIDを安全に保存（tmux user option + ファイル両方）
save_pane_id() {
  local pane_id="$1"
  # tmux user optionに保存（セッション共有）
  tmux set-option -gq "$CODEX_PANE_OPTION" "$pane_id"
  # 後方互換のためファイルにも保存
  echo "$pane_id" > "$CODEX_PANE_FILE"
  chmod 600 "$CODEX_PANE_FILE"
}

# ペインIDをクリア
clear_pane_id() {
  tmux set-option -gqu "$CODEX_PANE_OPTION" 2>/dev/null || true
  rm -f "$CODEX_PANE_FILE"
}

# 古いペイン状態をクリーンアップ
repair_pane_state() {
  local pane_id
  pane_id=$(get_running_pane)

  if [[ -n "$pane_id" ]]; then
    echo "ペインは正常に動作中です: $pane_id"
    return 0
  fi

  # 孤立した状態をクリーンアップ
  local option_value
  option_value=$(tmux show-option -gqv "$CODEX_PANE_OPTION" 2>/dev/null || true)

  if [[ -n "$option_value" ]] || [[ -f "$CODEX_PANE_FILE" ]]; then
    clear_pane_id
    echo "古いペイン状態をクリーンアップしました"
  else
    echo "クリーンアップ対象の状態はありません"
  fi
}

# --------------------------------------------------------------------------
# 一時ファイル管理（セキュアな方法）
# --------------------------------------------------------------------------

# セキュアな一時ファイルを作成し、パスを返す
create_temp_file() {
  local prefix="${1:-second-opinion}"
  # $TMPDIR を使用（未設定の場合は /tmp にフォールバック）
  local tmp_base="${TMPDIR:-/tmp}"
  # 末尾のスラッシュを除去
  tmp_base="${tmp_base%/}"
  # umask を設定して他ユーザーからのアクセスを防止
  (umask 077 && mktemp "${tmp_base}/${prefix}-XXXXXX")
}

# 一時ファイルをクリーンアップするtrapを設定
# 使用例: setup_cleanup_trap "$TEMP_FILE"
# 複数回呼び出し可能（ファイルは追記される）
setup_cleanup_trap() {
  # グローバル変数として保持（追記モード）
  if [[ -z "${_CLEANUP_FILES_INITIALIZED:-}" ]]; then
    _CLEANUP_FILES=()
    _CLEANUP_FILES_INITIALIZED=1
  fi
  _CLEANUP_FILES+=("$@")

  # EXIT + シグナルハンドリング
  _cleanup_handler() {
    rm -f "${_CLEANUP_FILES[@]}" 2>/dev/null || true
  }
  trap '_cleanup_handler' EXIT
  trap '_cleanup_handler; exit 130' INT
  trap '_cleanup_handler; exit 143' TERM
}

# --------------------------------------------------------------------------
# プロンプト送信（tmux load-buffer + paste-buffer 方式）
# --------------------------------------------------------------------------

# ペインにプロンプトを送信（自動で最適な方法を選択）
send_prompt_to_pane() {
  local pane_id="$1"
  local prompt="$2"

  # 長いプロンプト（500文字以上）または改行を含む場合はバッファ経由
  if [[ ${#prompt} -ge 500 ]] || [[ "$prompt" == *$'\n'* ]]; then
    send_long_prompt_to_pane "$pane_id" "$prompt"
    return $?
  fi

  # 短いプロンプトはリテラル送信
  tmux send-keys -t "$pane_id" -l "$prompt"

  # tmuxの処理完了を待機してからEnterを送信
  sleep 0.1
  tmux send-keys -t "$pane_id" Enter
}

# ペインに長いプロンプトを送信（バッファ経由）
send_long_prompt_to_pane() {
  local pane_id="$1"
  local prompt="$2"

  # 一時ファイル経由でバッファにロード
  local temp_file
  temp_file=$(create_temp_file "so-buffer")

  # バッファ名をPIDでユニーク化（並行実行対策）
  local buffer_name="so-prompt-$$"

  # ローカルクリーンアップ関数
  _local_cleanup() {
    rm -f "$temp_file" 2>/dev/null || true
    tmux delete-buffer -b "$buffer_name" 2>/dev/null || true
  }

  # 関数終了時に必ずクリーンアップ
  trap '_local_cleanup' RETURN

  echo "$prompt" > "$temp_file"

  # tmuxバッファにロードしてペースト
  if ! tmux load-buffer -b "$buffer_name" "$temp_file"; then
    return 1
  fi
  tmux paste-buffer -b "$buffer_name" -t "$pane_id"

  # ペースト完了を待機してからEnterを送信
  # プロンプトの長さに応じて待機時間を調整（最小0.1秒、最大1.0秒）
  local prompt_len=${#prompt}
  local wait_time
  wait_time=$(awk -v len="$prompt_len" 'BEGIN {
    t = len / 5000 + 0.1
    if (t > 1.0) t = 1.0
    printf "%.2f", t
  }')
  sleep "$wait_time"

  tmux send-keys -t "$pane_id" Enter
}

# --------------------------------------------------------------------------
# 入力バリデーション
# --------------------------------------------------------------------------

# トピック名をサニタイズ（パストラバーサル防止）
sanitize_topic() {
  local topic="$1"

  # 空チェック
  if [[ -z "$topic" ]]; then
    echo "Error: トピック名が空です" >&2
    return 1
  fi

  # 許可文字のみ（英数字、ハイフン、アンダースコア）
  if [[ ! "$topic" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: トピック名に使用できない文字が含まれています" >&2
    echo "使用可能: 英数字、ハイフン、アンダースコア" >&2
    return 1
  fi

  # パストラバーサルチェック（念のため）
  if [[ "$topic" == *".."* ]]; then
    echo "Error: 不正なトピック名です" >&2
    return 1
  fi

  echo "$topic"
}

# パスの安全性チェック（シンボリックリンク拒否）
validate_safe_path() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    return 0  # 存在しないパスはOK（後続で処理）
  fi

  # シンボリックリンクを拒否
  if [[ -L "$path" ]]; then
    echo "Error: シンボリックリンクは許可されていません: $path" >&2
    return 1
  fi

  return 0
}

# --------------------------------------------------------------------------
# セッションID管理（codex exec resume 用）
# --------------------------------------------------------------------------

# セッションID用のtmux user optionキーを生成
_get_session_option_key() {
  local project_hash
  project_hash=$(_hash_string "$(pwd -P)")
  echo "@second_opinion_session_${project_hash}"
}

# セッションIDを保存
save_session_id() {
  local session_id="$1"
  local option_key
  option_key=$(_get_session_option_key)
  tmux set-option -gq "$option_key" "$session_id"
}

# セッションIDを取得
get_session_id() {
  local option_key
  option_key=$(_get_session_option_key)
  tmux show-option -gqv "$option_key" 2>/dev/null || true
}

# セッションIDをクリア
clear_session_id() {
  local option_key
  option_key=$(_get_session_option_key)
  tmux set-option -gqu "$option_key" 2>/dev/null || true
}

# --------------------------------------------------------------------------
# Feature特定・コンテキスト取得
# --------------------------------------------------------------------------

# 現在のfeatureを取得（環境変数 → board.md → git diffの優先順位）
get_current_feature() {
  local feature=""

  # 1. 環境変数 FEATURE が設定されていればそれを使用
  if [[ -n "${FEATURE:-}" ]]; then
    echo "$FEATURE"
    return 0
  fi

  # 2. ai/board.md の Current Work から取得
  if [[ -f "ai/board.md" ]]; then
    # "## Current Work" セクションから feature: <name> を抽出
    feature=$(grep -A 5 "^## Current Work" "ai/board.md" 2>/dev/null | \
              grep -oE "feature:\s*\S+" | head -1 | sed 's/feature:\s*//' || true)
    if [[ -n "$feature" ]]; then
      echo "$feature"
      return 0
    fi
    # または "Feature: <name>" 形式
    feature=$(grep -A 5 "^## Current Work" "ai/board.md" 2>/dev/null | \
              grep -oE "Feature:\s*\S+" | head -1 | sed 's/Feature:\s*//' || true)
    if [[ -n "$feature" ]]; then
      echo "$feature"
      return 0
    fi
  fi

  # 3. git diff のパスから app/packages/<package>/ を抽出
  local diff_paths=""
  diff_paths=$(git diff HEAD --name-only 2>/dev/null || git diff --staged --name-only 2>/dev/null || git diff --name-only 2>/dev/null || true)
  if [[ -n "$diff_paths" ]]; then
    # app/packages/<package>/ からパッケージ名を抽出
    feature=$(echo "$diff_paths" | grep -oE "app/packages/[^/]+" | head -1 | sed 's|app/packages/||' || true)
    if [[ -n "$feature" ]]; then
      echo "$feature"
      return 0
    fi
  fi

  # 4. feature を特定できなかった場合は空文字を返す
  return 0
}

# feature の specs ドキュメントを取得
get_feature_context() {
  local feature="$1"
  local context=""

  if [[ -z "$feature" ]]; then
    return 0
  fi

  local specs_dir="ai/specs/$feature"

  # シンボリックリンクチェック
  validate_safe_path "$specs_dir" || return 0

  if [[ ! -d "$specs_dir" ]]; then
    return 0
  fi

  # requirements.md を最優先で読み込み
  if [[ -f "$specs_dir/requirements.md" ]]; then
    validate_safe_path "$specs_dir/requirements.md" || true
    local req_content
    req_content=$(head -50 "$specs_dir/requirements.md" 2>/dev/null || true)
    if [[ -n "$req_content" ]]; then
      context+="
### 要件（requirements.md）
$req_content
"
    fi
  fi

  # design.md を読み込み
  if [[ -f "$specs_dir/design.md" ]]; then
    validate_safe_path "$specs_dir/design.md" || true
    local design_content
    design_content=$(head -80 "$specs_dir/design.md" 2>/dev/null || true)
    if [[ -n "$design_content" ]]; then
      context+="
### 設計（design.md）
$design_content
"
    fi
  fi

  echo "$context"
}

# --------------------------------------------------------------------------
# JSONL出力からの応答抽出
# --------------------------------------------------------------------------

# jq がインストールされているか確認
check_jq_installed() {
  if ! command -v jq &>/dev/null; then
    echo "Error: jq がインストールされていません" >&2
    echo "インストール: brew install jq" >&2
    return 1
  fi
}

# JSONL出力から最新のagent_messageを抽出
extract_last_agent_message() {
  local jsonl_file="$1"

  jq -rs '[.[] | select(.type == "item.completed") | .item | select(.type == "agent_message")] | last | .text // empty' "$jsonl_file"
}

# JSONL出力からセッションIDを抽出
extract_session_id() {
  local jsonl_file="$1"
  jq -rs '[.[] | select(.type == "thread.started")] | first | .thread_id // empty' "$jsonl_file"
}

# --------------------------------------------------------------------------
# 出力キャプチャ
# --------------------------------------------------------------------------

# ペインの出力をキャプチャ（codexの応答完了を検知）
# 使用例: capture_pane_output "$pane_id" 60
#         capture_pane_output "$pane_id" 60 -500  # 500行取得
capture_pane_output() {
  local pane_id="$1"
  local timeout="${2:-60}"  # デフォルト60秒
  local capture_lines="${3:--300}"  # デフォルト300行（100行では長い応答が切り捨てられる）

  # 送信直後は処理中の可能性があるため少し待つ
  sleep 2

  local prev_output=""
  local stable_count=0

  for i in $(seq 1 "$timeout"); do
    sleep 1
    local output
    output=$(tmux capture-pane -t "$pane_id" -p -S "$capture_lines")

    # 「Working」状態でないことを確認
    if ! echo "$output" | grep -q 'Working'; then
      # 前回と同じ出力が2回続いたら完了とみなす
      if [[ "$output" == "$prev_output" ]]; then
        stable_count=$((stable_count + 1))
        if [[ $stable_count -ge 2 ]]; then
          echo "$output"
          return 0
        fi
      else
        stable_count=0
      fi
    fi
    prev_output="$output"
  done

  echo "Warning: タイムアウト（${timeout}秒）" >&2
  tmux capture-pane -t "$pane_id" -p -S "$capture_lines"
  return 1
}
