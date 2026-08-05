# Linux VM の環境構築 (Nix / Home Manager)

新しい Linux VM を立てたときに、zsh + oh-my-zsh / LazyVim / lazygit / tmux の環境を
1 コマンドで再現するための Home Manager (standalone) 設定。

NixOS 専用ではないので、Ubuntu / Debian / Fedora など任意のディストロで動く。

## macOS (ホスト) との棲み分け

macOS ホスト・Linux VM とも **Home Manager (Nix) で構築する**のが基本方針。
`flake.nix` が OS を判定し、共通モジュール + OS 固有モジュールを組み合わせる。

| | macOS (ホスト) | Linux VM |
|---|---|---|
| 適用方法 | `home-manager switch …#$USER@…-darwin` | `home-manager switch …#$USER@…-linux` |
| パッケージ (CLI) | Nix | Nix |
| GUI アプリ本体 | Homebrew cask (wezterm / ghostty / vscode 等) | (基本 CLI のみ) |
| zsh 設定 | `nix/home/zsh.nix` が生成 (macOS 固有部は darwin ブロック) | `nix/home/zsh.nix` が生成 |
| ターミナル設定 (ghostty/wezterm/alacritty) | `nix/home/terminals.nix` が symlink | 同じく symlink (本体は入れない) |
| VSCode 設定 | `nix/home/vscode.nix` が symlink | (VM では対象外) |
| nvim / vim 設定 | `.config/nvim` / `.vimrc` を symlink | 同じ実体を symlink |

shell 設定 (zsh) は macOS / Linux とも `nix/home/zsh.nix` が生成する。macOS 固有の設定
(Homebrew / pyenv / nvm など) は zsh.nix の darwin ブロックにまとめてある。よく編集する
alias / 対話設定だけは生ファイル `.zshrc` (リポジトリ) に置き、`~/.zshrc` へ symlink して
本体 rc (`~/.config/zsh/.zshrc`) の末尾で `source` する。`~/.zshrc` を編集して `source ~/.zshrc`
で即反映・hm-switch 不要 (本体 rc は dotDir=~/.config/zsh 側なので ~/.zshrc とは衝突しない)。

nvim 設定 (`.config/nvim`) と vim 設定 (`.vimrc`) は macOS / Linux で同じ実体を指すので、
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

`home-manager` 自体もこの設定で入るので、以後は短く書ける。

```bash
home-manager switch --flake ~/dotfiles#$USER@$(uname -m)-linux
```

