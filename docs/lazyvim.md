# LazyVim

Neovim（0.12）＋ LazyVim の使い方。設定はほぼ LazyVim のデフォルトで、キーバインドも独自追加していない。

- 導入: [nix/home/neovim.nix](../nix/home/neovim.nix)（neovim 本体と ripgrep / fd / LSP などのランタイム依存）
- 設定の実体: [.config/nvim/](../.config/nvim/) → `~/.config/nvim` にディレクトリごと symlink
- VSCode / Cursor と揃えているキーの対応表は [keybindings.md](keybindings.md)

```
nvim              # カレントディレクトリで起動（ダッシュボードが出る）
nvim <file>       # ファイルを開く
nvim .            # ディレクトリを開く
```

---

## まず読むべき3つ

### 1. leader は `Space`。押して待てばメニューが出る

`Space` を押して少し待つと which-key のポップアップに**次に押せるキーの一覧**が出る。
`Space f`（file）、`Space s`（search）、`Space g`（git）…とグループになっているので、覚えていなくても辿れる。
キー操作全体を検索したいときは `Space s k`（Keymaps）。

### 2. `jj` / `ff` は Neovim では効かない

[keybindings.md](keybindings.md) では `jj`（挿入 → ノーマル）/ `ff`（ビジュアル → ノーマル）を両環境共通としているが、
これは `~/.vimrc` の設定で、**Neovim は `~/.vimrc` を読まない**。
[.config/nvim/lua/config/keymaps.lua](../.config/nvim/lua/config/keymaps.lua) も空なので、Neovim では `Esc` を使う。
揃えたい場合は `keymaps.lua` に以下を足す:

```lua
vim.keymap.set("i", "jj", "<Esc>", { silent = true })
vim.keymap.set("x", "ff", "<Esc>", { silent = true })
```

### 3. 困ったら `:Lazy` と `:checkhealth`

プラグインの状態確認・更新は `Space l`（`:Lazy`）。LSP やツールが動かないときは `:checkhealth` と `:LspInfo`。

---

## 基本操作

| キー | 動作 |
| --- | --- |
| `Ctrl+s` | 保存（ノーマル / 挿入 / ビジュアルどこでも） |
| `Space q q` | 全部閉じて終了 |
| `Esc` | ノーマルモードへ ＋ 検索ハイライトを消す |
| `Space f n` | 新規ファイル |
| `Alt+j` / `Alt+k` | 行（選択範囲）を下 / 上へ移動 |
| `gcc` / `gc`（ビジュアル） | コメントのトグル |
| `gco` / `gcO` | 下 / 上にコメント行を追加 |
| `Space u w` | 折り返しのトグル |
| `Space u l` / `Space u L` | 行番号 / 相対行番号のトグル |

## ファイル・検索（snacks.picker）

| キー | 動作 |
| --- | --- |
| `Space Space` / `Space f f` | ファイル検索（プロジェクトルート） |
| `Space f F` | ファイル検索（カレントディレクトリ） |
| `Space f g` | git 管理下のファイルだけ検索 |
| `Space f r` | 最近開いたファイル |
| `Space ,` / `Space f b` | 開いているバッファ一覧 |
| `Space f c` | Neovim の設定ファイルを検索 |
| `Space /` / `Space s g` | 全文検索（grep） |
| `Space s w` | カーソル下の単語（ビジュアルなら選択範囲）で grep |
| `Space s b` | 現在のバッファ内を検索 |
| `Space s r` | 検索と置換（grug-far） |
| `Space s k` | キーマップ一覧 |
| `Space s h` | ヘルプ検索 |
| `Space s R` | 直前の検索を再開 |
| `Space :` | コマンド履歴 |

**picker 内の操作**

| キー | 動作 |
| --- | --- |
| `Enter` | 開く |
| `Ctrl+v` / `Ctrl+s` | 縦分割 / 横分割で開く |
| `Tab` | 複数選択 |
| `Ctrl+q` | 選択（なければ全件）を quickfix へ送る |
| `Alt+h` / `Alt+i` | 隠しファイル / .gitignore 対象の表示トグル |
| `Alt+p` | プレビューのトグル |
| `Esc` | 閉じる |
| `?` | picker のキー一覧 |

