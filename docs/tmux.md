# tmux

端末マルチプレクサ。1つの端末の中でペイン分割・ウィンドウ（タブ）切り替えを行い、
デタッチしてもプロセスが生き続ける（SSH が切れても作業が残る）。

- 導入: [nix/home/tmux.nix](../nix/home/tmux.nix)（tmux 本体と、環境依存分の `~/.config/tmux/nix.conf` を生成）
- 設定の実体: [.config/tmux/tmux.conf](../.config/tmux/tmux.conf) → `~/.config/tmux/tmux.conf` に symlink
- **prefix は `Ctrl+q`**（デフォルトの `Ctrl+b` から変更）

```
tmux                   # 新規セッション
tmux new -s work       # 名前を付けて新規セッション
tmux ls                # セッション一覧
tmux a                 # 最後のセッションに attach
tmux a -t work         # 指定したセッションに attach
```

---

## まず読むべき2つ

### 1. 操作はすべて「prefix → キー」

`Ctrl+q` を押して**離してから**1キー押す。以下の表で `Ctrl+q` `|` と書いてあれば、
`Ctrl+q` → `|` の順に押すという意味。

`Ctrl+q` を2回押すと、tmux の中のプログラムに `Ctrl+q` そのものが送られる。

### 2. 用語

| tmux | 意味 | ざっくり言うと |
| --- | --- | --- |
| session | ウィンドウの集まり。デタッチしても残る | 作業単位（プロジェクトごとに1つ） |
| window | 画面全体。下のステータスバーに並ぶ | タブ |
| pane | window を分割した1区画 | 分割 |

---

## ペイン

| キー | 動作 |
| --- | --- |
| `Ctrl+q` `\|` | 左右に分割 ★ |
| `Ctrl+q` `v` | 上下に分割 ★ |
| `Ctrl+q` `h` `j` `k` `l` | 左 / 下 / 上 / 右のペインへ移動 ★ |
| `Ctrl+q` 矢印 | 同上（デフォルト） |
| `Ctrl+q` `z` | ペインを全画面トグル |
| `Ctrl+q` `x` | ペインを閉じる（確認あり） |
| `Ctrl+q` `q` | ペイン番号を表示（表示中に番号を押すとそこへ移動） |
| `Ctrl+q` `o` | 次のペインへ順送り |
| `Ctrl+q` `{` / `}` | ペインの位置を前 / 後と入れ替え |
| `Ctrl+q` `Space` | レイアウトを順に切り替え |
| `Ctrl+q` `Ctrl+矢印` | ペインのリサイズ（押しっぱなしで連続） |
| `Ctrl+q` `!` | ペインを新しいウィンドウに切り出す |

★ はこの dotfiles で追加したキー。デフォルトの `"`（上下分割）/ `%`（左右分割）もそのまま使える。
マウスも有効なので、クリックでペイン選択、境界のドラッグでリサイズもできる。

> `Ctrl+q` `l` はデフォルトでは「直前のウィンドウへ」だが、ペイン移動に上書きしているので使えない。

## ウィンドウ

| キー | 動作 |
| --- | --- |
| `Ctrl+q` `c` | 新規ウィンドウ |
| `Ctrl+q` `n` / `p` | 次 / 前のウィンドウ |
| `Ctrl+q` `0`〜`9` | 番号でウィンドウへ移動 |
| `Ctrl+q` `,` | ウィンドウ名を変更 |
| `Ctrl+q` `&` | ウィンドウを閉じる（確認あり） |
| `Ctrl+q` `w` | セッション・ウィンドウをツリーから選ぶ |

## セッション

| キー | 動作 |
| --- | --- |
| `Ctrl+q` `d` | デタッチ（セッションは裏で動き続ける） |
| `Ctrl+q` `s` | セッション・ウィンドウをツリーから選ぶ ★（`w` と同じ。デフォルトはセッションだけのツリー） |
| `Ctrl+q` `$` | セッション名を変更 |
| `Ctrl+q` `(` / `)` | 前 / 次のセッションへ |

