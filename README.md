# dotfiles

個人用の設定ファイル（dotfiles）を集約して管理するリポジトリ。

**macOS ホスト・Linux VM のどちらも Nix / Home Manager で構築する**のが基本方針。
`flake.nix` が OS を判定し、共通モジュール + OS 固有モジュールを組み合わせる。

| 環境 | 方法 | 入口 |
| --- | --- | --- |
| macOS（ホスト） | Nix / Home Manager（GUI アプリ本体のみ Homebrew cask） | `flake.nix` → `ken@aarch64-darwin` |
| Linux VM | Nix / Home Manager で環境ごと構築 | `flake.nix` → [docs/nix-vm.md](docs/nix-vm.md) |

設定の実体（nvim / vim / tmux / wezterm / ghostty / alacritty / vscode）は、どの OS でも
リポジトリ内の同じファイルを `mkOutOfStoreSymlink` で指すので、編集して即反映・そのまま commit できる。
zsh / git / lazygit は実体ファイルを持たず、`nix/home/*.nix` から設定ファイルを生成する。

## 管理対象

リポジトリ内に実体を持ち、Home Manager が symlink するもの:

| リポジトリ内のパス | 配置先 | 担当モジュール |
| --- | --- | --- |
| `.config/nvim/` | `~/.config/nvim` | [neovim.nix](nix/home/neovim.nix) |
| `.vimrc` | `~/.vimrc` | [vim.nix](nix/home/vim.nix) |
| `.ideavimrc` | `~/.ideavimrc` | [vim.nix](nix/home/vim.nix) |
| `.tmux.conf` | `~/.config/tmux/tmux.conf`（`readFile` で取り込み） | [tmux.nix](nix/home/tmux.nix) |
| `.config/wezterm/*.lua` | `~/.config/wezterm/*.lua` | [terminals.nix](nix/home/terminals.nix) |
| `.config/ghostty/config` | `~/.config/ghostty/config` | [terminals.nix](nix/home/terminals.nix) |
| `.config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | [terminals.nix](nix/home/terminals.nix) |
| `vscode/settings.json` | `~/Library/Application Support/Code/User/settings.json`（macOS のみ） | [vscode.nix](nix/home/vscode.nix) |
| `vscode/keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json`（macOS のみ） | [vscode.nix](nix/home/vscode.nix) |

Nix モジュールが設定ファイルを生成するもの（リポジトリに実体は無い）:

| 生成物 | 担当モジュール |
| --- | --- |
| zsh + oh-my-zsh（補完 / 履歴 / エイリアス、macOS 固有部は darwin ブロック） | [zsh.nix](nix/home/zsh.nix) |
| git + delta + gh | [git.nix](nix/home/git.nix) |
| lazygit | [lazygit.nix](nix/home/lazygit.nix) |
| 基本 CLI ツール群（ripgrep / fd / bat / eza / fzf / zoxide ...） | [packages.nix](nix/home/packages.nix) |

## Nix のインストール（macOS / Linux 共通）

[Determinate Systems のインストーラ](https://install.determinate.systems)を使う。
flakes と `nix-command` が最初から有効なので `nix.conf` を手で編集しなくてよい。macOS / Linux 共通。

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

インストール直後の**現在のシェルにはまだ `nix` が無い**。再ログインするか、プロファイルを読み込む:

```sh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix --version   # 動作確認
```

- **Linux VM**（Nix も git も無い素の状態からの完全手順、systemd 無し環境の分岐なども含む）は
  [docs/nix-vm.md](docs/nix-vm.md) を参照。
- **macOS** は下記「セットアップ › macOS」へ。

## セットアップ

初回適用時、VM 標準の `~/.bashrc` など既存ファイルがあると `home-manager switch` は
「上書きできない」で止まる。`-b backup` を付けると `<file>.backup` に退避してから進む。

### macOS（ホスト）

前提として **Nix**（上記）と、GUI アプリ用に [Homebrew](https://brew.sh) を導入しておく。

```sh
# 1. Homebrew（未導入なら）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. GUI アプリ本体を cask で入れる（設定ファイルは Home Manager が symlink する）
brew install --cask wezterm ghostty alacritty visual-studio-code

# 3. このリポジトリを clone（clone 先は ~/dotfiles にすること。別の場所なら flake.nix の dotfilesDir を合わせる）
git clone https://github.com/kkito0726/dotfiles.git ~/dotfiles

# 4. Home Manager を適用（home-manager コマンドはまだ無いので nix run で呼ぶ）
nix run home-manager/master -- switch -b backup --flake ~/dotfiles#$USER@$(uname -m | sed 's/arm64/aarch64/')-darwin
```

`$USER` が `flake.nix` の `username`（既定 `ken`）と一致している必要がある。違う場合は先に `flake.nix` を書き換える。
以降は `hm-switch`（zsh 関数。OS を判定して適切な flake attribute を選ぶ）で再適用できる。

### Linux VM

Nix と Home Manager で、zsh + oh-my-zsh / LazyVim / lazygit / tmux をまとめて構築する。
Nix も git も入っていない状態からの完全な手順は [docs/nix-vm.md](docs/nix-vm.md) を参照。

```sh
git clone https://github.com/kkito0726/dotfiles.git ~/dotfiles
nix run home-manager/master -- switch -b backup --flake ~/dotfiles#$USER@$(uname -m)-linux
```

## 運用メモ

- **設定ファイルの中身を編集しただけ**なら再適用は不要。実体はリポジトリ側にあり、symlink 経由で
  そのまま反映される（アプリの再読み込みだけでよい）。
- **設定を Nix で生成しているもの**（zsh / git / lazygit のエイリアスや options など）を変えたときや、
  **新しいファイルを管理対象に追加**したときは再適用する:

  ```sh
  nvim ~/dotfiles/nix/home/zsh.nix   # 設定を編集
  hm-switch                          # 適用（OS を自動判定）
  cd ~/dotfiles && git add -u && git commit -m "..." && git push
  ```

- macOS でも VM でも `~/dotfiles` は同じリポジトリ。片方で編集して `git push` → もう片方で
  `git pull && hm-switch` すれば揃う。
- OS 別に効かせたい設定は、各モジュール内で `lib.mkIf pkgs.stdenv.isDarwin` や
  `lib.optionalString isDarwin` で分岐する（例は [zsh.nix](nix/home/zsh.nix) / [terminals.nix](nix/home/terminals.nix)）。

## リポジトリ構成

```
flake.nix / flake.lock   入口。username / 対象システム / 依存の固定
nix/home/
  default.nix    共通設定（OS 判定・stateVersion・環境変数）＋ import
  packages.nix   基本 CLI ツール群
  zsh.nix        zsh + oh-my-zsh（macOS 固有部は darwin ブロック）
  git.nix        git + delta + gh
  lazygit.nix    lazygit
  neovim.nix     neovim 本体 + LazyVim のランタイム依存 + 設定リンク
  vim.nix        本物の Vim + .vimrc / .ideavimrc リンク
  tmux.nix       tmux（.tmux.conf を単一ソースとして取り込み）
  terminals.nix  wezterm / ghostty / alacritty の設定リンク（全 OS）
  vscode.nix     VSCode 設定リンク（macOS のみ）
.config/nvim/    LazyVim 一式（実体）
.vimrc .ideavimrc .tmux.conf   各種設定の実体
.config/{wezterm,ghostty,alacritty}   ターミナル設定の実体
vscode/          VSCode 設定の実体
docs/            セットアップ手順・キーバインド一覧
```