## エクスプローラー（snacks.explorer）

`Space e` でプロジェクトルート、`Space E` でカレントディレクトリを開く。
LazyVim 標準は neo-tree ではなく snacks の explorer。この dotfiles では隠しファイルも表示する設定にしてある
（[plugins/snacks.lua](../.config/nvim/lua/plugins/snacks.lua)）。

| キー | 動作 |
| --- | --- |
| `l` / `Enter` | 開く（ディレクトリなら展開） |
| `h` | ディレクトリを閉じる |
| `Backspace` | 親ディレクトリへ |
| `a` | 新規作成（末尾を `/` にするとディレクトリ） |
| `r` | リネーム |
| `d` | 削除 |
| `c` / `m` | コピー / 移動 |
| `y` / `p` | ヤンク / ペースト |
| `o` | OS のアプリで開く |
| `H` / `I` | 隠しファイル / .gitignore 対象の表示トグル |
| `Z` | 全部たたむ |
| `]g` / `[g` | 次 / 前の git 変更ファイルへ |
| `?` | キー一覧 |

## バッファ / ウィンドウ / タブ

Neovim の「バッファ」= 開いているファイル（上のタブバーに並ぶもの）。
Neovim の「タブ」はウィンドウ配置のセットで、VSCode のタブとは別物。普段はバッファだけで足りる。

