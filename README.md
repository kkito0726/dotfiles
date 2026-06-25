# dotfiles

個人用の設定ファイル（dotfiles）を集約し、シンボリックリンクで `$HOME` 以下へ展開して管理するリポジトリ。

## 管理対象

| リポジトリ内のパス | リンク先 | 用途 |
| --- | --- | --- |
| `.vimrc` | `~/.vimrc` | Vim 設定 |
| `.ideavimrc` | `~/.ideavimrc` | IntelliJ (IdeaVim) 設定 |
| `.config/nvim/init.lua` | `~/.config/nvim/init.lua` | Neovim 設定 |
| `.config/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | WezTerm 本体設定 |
| `.config/wezterm/keybinds.lua` | `~/.config/wezterm/keybinds.lua` | WezTerm キーバインド |

## セットアップ

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` がリポジトリ内のファイルを、**リポジトリルートからの相対パスを保ったまま** `$HOME` 以下へシンボリックリンクする。

```
~/dotfiles/.config/wezterm/wezterm.lua  ->  ~/.config/wezterm/wezterm.lua
```

## install.sh

| コマンド | 動作 |
| --- | --- |
| `./install.sh` | リンクを作成（既存ファイルは確認のうえバックアップして置き換え） |
| `./install.sh --dry-run` | 実際には変更せず、何が起きるかだけ表示 |
| `./install.sh --force` | 確認なしで既存ファイルを置き換え（バックアップは必ず取る） |
| `./install.sh --help` | ヘルプを表示 |

### 仕様

- **冪等**: 既に正しいリンクが張られていれば `skip`。何度実行しても安全。
- **バックアップ**: リンク先に実体ファイルがある場合、`~/.dotfiles-backup/<日時>/` へ退避してからリンクを張る。
- **除外**: `.git` / `install.sh` / `README.md` などはリンク対象外（`install.sh` の `EXCLUDES` で管理）。
- **例外マッピング**: 実体の位置とリンク先を変えたい場合は `install.sh` の `LINK_MAP` に
  `"リポジトリ内の相対パス:$HOME からのリンク先"` を追加する。

## 運用メモ

- ファイルの**中身を編集**しただけなら `install.sh` の再実行は不要（実体は1つで、リンク経由でそのまま反映される）。
- **新しいファイルを管理対象に追加**したときだけ `install.sh` を再実行する。
- 既存の `~/xxx` を管理下に置くには、実体をリポジトリへ移動してから `install.sh` を実行する。

  ```sh
  mv ~/.gitconfig ~/dotfiles/.gitconfig
  cd ~/dotfiles && ./install.sh
  ```
