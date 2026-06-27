# キーバインド早見表

Vim 系の操作を **VSCode / Cursor（VSCodeVim）** と **Neovim（LazyVim）** で揃えるための一覧。
leader キーは両環境とも **Space**。

> VSCode / Cursor のキーバインドは `vscode/settings.json` の `vim.normalModeKeyBindingsNonRecursive`
> および `keybindings.json` で定義。`jj` / `ff` は dotfiles の `~/.vimrc` から読み込む。

---

## モード切り替え

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 挿入 → ノーマル | `jj` | `jj` |
| ビジュアル → ノーマル | `ff` | `ff` |
| モード判別 | カーソル形状（ノーマル=ブロック / 挿入=縦線） | lualine（ステータスライン）＋カーソル |

## ペイン / フォーカス移動

Neovim の「ウィンドウ」= VSCode の「エディタグループ（分割）」。

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 左 / 下 / 上 / 右へ移動 | `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` | `Ctrl+h` / `Ctrl+j` / `Ctrl+k` / `Ctrl+l` |
| エクスプローラーへ | `Space e`（または `Ctrl+h` で左へ） | `Space e`（neo-tree） |
| ターミナルへ | `Ctrl+j`（下のパネルへ） | `Ctrl+/`（ターミナルトグル） |

> VSCode ではターミナル/エクスプローラー側からも `Ctrl+h/j/k/l` で戻れる（`keybindings.json` で定義）。
> ただしターミナル内の `Ctrl+l` だけはシェルの「画面クリア」を優先。

## バッファ / タブ移動

Neovim の「バッファ」= VSCode の「エディタ（タブ）」。

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 前のバッファ | `Shift+h` / `[b` | `Shift+h` / `[b` |
| 次のバッファ | `Shift+l` / `]b` | `Shift+l` / `]b` |
| バッファを閉じる | `Space b d` | `Space b d` |

## ウィンドウ分割

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 縦分割（左右に並ぶ） | `Space \|` | `Space \|` |
| 横分割（上下に並ぶ） | `Space -` | `Space -` |

## 検索・探索（LazyVim の Telescope 相当）

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| ファイル検索 | `Space Space` / `Space f f` | `Space Space` / `Space f f` |
| バッファ一覧 | `Space f b` | `Space f b` |
| 最近開いた | `Space f r` | `Space f r` |
| 全文検索（grep） | `Space /` / `Space s g` | `Space /` / `Space s g` |
| シンボル検索 | `Space s s` | `Space s s` |
| コマンド検索 | `Space :` | `Space :` |

## 定義ジャンプ / LSP

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 定義へジャンプ | `gd`（ネイティブ `F12`） | `gd` |
| 宣言へ | `gD` | `gD` |
| 参照一覧 | `Shift+F12` | `gr` |
| 実装へ | `Ctrl+F12` | `gI` |
| 型定義へ | （コマンド） | `gy` |
| ホバー（型情報） | `gh` / `K` | `K` |
| 定義をプレビュー（peek） | `Alt+F12` | — |

## ジャンプ後の戻る / 進む

ここだけ環境差あり。

| 操作 | VSCode / Cursor | Neovim (LazyVim) |
| --- | --- | --- |
| 戻る | `Ctrl+-`（macOS） | `Ctrl+o` |
| 進む | `Ctrl+Shift+-`（macOS） | `Ctrl+i` |