| キー | 動作 |
| --- | --- |
| `Shift+h` / `Shift+l` | 前 / 次のバッファ（`[b` / `]b` も同じ） |
| `` Space ` `` / `Space b b` | 直前のバッファと行き来 |
| `Space b d` | バッファを閉じる |
| `Space b o` | 他のバッファを全部閉じる |
| `Space b p` | バッファをピン留め（`Space b P` でピン以外を閉じる） |
| `Space \|` / `Space -` | 左右 / 上下に分割 |
| `Ctrl+h/j/k/l` | 左 / 下 / 上 / 右のウィンドウへ |
| `Ctrl+←/→/↑/↓` | ウィンドウのリサイズ |
| `Space w d` | ウィンドウを閉じる |
| `Space w m` | ウィンドウを最大化（ズーム）トグル |
| `Space Tab Tab` | 新規タブ |
| `Space Tab ]` / `Space Tab [` | 次 / 前のタブ |
| `Space Tab d` | タブを閉じる |

> `Ctrl+h/j/k/l` は **Neovim 内のウィンドウ移動だけ**。tmux のペインまでは越えない
> （vim-tmux-navigator は入れていない）。tmux 側は `Ctrl+q` `h/j/k/l` で移動する（[tmux.md](tmux.md)）。

## 移動・編集

| キー | 動作 |
| --- | --- |
| `s` + 2文字 | flash: 画面内の任意の場所へジャンプ（ラベルの文字を押す） |
| `S` | flash: treesitter の構文単位で選択 |
| `Ctrl+Space` | 構文単位で選択範囲を広げる（連打で拡大） |
| `Ctrl+o` / `Ctrl+i` | ジャンプを戻る / 進む |
| `]d` / `[d` | 次 / 前の診断（`]e` `[e` はエラーのみ、`]w` `[w` は警告のみ） |
| `]t` / `[t` | 次 / 前の TODO コメント |
| `[Space` / `]Space` | 上 / 下に空行を追加 |

テキストオブジェクトは mini.ai で拡張されている。`vaf`（関数全体）、`vif`（関数の中身）、
`vac`（クラス）、`vi(` / `va"` など。`an` / `in` は「次の」オブジェクトを対象にする。

## LSP / コード

LSP が起動したバッファでだけ効く。

| キー | 動作 |
| --- | --- |
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `gI` | 実装へ |
| `gy` | 型定義へ |
| `gD` | 宣言へ |
| `K` | ホバー（型情報・ドキュメント） |
| `gK` | シグネチャヘルプ |
| `Space c a` | コードアクション |
| `Space c r` | リネーム |
| `Space c f` | フォーマット（保存時にも自動で走る） |
| `Space c d` | カーソル行の診断を表示 |
| `Space s s` | シンボル検索（ファイル内） |
| `Space s d` | 診断一覧 |
| `Space x x` | 診断一覧（Trouble） |
| `Space u f` | 保存時フォーマットのオン / オフ |
| `Space u h` | インレイヒントのトグル |

補完（blink.cmp）: `Ctrl+n` / `Ctrl+p` で候補移動、`Enter` で確定、`Ctrl+e` で閉じる、`Ctrl+Space` で手動表示。

LSP サーバ本体は [neovim.nix](../nix/home/neovim.nix) で入れている（TypeScript / Python / Go / Nix / Lua / Markdown）。
足りない言語は `Space c m`（`:Mason`）から入れるか、`:LazyExtras` で言語の extra を有効にする。

## Git

| キー | 動作 |
| --- | --- |
| `Space g g` | lazygit を開く（プロジェクトルート） |
| `Space g s` | git status |
| `Space g d` | 変更箇所（hunk）一覧 |
| `Space g b` | カーソル行の blame |
| `Space g f` | 現在のファイルの履歴 |
| `Space g l` | git log |
| `Space g B` | GitHub などのブラウザで開く |
| `]h` / `[h` | 次 / 前の hunk |
| `Space g h s` / `Space g h r` | hunk を stage / reset |
| `Space g h p` | hunk をプレビュー |

## ターミナル

| キー | 動作 |
| --- | --- |
| `Ctrl+/` | 下部のターミナルをトグル（ターミナル内でも効く） |
| `Space f t` / `Space f T` | ターミナル（ルート / カレントディレクトリ） |
| `Esc Esc` | ターミナルモードからノーマルモードへ |

## セッション

ディレクトリごとに開いていたバッファ・ウィンドウ配置が自動保存される（persistence.nvim）。

| キー | 動作 |
| --- | --- |
| `Space q s` | このディレクトリの前回セッションを復元 |
| `Space q l` | 最後のセッションを復元 |
| `Space q S` | セッションを選んで復元 |
| `Space q d` | 今回はセッションを保存しない |

---

## 設定の変更

実体は `~/dotfiles/.config/nvim/`。`~/.config/nvim` からディレクトリごと直リンクしているので、
**編集して Neovim を起動し直せば反映**される（`hm-switch` は不要）。

| ファイル | 用途 |
| --- | --- |
| `lua/config/options.lua` | `vim.opt` の設定 |
| `lua/config/keymaps.lua` | 独自キーマップ（現在は空） |
| `lua/config/autocmds.lua` | autocmd |
| `lua/plugins/*.lua` | プラグインの追加・上書き。ファイルを置くだけで読み込まれる |
| `lazyvim.json` | `:LazyExtras` で有効にした extra の一覧（現在は `lang.markdown`） |
| `lazy-lock.json` | プラグインのバージョン固定。更新したらコミットする |

この dotfiles で LazyVim のデフォルトから変えている点:

- [plugins/colorscheme.lua](../.config/nvim/lua/plugins/colorscheme.lua): tokyonight を背景透過にする（ターミナル側の透過を活かす）。補完メニューと which-key は読みやすさのため不透明のまま
- [plugins/snacks.lua](../.config/nvim/lua/plugins/snacks.lua): エクスプローラーで隠しファイルを表示する
- [plugins/example.lua](../.config/nvim/lua/plugins/example.lua): LazyVim のサンプル。先頭で `return {}` しているので何も読み込まない

プラグインを足すときは `lua/plugins/` に新しいファイルを作る:

```lua
-- lua/plugins/foo.lua
return {
  { "author/foo.nvim", opts = {} },
}
```

## よく使うコマンド

| コマンド | 動作 |
| --- | --- |
| `:Lazy` | プラグイン管理（`U` で更新、`S` で lock に合わせて同期） |
| `:LazyExtras` | 言語サポートなどの extra を有効化 / 無効化（`x` でトグル） |
| `:Mason` | LSP / フォーマッタ / リンタのインストール |
| `:LspInfo` | 現在のバッファに付いている LSP |
| `:ConformInfo` | 使われるフォーマッタ |
| `:checkhealth` | 環境の診断 |