ツリー表示の中では `j` / `k` で移動、`Enter` で決定、`x` で kill、`q` で閉じる。

## コピーモード（スクロールバック）

vi 風のキー操作にしてある。履歴は 50000 行まで残る。

| キー | 動作 |
| --- | --- |
| `Ctrl+q` `[` | コピーモードに入る（マウスホイールで上にスクロールしても入る） |
| `h` `j` `k` `l` / `w` `b` / `Ctrl+u` `Ctrl+d` | vim と同じ移動 |
| `/` / `?` | 下 / 上へ検索（`n` / `N` で次 / 前） |
| `v` | 選択開始 ★ |
| `Ctrl+v` | 矩形選択の切り替え ★ |
| `y` | コピーしてコピーモードを抜ける。**OS のクリップボードにも入る** ★ |
| `Esc` | 選択を解除 |
| `q` | コピーモードを抜ける |
| `Ctrl+q` `]` | tmux 内のバッファから貼り付け |

`y` のクリップボード連携は macOS では `pbcopy`、Linux では `wl-copy`（なければ `xclip`）を使う。

## その他

| キー | 動作 |
| --- | --- |
| `Ctrl+q` `r` | 設定ファイルを再読み込み（`Reloaded!` と表示）★ |
| `Ctrl+q` `:` | tmux のコマンドを入力（vi 操作） |
| `Ctrl+q` `?` | キーバインドの一覧 |
| `Ctrl+q` `t` | 時計を表示 |

---

## CLI

| コマンド | 動作 |
| --- | --- |
| `tmux new -s <name>` | 名前を付けて新規セッション |
| `tmux new -A -s <name>` | あれば attach、なければ作成 |
| `tmux ls` | セッション一覧 |
| `tmux a -t <name>` | attach |
| `tmux kill-session -t <name>` | セッションを終了 |
| `tmux kill-server` | 全セッションを終了 |
| `tmux source ~/.config/tmux/tmux.conf` | 設定を再読み込み（tmux 外から） |
| `tmux list-keys` | 全キーバインドを出力 |

## 設定の変更

実体は `~/dotfiles/.config/tmux/tmux.conf`。`~/.config/tmux/tmux.conf` から作業ツリーを直接指しているので、
**編集したら `Ctrl+q` `r` で即反映**される（`hm-switch` は不要）。

store パスを含む設定など Nix でしか書けないものは [tmux.nix](../nix/home/tmux.nix) が
`~/.config/tmux/nix.conf` として生成し、`tmux.conf` の末尾で読み込む（後勝ち）。中身は:

| 設定 | 理由 |
| --- | --- |
| `default-shell` = Nix の zsh | `chsh` が失敗していても tmux 内は zsh にする |
| `default-terminal "tmux-256color"` ＋ `Tc` | truecolor（LazyVim の配色のため） |
| `history-limit 50000` | スクロールバックを増やす |
| `escape-time 10` | デフォルトの 500ms だと Neovim の `Esc` が遅れる |

Nix を使わない環境では `nix.conf` が無いだけで、エラーにはならない。

## Neovim と一緒に使うとき

- Neovim のウィンドウ移動（`Ctrl+h/j/k/l`）と tmux のペイン移動（`Ctrl+q` `h/j/k/l`）は**別物**。
  Neovim から隣の tmux ペインへは `Ctrl+q` を挟む。
- `Ctrl+q` は tmux が先に取るので、Neovim やシェルに `Ctrl+q` を送りたいときは `Ctrl+q` `Ctrl+q`。
- 配色がおかしい（色数が少ない）ときは tmux 内で `echo $TERM` が `tmux-256color` になっているか確認する。
  変えた後は一度 `tmux kill-server` してから起動し直す（`default-terminal` はリロードでは既存ペインに効かない）。

LazyVim の操作は [lazyvim.md](lazyvim.md)、tmux の代替として試している zellij との対応表は [zellij.md](zellij.md#tmux-との対応) を参照。
