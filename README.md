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

`install.sh` は **Nix を入れられないマシン用のフォールバック**として残してある（下記「install.sh（フォールバック）」参照）。
Nix で運用しているマシンでは実行しないこと（`~/.zshenv` が Home Manager と衝突する）。

## 管理対象

| リポジトリ内のパス             | リンク先                         | 用途                                                              |
| ------------------------------ | -------------------------------- | ----------------------------------------------------------------- |
| `zsh/zshenv`                   | `~/.zshenv`                      | zsh 環境変数（cargo env など、全シェルで読まれる）                |
| `zsh/zprofile`                 | `~/.zprofile`                    | zsh ログインシェル設定（brew shellenv）                           |
| `zsh/zshrc`                    | `~/.zshrc`                       | zsh 設定（PATH・プロンプト・補完など）                            |
| `bash/bashrc`                  | `~/.bashrc`                      | bash プロンプト（zsh の git プロンプトを移植。Docker コンテナ用） |
| `.vimrc`                       | `~/.vimrc`                       | Vim 設定                                                          |
| `.tmux.conf`                   | `~/.tmux.conf`                   | tmux 設定（prefix C-q など。VM 側は nix/home/tmux.nix が読み込む）|
| `.ideavimrc`                   | `~/.ideavimrc`                   | IntelliJ (IdeaVim) 設定                                           |
| `.config/nvim/`                | `~/.config/nvim`                 | Neovim 設定（LazyVim 一式。ディレクトリ単位でリンク）             |
| `.config/wezterm/wezterm.lua`  | `~/.config/wezterm/wezterm.lua`  | WezTerm 本体設定                                                  |
| `.config/wezterm/keybinds.lua` | `~/.config/wezterm/keybinds.lua` | WezTerm キーバインド                                              |
| `.config/ghostty/config`       | `~/.config/ghostty/config`       | Ghostty 設定                                                      |
| `.config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty 設定（フォント・透過など）                      |
| `vscode/settings.json`         | `~/Library/Application Support/Code/User/settings.json` | VSCode 設定（マシン固有値を除去済み）             |
| `vscode/keybindings.json`      | `~/Library/Application Support/Code/User/keybindings.json` | VSCode キーバインド（OS 別パスで解決）         |

シンボリックリンクの対象外（`install.sh` の `EXCLUDES` に入っている）:

| パス | 用途 |
| --- | --- |
| `flake.nix` / `flake.lock` | Home Manager 設定の入口（macOS / Linux 共通） |
| `nix/home/` | Home Manager のモジュール群（zsh・git・lazygit・nvim・vim・tmux ＋ macOS 専用の terminals・vscode） |

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
nix run home-manager/master -- switch --flake ~/dotfiles#$USER@$(uname -m | sed 's/arm64/aarch64/')-darwin
```

> **旧 `install.sh` で symlink 済みのマシンから移行する場合**、`home-manager switch` は
> 既存ファイルを上書きできず失敗する。適用前に install.sh 由来のリンクを外しておく（実体は
> repo 側なので消えない）:
>
> ```sh
> rm -f ~/.zshrc ~/.zshenv ~/.zprofile \
>       ~/.config/wezterm/wezterm.lua ~/.config/wezterm/keybinds.lua \
>       ~/.config/ghostty/config ~/.config/alacritty/alacritty.toml
> rm -f "$HOME/Library/Application Support/Code/User/settings.json" \
>       "$HOME/Library/Application Support/Code/User/keybindings.json"
> ```

`$USER` が `flake.nix` の `username`（既定 `ken`）と一致している必要がある。違う場合は先に `flake.nix` を書き換える。
以降は `hm-switch`（zsh 関数。OS を判定して適切な flake attribute を選ぶ）で再適用できる。

### Linux VM

Nix と Home Manager で、zsh + oh-my-zsh / LazyVim / lazygit / tmux をまとめて構築する。
Nix も git も入っていない状態からの完全な手順は [docs/nix-vm.md](docs/nix-vm.md) を参照。

```sh
git clone https://github.com/kkito0726/dotfiles.git ~/dotfiles
nix run home-manager/master -- switch --flake ~/dotfiles#$USER@$(uname -m)-linux
```

## install.sh（フォールバック）

> Nix を導入できないマシン専用。**Nix で運用しているホストでは実行しないこと**
> （`~/.zshenv` が Home Manager と衝突する）。zsh 系設定は Homebrew 前提のため Linux では動かない。

| コマンド                 | 動作                                                             |
| ------------------------ | ---------------------------------------------------------------- |
| `./install.sh`           | リンクを作成（既存ファイルは確認のうえバックアップして置き換え） |
| `./install.sh --dry-run` | 実際には変更せず、何が起きるかだけ表示                           |
| `./install.sh --force`   | 確認なしで既存ファイルを置き換え（バックアップは必ず取る）       |
| `./install.sh --help`    | ヘルプを表示                                                     |

### 仕様

- **冪等**: 既に正しいリンクが張られていれば `skip`。何度実行しても安全。
- **バックアップ**: リンク先に実体ファイルがある場合、`~/.dotfiles-backup/<日時>/` へ退避してからリンクを張る。
- **除外**: `.git` / `install.sh` / `README.md` などはリンク対象外（`install.sh` の `EXCLUDES` で管理）。
- **例外マッピング**: 実体の位置とリンク先を変えたい場合は `install.sh` の `LINK_MAP` に
  `"リポジトリ内の相対パス:$HOME からのリンク先"` を追加する。
- **OS 依存パス**: VSCode 設定など OS ごとに置き場所が違うものは、`install.sh` 内で `uname` 判定し
  リンク先を動的に決定する（macOS: `Library/Application Support/Code/User`、
  Linux: `.config/Code/User`、Windows: `AppData/Roaming/Code/User`）。
- **ディレクトリ単位リンク**: 配下のファイルが増減する設定（LazyVim 等）は、末端ファイルではなく
  ディレクトリ自体をリンクする。`install.sh` の `LINK_DIRS` に相対パスを追加する（例: `.config/nvim`）。
  これにより、プラグイン追加や `lazy-lock.json` 更新のたびに `install.sh` を再実行する必要がない。

## 運用メモ

- ファイルの**中身を編集**しただけなら `install.sh` の再実行は不要（実体は1つで、リンク経由でそのまま反映される）。
- **新しいファイルを管理対象に追加**したときだけ `install.sh` を再実行する。
- 既存の `~/xxx` を管理下に置くには、実体をリポジトリへ移動してから `install.sh` を実行する。

  ```sh
  mv ~/.gitconfig ~/dotfiles/.gitconfig
  cd ~/dotfiles && ./install.sh
  ```
