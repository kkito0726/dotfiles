# zsh の「よく編集する対話設定」。zsh.nix の initContent 末尾から source される生ファイル。
#
# ここは Nix を通さず直接読まれるので、編集したら `source ~/.config/zsh/rc.zsh` か
# 新しいシェルを開くだけで即反映される (hm-switch 不要・そのまま commit できる)。
# oh-my-zsh / プラグイン / 補完 / 履歴 / OS 依存部 (Homebrew の pyenv・nvm 等) と
# hm-switch は zsh.nix 側が管理する。ここには OS 非依存の alias / 関数 / 挙動を書く。

# ── エイリアス ─────────────────────────────────────────────
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first --git'
alias la='eza -la --group-directories-first --git'
alias lt='eza --tree --level=2'
# cat は本物の cat のまま。色付き表示が欲しいときは bat を直接使う。
alias v='nvim'
# vim は本物の Vim (vim.nix) を指すので alias は張らない
alias lg='lazygit'
alias hm='home-manager'

# ── 対話シェルの挙動 ───────────────────────────────────────
# ディレクトリ移動を快適にする
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS

# 補完で大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# 編集中のコマンドを nvim で開く (Ctrl-X Ctrl-E → :wq で戻る)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ── ここから下に自由に alias / 関数 / 設定を追記する ──────────
