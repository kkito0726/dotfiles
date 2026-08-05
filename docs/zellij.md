# zellij

tmux の代替として試している端末マルチプレクサ。tmux と併用できる（自動起動はしない）。

- 導入: [nix/home/zellij.nix](../nix/home/zellij.nix)（`programs.zellij`, zellij 0.44.3）
- 設定の実体: [.config/zellij/config.kdl](../.config/zellij/config.kdl) → `~/.config/zellij/config.kdl` に symlink
- **キーバインドは zellij のデフォルトのまま**。このドキュメントはその一覧。

```
zellij            # 新規セッション
zellij -s work    # 名前を付けて新規セッション
zellij ls         # セッション一覧
zellij a work     # 既存セッションに attach
```

---

## まず読むべき2つ

### 1. tmux の「prefix」ではなく「モード」

tmux は `prefix` を押してから1キー。zellij は**モードに入り、そのモードに居続ける**。
ペインを3つ作るなら `Ctrl+p` を1回押して `n n n`（`Ctrl+p` を毎回押し直さなくてよい）。

モードを抜けるのは `Enter` または `Esc`。今どのモードかは画面下のステータスバーに出る。

### 2. `Ctrl+q` は「zellij 終了」

tmux の prefix が `Ctrl+q` なので、指が覚えたまま押すと**セッションごと終了する**（確認なし）。
最初に踏む地雷なのでここだけ先に覚えておく。避けたい場合は後述の [Ctrl キーの衝突](#ctrl-キーの衝突と-locked-mode) を参照。

---

## モード一覧

| モードへ入る | モード | 用途 |
| --- | --- | --- |
| `Ctrl+p` | pane | ペインの作成 / 移動 / 分割 / 全画面 |
| `Ctrl+t` | tab | タブの作成 / 移動 / リネーム |
| `Ctrl+n` | resize | ペインのリサイズ |
| `Ctrl+h` | move | ペインの位置そのものを入れ替える |
| `Ctrl+s` | scroll | スクロールバックの閲覧 / 検索 |
| `Ctrl+o` | session | デタッチ / セッション一覧 / 設定画面 |
| `Ctrl+b` | tmux | tmux 風のキーで操作する互換モード |
| `Ctrl+g` | locked | **全キーを下のプログラムに素通しする** |
| `Enter` / `Esc` | → normal | どのモードからでも戻る |

`Ctrl+q` は Quit（locked 以外のどのモードでも効く）。

## モードに入らずに使えるキー

実際はこれだけで大体足りる。**locked モードでも効く**のがポイント。

| キー | 動作 |
| --- | --- |
| `Alt+h` / `Alt+l` | 左 / 右のペインへ移動（端まで行くと隣のタブへ） |
| `Alt+j` / `Alt+k` | 下 / 上のペインへ移動 |
| `Alt+n` | 新規ペイン |
| `Alt+f` | フローティングペインの表示 / 非表示 |
| `Alt+=` / `Alt+-` | フォーカス中のペインを拡大 / 縮小 |
| `Alt+i` / `Alt+o` | タブを左 / 右へ移動 |
| `Alt+[` / `Alt+]` | レイアウトを切り替える（swap layout） |

> **macOS の注意**: Option キーが Meta として送られないと `Alt+*` が全滅する。
> WezTerm なら `send_composed_key_when_left_alt_is_pressed = false`、
> Ghostty なら `macos-option-as-alt = true` を設定する。

## pane モード（`Ctrl+p`）

| キー | 動作 |
| --- | --- |
| `h` `j` `k` `l` / 矢印 | フォーカス移動 |
| `p` | 次のペインへ（順送り） |
| `n` | 新規ペイン |
| `d` | 下に分割 |
| `r` | 右に分割 |
| `s` | スタックペインとして追加 |
| `x` | ペインを閉じる |
| `f` | 全画面トグル（tmux の `prefix z`） |
| `w` | フローティングペインのトグル |
| `e` | 埋め込み ↔ フローティングを切り替える |
| `i` | フローティングペインをピン留め（常に最前面） |
| `z` | ペイン枠の表示 / 非表示 |
| `c` | ペイン名をリネーム |

## tab モード（`Ctrl+t`）

| キー | 動作 |
| --- | --- |
| `n` | 新規タブ |
| `x` | タブを閉じる |
| `r` | タブをリネーム |
| `1` 〜 `9` | その番号のタブへ |
| `h` `k` / 左 上 | 前のタブ |
| `l` `j` / 右 下 | 次のタブ |
| `Tab` | 直前のタブとトグル |
| `s` | 同期モード（全ペインに同じ入力を送る） |
| `b` | フォーカス中のペインを新しいタブへ切り出す |
| `[` / `]` | ペインを左 / 右のタブへ移す |

## resize モード（`Ctrl+n`）

| キー | 動作 |
| --- | --- |
| `h` `j` `k` `l` | その方向へ広げる |
| `H` `J` `K` `L` | その方向を縮める |
| `=` / `-` | 拡大 / 縮小 |

## move モード（`Ctrl+h`）

フォーカスではなく**ペインの配置そのもの**を動かす。

| キー | 動作 |
| --- | --- |
| `h` `j` `k` `l` | その方向へペインを移動 |
| `n` / `Tab` | 次の位置へ送る |
| `p` | 前の位置へ送る |

## scroll モード（`Ctrl+s`）

| キー | 動作 |
| --- | --- |
| `j` / `k` | 1行スクロール |
| `d` / `u` | 半画面スクロール |
| `Ctrl+f` / `Ctrl+b` | 1画面スクロール |
| `s` | 検索を開始（`Enter` で確定 → search モード） |
| `e` | スクロールバック全体を nvim で開く |
| `Ctrl+c` | 最下部に戻って normal へ |

検索確定後（search モード）は `n` / `p` で次 / 前へ、`c` で大文字小文字、`w` で折り返し、`o` で単語単位をトグル。

> **コピー操作は tmux と違う**。zellij には `v` で選択開始…という copy-mode が無く、
> **マウスで選択した時点でクリップボードにコピーされる**（`copy_on_select` が既定で true）。
> キーボードだけで範囲コピーしたいときは `Ctrl+s` → `e` でスクロールバックを nvim に流して、
> nvim 側でヤンクするのが確実。
>
> なお `copy_command` は**設定していない**ので、クリップボードへの転送は端末の OSC 52 に依存する。
> ヘッドレス VM に SSH している場合は nvim のクリップボードと同じ制約を受ける
> （[nix-vm.md](nix-vm.md) の nvim / クリップボード の節を参照）。
> 端末が OSC 52 に対応していない環境では `.config/zellij/config.kdl` に
> `copy_command "wl-copy"`（Wayland）/ `"xclip -selection clipboard"`（X11）/ `"pbcopy"`（macOS）
> を書く。ただし KDL には OS 分岐が無いので、マシンごとに違う値が要るなら注意。

## session モード（`Ctrl+o`）

| キー | 動作 |
| --- | --- |
| `d` | デタッチ（tmux の `prefix d`） |
| `w` | セッションマネージャ（一覧・切り替え・リサレクト） |
| `c` | 設定画面をプラグインとして開く |
| `p` | プラグインマネージャ |
| `a` | zellij について |

## tmux モード（`Ctrl+b`）

tmux の指使いのまま操作できる互換モード。移行期の保険として用意されている。

| キー | 動作 |
| --- | --- |
| `"` / `%` | 下 / 右に分割 |
| `c` | 新規タブ |
| `,` | タブをリネーム |
| `n` / `p` | 次 / 前のタブ |
| `h` `j` `k` `l` / 矢印 | ペイン移動 |
| `o` | 次のペインへ |
| `z` | 全画面トグル |
| `x` | ペインを閉じる |
| `d` | デタッチ |
| `[` | scroll モードへ |
| `Space` | レイアウト切り替え |
| `Ctrl+b` | 下のプログラムに `Ctrl+b` を送る |

---

## Ctrl キーの衝突と locked mode

zellij はデフォルトで以下を**奪う**。normal モードでいる限り、下のシェルや nvim には届かない。

| キー | 本来の用途 | zellij での用途 |
| --- | --- | --- |
| `Ctrl+p` | zsh: 履歴を前へ / nvim: 補完候補を上へ | pane モード |
| `Ctrl+n` | zsh: 履歴を次へ / nvim: 補完候補を下へ | resize モード |
| `Ctrl+o` | **nvim: ジャンプを戻る** | session モード |
| `Ctrl+h` | **nvim / VSCode: 左のウィンドウへ**（[keybindings.md](keybindings.md) 参照） | move モード |
| `Ctrl+s` | 端末フリーズ（XOFF） | scroll モード |
| `Ctrl+t` | zsh: fzf ファイル検索 | tab モード |
| `Ctrl+q` | tmux の prefix | **zellij を終了** |

**対処は `Ctrl+g`（locked モード）**。入るとステータスバーが `LOCKED` になり、上の全部が素通しになる。
`Alt+*` 系だけは locked でも効くので、ペイン移動・新規ペインには困らない。zellij を操作したいときだけ
`Ctrl+g` で解除し、また `Ctrl+g` で施錠する、という使い方が現実的。

nvim を多用するなら**起動時から locked にしてしまう**のが楽。`.config/zellij/config.kdl` に1行:

```kdl
default_mode "locked"
```

`Ctrl+q` だけ潰したい場合は、キーバインド全体を上書きせず該当分だけ書く（動作確認済み）:

```kdl
keybinds {
    shared_except "locked" {
        unbind "Ctrl q"
    }
}
```

---

## CLI

| コマンド | 動作 |
| --- | --- |
| `zellij` | 新規セッション（名前は自動生成） |
| `zellij -s <name>` | 名前を付けて新規セッション |
| `zellij ls` | セッション一覧（終了済みのものも出る） |
| `zellij a <name>` | attach。終了済みセッションなら復元して再開する |
| `zellij a -c <name>` | 無ければ作って attach |
| `zellij k <name>` | セッションを kill |
| `zellij d <name>` | セッションを削除（復元用データごと消す） |
| `zellij ka` / `zellij da` | 全セッションを kill / 削除 |
| `zellij run -- <cmd>` | 新しいペインでコマンドを実行 |
| `zellij edit <file>` | 新しいペインで `$EDITOR` を開く |
| `zellij setup --dump-config` | デフォルト設定を全部出力（設定の辞書代わり） |
| `zellij setup --check` | 設定ファイルのパースと各種パスの確認 |

セッションは終了しても復元用データが残るので、`zellij ls` に出ているものは
`zellij a` でペイン構成ごと復活する（tmux には無い挙動）。

## 設定の変更

実体は `~/dotfiles/.config/zellij/config.kdl`。`~/.config/zellij/config.kdl` から
`mkOutOfStoreSymlink` で作業ツリーを直接指しているので、**編集したら zellij を起動し直すだけで反映**される
（`hm-switch` は不要）。変更したら `zellij setup --check` でパースを確認する。

キーバインドを変えたいときは、`keybinds` ブロックに**変えたい bind だけ**を書く。
ブロックごと書いてもデフォルトは消えない（`keybinds clear-defaults=true` にすると全部消える）。

## tmux との対応

現行の tmux 設定（prefix `Ctrl+q`, [.config/tmux/tmux.conf](../.config/tmux/tmux.conf)）との対比。

| 操作 | tmux | zellij |
| --- | --- | --- |
| 左右分割 | `Ctrl+q` `\|` | `Ctrl+p` `r` |
| 上下分割 | `Ctrl+q` `v` | `Ctrl+p` `d` |
| ペイン移動 | `Ctrl+q` `h/j/k/l` | `Alt+h/j/k/l` |
| ペインを閉じる | `Ctrl+q` `x` | `Ctrl+p` `x` |
| 全画面トグル | `Ctrl+q` `z` | `Ctrl+p` `f` |
| 新規タブ / ウィンドウ | `Ctrl+q` `c` | `Ctrl+t` `n` |
| 一覧から選ぶ | `Ctrl+q` `s` | `Ctrl+o` `w` |
| デタッチ | `Ctrl+q` `d` | `Ctrl+o` `d` |
| スクロールバック | `Ctrl+q` `[` | `Ctrl+s` |
| 設定リロード | `Ctrl+q` `r` | （再起動が必要） |
