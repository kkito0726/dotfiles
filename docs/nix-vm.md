# Linux VM の環境構築 (Nix / Home Manager)

新しい Linux VM を立てたときに、zsh + oh-my-zsh / LazyVim / lazygit / tmux の環境を
1 コマンドで再現するための Home Manager (standalone) 設定。

NixOS 専用ではないので、Ubuntu / Debian / Fedora など任意のディストロで動く。

## macOS (ホスト) との棲み分け

このリポジトリは 2 通りの展開方法を持っている。**混ぜて使わないこと。**

| | macOS (ホスト) | Linux VM |
|---|---|---|
| 展開方法 | `./install.sh` (symlink) | `home-manager switch` (Nix) |
| パッケージ | Homebrew | Nix |
| zsh 設定 | `zsh/zshrc` を `~/.zshrc` へリンク | `nix/home/zsh.nix` が生成 |
| nvim 設定 | `.config/nvim` を symlink | `.config/nvim` を symlink (同じ実体) |
| vim 設定 | `.vimrc` を symlink | `.vimrc` を symlink (同じ実体) |

> **VM 上で `./install.sh` を実行しないこと。**
> `zsh/zshenv` のリンク先 `~/.zshenv` は Home Manager も生成するため衝突し、
> activation が失敗する。また `zsh/zshrc` は Homebrew / pyenv / nvm 前提で
> Linux では動かない。VM 側の shell 設定は `nix/home/zsh.nix` が担当する。

nvim 設定 (`.config/nvim`) と vim 設定 (`.vimrc`) は両者で同じ実体を指すので、
どちらで編集しても git 経由で共有される。

## VM 上でのセットアップ

まっさらな Linux VM を想定した手順。Nix も git も入っていない状態から始める。

### 0. 前提パッケージ (ディストロのパッケージマネージャで入れる)

Nix のインストーラ自体が `curl` と `xz` を要求する。最小構成のイメージには
`xz` が入っていないことがあるので先に入れる。`sudo` が使える一般ユーザーで作業する。

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y curl xz-utils ca-certificates

# Fedora / RHEL / Rocky
sudo dnf install -y curl xz ca-certificates

# Alpine
sudo apk add curl xz ca-certificates
```

git はここでは入れなくてよい。Nix を入れた後に Nix 側から使う (手順 2 参照)。

### 1. Nix をインストール

Determinate Systems のインストーラを使う。flakes と nix-command が最初から
有効になっているので、`/etc/nix/nix.conf` を手で編集する必要がない。

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install
```

インストール後、**現在のシェルにはまだ `nix` が無い**。再ログインするか、
プロファイルを読み込む:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --version   # 動作確認
```

<details>
<summary>公式インストーラを使う場合 (flakes を自分で有効化する必要がある)</summary>

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

sudo mkdir -p /etc/nix
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon   # systemd が無い環境では再ログインで代用
```
</details>

<details>
<summary>systemd が無い / root 権限が無い環境 (コンテナなど)</summary>

マルチユーザーモードは systemd に依存するので、シングルユーザーモードで入れる:

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```
</details>

### 2. このリポジトリを clone

VM に git が無くても、Nix 経由で入れれば済む。

```bash
nix profile install nixpkgs#git
git clone https://github.com/kkito0726/dotfiles.git ~/dotfiles
```

**clone 先は `~/dotfiles` にすること。** `~/.config/nvim` はここへの symlink になる。
別の場所に置く場合は `flake.nix` の `dotfilesDir` を合わせて変更する。

> ブートストラップ用の `nix profile install nixpkgs#git` は、適用後に
> `nix profile remove git` で外してよい。以降は Nix 側の git が入る。

### 3. 適用 (初回)

`home-manager` コマンドはまだ無いので、`nix run` で一時的に呼び出す。

```bash
nix run home-manager/master -- switch --flake ~/dotfiles#$USER@$(uname -m)-linux
```