**GUI 付き Linux ではこのコマンドを直接使わないこと。** `$USER@…` は GUI 無し構成
なので、これで再適用すると [キー再マップ (xremap)](#gui-付き-linux-キー再マップ--xremap)
が丸ごと消える (`~/.config/xremap/` も systemd サービスも無くなる)。

代わりに `hm-switch` ([nix/home/hm-switch.nix](../nix/home/hm-switch.nix) が入れるコマンド)
を使う。OS に加えて GUI の有無も見て `$USER@…` / `$USER-gui@…` を自動で選ぶ。

```bash
hm-switch      # 選んだ attribute を表示してから switch する
```

GUI 判定は次の順で行う。

1. `graphical-session.target` が active … デスクトップにログイン中。`-gui` を選び、同時に
   `~/.local/state/hm-gui` にマーカーを残す。
2. マーカーがある … 過去に GUI 機として適用済み。**デスクトップ未ログインの SSH / TTY から
   叩いても `-gui` を維持する。** target はセッション状態なので GUI 機でも inactive になり
   うるため、ここを見ないと「SSH から再適用したら xremap が消えた」が起きる。
3. どちらでもない … ヘッドレス VM とみなして `$USER@…` を選ぶ。

> シェル関数ではなく実行ファイルにしてあるのは、関数だとシェル起動時に rc から読み込まれて
> メモリに載るため、**関数を直したあとも既に開いているターミナルは古い定義を使い続ける**
> から。実際それで GUI 構成が外れて xremap が消える事故が起きた。実行ファイルなら起動の
> たびに現在の中身が読まれるので、古いターミナルから叩いても安全。

## GUI 付き Linux (キー再マップ / xremap)

デスクトップ環境のある Linux で、macOS 風のキー配置 (Cmd→Ctrl) を使いたいときは
**`$USER-gui@…` 構成**を使う。ヘッドレス VM 用の `$USER@…` にはこの設定は入らない
(Nix は GUI の有無を自動判定できないので、構成名で明示的に切り替える)。

キー再マップは [xremap](https://github.com/xremap/xremap) で行う。設定の実体は
`~/dotfiles/.config/xremap/config.yml` (編集して即反映・そのまま commit できる)。
担当モジュールは [nix/home/keymap.nix](../nix/home/keymap.nix)。

**アプリを判別して振り分ける。** ターミナルで Cmd+C を単純に Ctrl+C にすると、コピー
ではなく実行中プログラムへの SIGINT (中断/終了) になってしまう。そこで:

- ターミナル (wezterm / ghostty / alacritty …) … Cmd+C/V を **Ctrl+Shift+C/V** (コピー/貼付)
  にし、**Ctrl+C は触らず SIGINT のまま**残す。
- それ以外のアプリ (VSCode / Chrome など) … **Super は Super のまま残し**、`Super+<キー>`
  を `Ctrl+<キー>` に個別変換する (文字 a〜z / Shift 付き / よく使う記号)。これで Cmd+C・
  Cmd+Shift+P・Cmd+/ などが macOS 感覚で効く。
  - **残るもの (非文字キーなので変換対象外)**: Super 単独 (オーバービュー)、Super+←/→
    (タイル)、Super+↑/↓、Super+1〜9 (Dock)、Super+PageUp/Down (ワークスペース)、
    Super+Space (入力切替) といった GNOME のウィンドウ操作はそのまま使える。
  - **上書きされるもの (割り切り)**: 文字ベースの GNOME ショートカット、例えば Super+L
    (ロック)、Super+A (アプリ一覧)、Super+D (デスクトップ表示) は Ctrl+◯ に化ける。
    残したい行は `config.yml` の該当エントリを削るだけでよい。
- 注意: VSCode の統合ターミナルや Chrome 内の Web ターミナルは「そのアプリのウィンドウ」
  として扱われる (=非ターミナル判定) ため、そこでのコピーは Ctrl+Shift+C を使う
  (xremap はウィンドウ単位判定なので、アプリ内の端末パネルまでは区別できない)。

この振り分けにはフォーカス中ウィンドウの判別が要る。**Ubuntu 26.04 など GNOME/Wayland が
デフォルトの環境**では xremap の gnome variant (`nix/home/keymap.nix` で選択済み) に加えて
**「Xremap」GNOME 拡張の導入が必要**。X11 セッションでログインするなら拡張は不要。

- GNOME 拡張マネージャ (`gnome-shell-extension-manager` / flatpak の Extension Manager) か
  [extensions.gnome.org](https://extensions.gnome.org/) から「**Xremap**」を入れて有効化する。
- 別の環境 (KDE / sway / Hyprland / X11 のみ) なら、[keymap.nix](../nix/home/keymap.nix) の
  `pkgs.xremap.gnome` を `pkgs.xremap.{kde,wlroots,hypr,x11}` に差し替える。

### 初回のみ root で必要な設定 (Home Manager では管理できない)

xremap は `/dev/uinput` を使うため、rootless で動かすには一度だけ root 権限の設定が要る。

```bash
# 1. uinput を有効化 (再起動後も有効にするなら /etc/modules-load.d/ にも書く)
sudo modprobe uinput

# 2. 自分を input グループに入れる (再ログインで反映)
sudo usermod -aG input "$USER"

# 3. uinput デバイスに input グループからアクセスできるよう udev ルールを置く
echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' \
  | sudo tee /etc/udev/rules.d/99-xremap-uinput.rules
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### 適用

```bash
# 初回
nix run home-manager/master -- switch --flake ~/dotfiles#$USER-gui@$(uname -m)-linux
# 2 回目以降
home-manager switch --flake ~/dotfiles#$USER-gui@$(uname -m)-linux
```

### 確認

```bash
systemctl --user status xremap   # active (running) になっている
```

- 再ログイン後の成功条件:
  - **ブラウザ/エディタ**で Cmd(Super)+C / V がコピー/貼付として効く。
  - **ターミナル**で Cmd+C がコピー、**Ctrl+C は従来どおり中断 (SIGINT)** になる。
- 効かない/振り分けが変な場合は `journalctl --user -u xremap` でログを確認。特に
  アプリ判別 (application) が効かないときは GNOME 拡張が有効か、`xremap --watch` で
  出るアプリ名が `config.yml` の一覧と一致しているかを見て調整する。
- **systemd の無い環境**では user サービスが起動しないので、
  `xremap ~/.config/xremap/config.yml` を自前で (ログインスクリプト等から) 起動する。

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

設定の実体はリポジトリの `.config/tmux/tmux.conf` に一本化している。
`nix/home/tmux.nix` が `~/.config/tmux/tmux.conf` からここへ `mkOutOfStoreSymlink`
するので、macOS ホストでも VM でも同じファイルを読む (単一ソース)。
作業ツリーを直接指しているため、編集したら `prefix + r` で即反映される (`hm-switch` は不要)。
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

store パスを含むなど Nix でしか書けない設定は `~/.config/tmux/nix.conf` として
home-manager が生成し、`tmux.conf` の末尾から `source-file -q` で読み込む
(後勝ちなので上書きが効く / Nix を使わない環境では `-q` により単に無視される):

- `default-shell` を zsh に固定 (`chsh` が失敗しても tmux 内は zsh)
- `tmux-256color` + truecolor override (LazyVim の配色のため)
- `escape-time 10` — 既定の 500ms だと nvim の `ESC` / `jj` が体感で遅れる
- `history-limit 50000`

`mode-keys vi` のようにリポジトリ側 (`.config/tmux/tmux.conf`) で定義している設定は、
後から潰さないよう `nix.conf` には置かないこと。

なお `programs.tmux` は使っていない。あれを有効にすると home-manager が
`~/.config/tmux/tmux.conf` の中身を生成してしまい、リポジトリの設定ファイルを
symlink で指せなくなるため、本体パッケージだけ入れて設定ファイルは自前で置いている。
代わりに `programs.tmux` が Linux で既定 ON にしていた `secureSocket` 相当として、
`tmux.nix` が `TMUX_TMPDIR=$XDG_RUNTIME_DIR` を export している
(ソケットを `/tmp` ではなく `/run/user/$UID` に置く)。これを落とすと
起動中の tmux サーバが新しいシェルから見えなくなるので、消さないこと。

## zellij

tmux の代替として併用している。キーバインド一覧・使い方は [zellij.md](zellij.md) を参照。

設定の実体は `.config/zellij/config.kdl` で、tmux と同じく `mkOutOfStoreSymlink` で
`~/.config/zellij/config.kdl` から指している。`programs.zellij` は使っているが、
`settings` / `extraConfig` を空のままにすること (どちらかを書くと HM が
`config.kdl` の中身を生成してしまい、symlink と衝突する)。

`enableZshIntegration` は明示的に `false` にしている。既定値は
`home.shell.enableShellIntegration` (= true) を継承するので、放っておくと
全ての対話シェルが zellij の中で自動起動する。起動は手動 (`zellij`) に任せる。

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
  zsh.nix              zsh + oh-my-zsh + 補完 / 履歴 (alias/対話設定は ~/.zshrc を source)
  git.nix              git 設定 + delta + gh
  lazygit.nix          lazygit
  neovim.nix           Neovim 本体 + LazyVim のランタイム依存 + nvim 設定のリンク
  vim.nix              本物の Vim (vim-full) + .vimrc のリンク
  tmux.nix             tmux (tmux.conf のリンク + 環境依存分の nix.conf 生成)
  zellij.nix           zellij (config.kdl のリンク。詳細は docs/zellij.md)
  keymap.nix           GUI 付き Linux 専用のキー再マップ (xremap, Cmd→Ctrl)
  vscode.nix           VSCode 設定のリンク (macOS / GUI 付き Linux)
  hm-switch.nix        hm-switch コマンド (OS / GUI を判定して flake attribute を選ぶ)
```

## 設計上の判断

- **nvim 設定は Nix で宣言的に固めない。** `nix/home/neovim.nix` は
  `~/.config/nvim` をリポジトリ内の `.config/nvim` へ `mkOutOfStoreSymlink` で
  リンクするだけ。通常の `xdg.configFile` だと nix store への読み取り専用リンクに
  なって VM 上で試行錯誤できないため。Nix 側はランタイム依存 (ripgrep, fd, gcc,
  tree-sitter) と LSP の供給に徹する。
- **`targets.genericLinux.enable = !isDarwin`。** 非 NixOS の Linux でロケールや
  `XDG_DATA_DIRS` が壊れるのを防ぐ。macOS では自動で無効。NixOS 上で使う場合は
  `nix/home/default.nix` で明示的に false にする。
- **`programs.bash.initExtra` で zsh に exec している。** `chsh` が使えない VM
  (コンテナ等) でも対話シェルが zsh になる保険。
- **GUI の有無は `gui` フラグで明示的に切り替える。** Nix は評価時に desktop 環境の
  有無を判定できないので、`flake.nix` が `$USER@…` (gui 無し) と `$USER-gui@…`
  (gui 有り, Linux のみ) の2構成を生成する。`keymap.nix` は `pkgs.stdenv.isLinux && gui`
  で `mkIf` ガードしており、macOS / ヘッドレス Linux では空になる。

## 注意

- lazygit / LazyVim のアイコン表示にはターミナル側の Nerd Font が必要。
  使わない場合は `nix/home/lazygit.nix` の `nerdFontsVersion` を `""` にする。
- `home.stateVersion` は初回導入時のバージョンを表す。動いた後に上げない。
