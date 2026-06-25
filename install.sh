#!/usr/bin/env bash
#
# install.sh — dotfiles のシンボリックリンクを自動で貼る
#
# このリポジトリ内のファイルを、リポジトリルートからの相対パスを保ったまま
# $HOME 以下へシンボリックリンクします。
# 例: <repo>/.config/wezterm/wezterm.lua -> ~/.config/wezterm/wezterm.lua
#
# 使い方:
#   ./install.sh            実行（既存ファイルはバックアップしてからリンク）
#   ./install.sh --dry-run  実際には変更せず、何が起きるかだけ表示
#   ./install.sh --force    確認なしで既存ファイルを上書き（バックアップは取る）
#
set -euo pipefail

# このスクリプトが置かれているディレクトリ = dotfiles リポジトリのルート
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# リンク対象から除外するパス（リポジトリルートからの相対パス、glob 可）
EXCLUDES=(
  ".git"
  ".gitignore"
  "install.sh"
  "README.md"
  "LICENSE"
  ".DS_Store"
)

# 例外マッピング: 既定では「リポジトリ内の相対パス = $HOME 以下のリンク先」だが、
# ここに "リポジトリ内の相対パス:$HOME からのリンク先" を書くと、その通りにリンクする。
# 例) 実体は .config/foo/bar のまま、リンクは ~/.bar に張る:
#   ".config/foo/bar:.bar"
LINK_MAP=(
)

DRY_RUN=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force)   FORCE=true ;;
    -h|--help)
      grep '^#' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' | head -n 16
      exit 0
      ;;
    *)
      echo "不明なオプション: $arg" >&2
      exit 1
      ;;
  esac
done

# 色付きログ
log()  { printf '\033[0;34m%s\033[0m %s\n' "[info]" "$*"; }
ok()   { printf '\033[0;32m%s\033[0m %s\n' "[ ok ]" "$*"; }
warn() { printf '\033[0;33m%s\033[0m %s\n' "[warn]" "$*"; }
skip() { printf '\033[0;90m%s\033[0m %s\n' "[skip]" "$*"; }

# 相対パスが除外対象かどうか判定
is_excluded() {
  local rel="$1"
  local top="${rel%%/*}"   # 先頭セグメント
  for ex in "${EXCLUDES[@]}"; do
    [[ "$top" == "$ex" || "$rel" == "$ex" ]] && return 0
  done
  return 1
}

# LINK_MAP に登録された相対パスなら、対応するリンク先（$HOME からの相対）を返す。
# 未登録なら入力をそのまま返す（= 既定の「同じ構造」動作）。
mapped_dest() {
  local rel="$1"
  for entry in ${LINK_MAP[@]+"${LINK_MAP[@]}"}; do
    if [[ "${entry%%:*}" == "$rel" ]]; then
      printf '%s' "${entry#*:}"
      return
    fi
  done
  printf '%s' "$rel"
}

link_file() {
  local src="$1"                       # リポジトリ内の絶対パス
  local rel="${src#"$DOTFILES_DIR"/}"  # ルートからの相対パス
  local dst_rel
  dst_rel="$(mapped_dest "$rel")"      # マッピングがあれば差し替え
  local dst="${TARGET_DIR}/${dst_rel}" # リンク先（$HOME 以下）

  if is_excluded "$rel"; then
    return
  fi

  # 既に正しいリンクが張られていればスキップ
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    skip "$rel (既にリンク済み)"
    return
  fi

  # 親ディレクトリを作成
  local dst_parent
  dst_parent="$(dirname "$dst")"
  if [[ ! -d "$dst_parent" ]]; then
    if $DRY_RUN; then
      log "mkdir -p $dst_parent"
    else
      mkdir -p "$dst_parent"
    fi
  fi

  # リンク先に既存の実体（ファイル/ディレクトリ/別リンク）がある場合
  if [[ -e "$dst" || -L "$dst" ]]; then
    if ! $FORCE; then
      printf '\033[0;33m%s\033[0m %s\n' "[warn]" "$dst は既に存在します。"
      read -r -p "       バックアップして上書きしますか? [y/N] " ans </dev/tty || ans="n"
      if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        skip "$rel (ユーザがスキップ)"
        return
      fi
    fi
    # バックアップ
    local backup_path="${BACKUP_DIR}/${rel}"
    if $DRY_RUN; then
      log "backup $dst -> $backup_path"
    else
      mkdir -p "$(dirname "$backup_path")"
      mv "$dst" "$backup_path"
    fi
    warn "$rel を $backup_path に退避しました"
  fi

  # シンボリックリンク作成
  if $DRY_RUN; then
    log "ln -s $src $dst"
  else
    ln -s "$src" "$dst"
  fi
  ok "$rel -> $dst"
}

main() {
  log "dotfiles: $DOTFILES_DIR"
  log "target  : $TARGET_DIR"
  $DRY_RUN && log "(dry-run モード: 実際の変更は行いません)"
  echo

  # 除外ディレクトリは find の段階でも枝刈りして高速化
  while IFS= read -r -d '' src; do
    link_file "$src"
  done < <(
    find "$DOTFILES_DIR" \
      \( -path "$DOTFILES_DIR/.git" \) -prune -o \
      -type f -print0
  )

  echo
  ok "完了しました。"
  if [[ -d "$BACKUP_DIR" ]]; then
    log "退避したファイル: $BACKUP_DIR"
  fi
}

main