`$USER` が `flake.nix` の `username` (既定は `ken`) と一致している必要がある。
違う場合は先に `flake.nix` を書き換える。
`$(uname -m)` は x86_64 VM なら `x86_64`、ARM VM なら `aarch64` に展開される。

### 4. zsh をログインシェルにする

```bash
command -v zsh | sudo tee -a /etc/shells
chsh -s "$(command -v zsh)"
```

`chsh` が使えない VM でも、bash から zsh へ `exec` する設定を入れてあるので
対話シェルは zsh になる (`nix/home/zsh.nix` 参照)。

### 5. 確認

再ログインしてから:

```bash
echo $SHELL            # zsh になっている
lazygit --version
ls -l ~/.config/nvim   # ~/dotfiles/.config/nvim への symlink になっている
nvim                   # 初回起動で lazy.nvim が LazyVim のプラグインを同期する
tmux                   # prefix は C-q
```

## 2 回目以降

`home-manager` 自体もこの設定で入るので、以後は短く書ける
(`hm-switch` エイリアスも用意してある)。

```bash
home-manager switch --flake ~/dotfiles#$USER@$(uname -m)-linux
```

## nvim の設定 / キーバインド

`~/.config/nvim` は `~/dotfiles/.config/nvim` への symlink なので、ホストの
macOS とまったく同じ設定が入る。VM 上で編集して `git push` すれば、ホスト側で
`git pull` して反映できる (逆も同様)。

`init.lua` に入っているカスタマイズ:

| 設定 | 内容 |
|---|---|
| `jj` (insert モード) | `<ESC>` |
| `ff` (visual モード) | `<ESC>` |
| `clipboard` | `unnamedplus` (OS クリップボードと共有) |
| インデント | `expandtab`, tabstop / softtabstop / shiftwidth = 4 |

プラグイン側は `lua/plugins/colorscheme.lua` で tokyonight を透過設定にしている。

### VM から push する場合

clone は HTTPS なので、push には認証が要る。`gh` が入っているので:

```bash
gh auth login          # ブラウザ認証 or PAT
gh auth setup-git
```

SSH 鍵を VM に置いているなら remote を張り替えてもよい:

```bash
git -C ~/dotfiles remote set-url origin git@github.com:kkito0726/dotfiles.git
```

## vim (neovim とは別物)

`nvim` (LazyVim) とは独立して、本物の Vim も入れている。

| コマンド | 実体 | 読む設定 |
|---|---|---|
| `vim` | Vim (`vim-full`) | `~/.vimrc` (= `~/dotfiles/.vimrc` への symlink) |
| `nvim` | neovim | `~/.config/nvim` (LazyVim) |

`~/.vimrc` の中身:

| 設定 | 内容 |
|---|---|
| `jj` (insert モード) | `<ESC>` |
| `ff` (visual モード) | `<ESC>` |
| `clipboard+=unnamed` | OS クリップボードと共有 |

> パッケージは `pkgs.vim` ではなく **`pkgs.vim-full`** を使っている。
> `.vimrc` の `set clipboard+=unnamed` は clipboard 対応ビルド (`+clipboard`) で
> ないと起動時に `E518` を出すが、軽量な `pkgs.vim` は `-clipboard` のため。
> `vim-full` は X11 / GTK3 / python3 / ruby を含むぶん依存が重い。
> クリップボード連携が実際に効くかは下記「クリップボード連携について」と同じ制約。

### クリップボード連携について

`clipboard = "unnamedplus"` は外部プロバイダを必要とする。X11 / Wayland 環境向けに
`xclip` と `wl-clipboard` を入れてあるが、**ヘッドレスな VM に SSH している場合は
どちらも機能しない**。その場合は端末エミュレータ側の OSC 52 対応に頼るか、
nvim 側で `vim.g.clipboard` を OSC 52 に設定する。

## tmux

キーバインド定義はリポジトリ直下の `.tmux.conf` に一本化している。
ホストはこれを `~/.tmux.conf` へリンクして使い、VM 側は `nix/home/tmux.nix` が
`builtins.readFile` で同じファイルを読み込む (単一ソース)。
prefix は `C-b` ではなく **`C-q`**。

| キー (prefix 後) | 動作 |
|---|---|
| `\|` | 左右分割 |
| `v` | 上下分割 |
| `h` / `j` / `k` / `l` | ペイン移動 (左 / 下 / 上 / 右) |
| `s` | セッション / ウィンドウ一覧 (`choose-tree -Zw`) |
| `r` | 設定の再読み込み |
| `d` | デタッチ (tmux 既定のまま) |

マウス操作は有効。

ホストには無いが VM 用に足した設定:

- `default-shell` を zsh に固定 (`chsh` が失敗しても tmux 内は zsh)
- `tmux-256color` + truecolor override (LazyVim の配色のため)
- `escape-time 10` — 既定の 500ms だと nvim の `ESC` / `jj` が体感で遅れる
- `history-limit 50000`

VM では `bind r` の reload 先だけ、ホスト共有の定義を上書きして
home-manager 生成ファイル (`~/.config/tmux/tmux.conf`) を指すようにしている。

## VM ごとに書き換える場所

| 項目 | 場所 |
|---|---|
| ユーザー名 / 対象アーキテクチャ | `flake.nix` の `username`, `systems` |
| リポジトリの clone 先 | `flake.nix` の `dotfilesDir` |
| git の user.name / user.email | `nix/home/git.nix` |
| 追加したい CLI ツール | `nix/home/packages.nix` |
| 追加したい LSP / フォーマッタ | `nix/home/neovim.nix` の `extraPackages` |

## 構成

```
flake.nix              入口。username と clone 先と対象システムを定義
flake.lock             nixpkgs / home-manager のバージョン固定
nix/home/
  default.nix          共通設定 (stateVersion, 環境変数, genericLinux)
  packages.nix         基本 CLI ツール群 (ripgrep, fd, bat, eza, fzf, ...)
  zsh.nix              zsh + oh-my-zsh + 補完 / 履歴 / エイリアス
  git.nix              git 設定 + delta + gh
  lazygit.nix          lazygit
  neovim.nix           Neovim 本体 + LazyVim のランタイム依存 + nvim 設定のリンク
  vim.nix              本物の Vim (vim-full) + .vimrc のリンク
  tmux.nix             tmux (prefix C-q, vim 風ペイン移動)
```

## 設計上の判断

- **nvim 設定は Nix で宣言的に固めない。** `nix/home/neovim.nix` は
  `~/.config/nvim` をリポジトリ内の `.config/nvim` へ `mkOutOfStoreSymlink` で
  リンクするだけ。通常の `xdg.configFile` だと nix store への読み取り専用リンクに
  なって VM 上で試行錯誤できないため。Nix 側はランタイム依存 (ripgrep, fd, gcc,
  tree-sitter) と LSP の供給に徹する。
- **`targets.genericLinux.enable = true`。** 非 NixOS でロケールや `XDG_DATA_DIRS` が
  壊れるのを防ぐ。NixOS 上で使う場合は `nix/home/default.nix` で false にする。
- **`programs.bash.initExtra` で zsh に exec している。** `chsh` が使えない VM
  (コンテナ等) でも対話シェルが zsh になる保険。
- **`install.sh` は `flake.nix` / `flake.lock` / `nix/` を除外する。**
  これらは `$HOME` にリンクするものではないため。

## 注意

- lazygit / LazyVim のアイコン表示にはターミナル側の Nerd Font が必要。
  使わない場合は `nix/home/lazygit.nix` の `nerdFontsVersion` を `""` にする。
- `home.stateVersion` は初回導入時のバージョンを表す。動いた後に上げない。
