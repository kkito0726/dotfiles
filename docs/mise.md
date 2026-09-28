# mise

プログラミング言語のバージョン管理ツール。Python / Node.js / Go / Java を mise で入れ、
ディレクトリごとに使うバージョンを切り替える。pyenv / nvm / goenv / SDKMAN の役割を1つにまとめたもの。

- 公式ドキュメント: <https://mise.jdx.dev>
- この手順は mise 2026.7.5（nixpkgs 版）で動作確認している

```
mise use -g python@3.14     # 普段使うバージョン（グローバル）を決める
mise use node@22            # このディレクトリだけ Node 22 にする（mise.toml ができる）
mise install                # mise.toml に書かれたものを全部入れる
mise ls                     # 入っているもの・使われているもの
```

---

## 方針

| 何を | どこで管理するか |
| --- | --- |
| mise 本体・シェル連携 | Nix（[nix/home/mise.nix](../nix/home/mise.nix)） |
| 普段使う言語のバージョン | `~/.config/mise/config.toml`（実体は [.config/mise/config.toml](../.config/mise/config.toml)） |
| プロジェクトごとのバージョン | 各プロジェクトの `mise.toml`（プロジェクト側で commit する） |
| 言語本体のインストール先 | `~/.local/share/mise/installs/`（リポジトリ管理外） |

言語は Nix ではなく mise で入れる。Nix だとパッチバージョンの指定やプロジェクトごとの切り替えが面倒で、
`.nvmrc` / `.python-version` を置いている既存プロジェクトともそのまま付き合えないため。

---

## 導入

dotfiles 側の設定は入っているので、Home Manager を適用するだけでよい（macOS / Linux 共通）。

### 1. 適用して言語を入れる

```sh
hm-switch            # mise 本体とシェル連携を入れる
exec zsh             # 新しいシェルで mise activate を効かせる
mise install         # config.toml の言語を全部入れる
mise doctor          # 問題が無いか確認（activated: yes になっていれば OK）
```

確認:

```sh
mise ls
which python node go java     # すべて ~/.local/share/mise/installs/... を指していれば OK
```

### 2. dotfiles 側の仕組み

**[nix/home/mise.nix](../nix/home/mise.nix)**

- `programs.mise` で mise 本体を入れ、zsh / bash に `eval "$(mise activate zsh)"` を差し込む。
- `~/.config/mise/config.toml` はリポジトリの `.config/mise/config.toml` を `mkOutOfStoreSymlink` で指す。
  `mise use -g` の結果がそのままリポジトリに残るので、変わったら commit する。
- `programs.mise.globalConfig` は使わない。値を書くと `config.toml` が nix store の読み取り専用ファイルになり、
  symlink と衝突するうえ `mise use -g` も書けなくなる。

**[.config/mise/config.toml](../.config/mise/config.toml)**

```toml
[tools]
python = "3.14"
node = "lts"
go = "1.27"
java = "temurin-25"

[settings]
# .nvmrc / .python-version / .go-version / .java-version も読む（既定は無効）
idiomatic_version_file_enable_tools = ["python", "node", "go", "java"]
```

- バージョンは前方一致。`"3.14"` なら 3.14 系の最新、`"lts"` は Node の最新 LTS。
- **Java は `temurin-` を付ける**。`java = "21"` のように数字だけだと OpenJDK 版になるが、OpenJDK 版は
  最新の非 LTS しか更新されず、21 系は 21.0.2 で止まっている。Temurin は LTS にパッチが出続ける。

### 3. pyenv / nvm との関係（macOS）

[zsh.nix](../nix/home/zsh.nix) の macOS ブロックには、Homebrew の pyenv / nvm を初期化する設定が残してある。
mise の `activate` はプロンプトのたびに自分のパスを PATH の先頭へ入れ直すので、両方あっても mise が優先される。

- **pyenv / nvm を入れていない Mac**（新しく Nix で構築した Mac など）では、`eval "$(pyenv init -)"` が
  `command not found: pyenv` をシェル起動のたびに出す。zsh.nix の macOS ブロックから
  `# pyenv: Python バージョン管理` 〜 `nvm/etc/bash_completion.d/nvm` までを消して `hm-switch` する
  （nvm の行はファイルの存在チェック付きなので害は無いが、使わないなら一緒に消す）。
- **pyenv / nvm から移行する場合**は、`~/.pyenv` / `~/.nvm` のグローバルパッケージ
  （`npm ls -g --depth=0` などで確認）を、後述の [CLI ツール](#cli-ツールもまとめて入れる) の方法で入れ直してから
  `brew uninstall pyenv nvm` する。

---

## 日常の使い方

### バージョンを決める

| コマンド | 動作 |
| --- | --- |
| `mise use -g node@lts` | グローバルのバージョンを変える（`~/.config/mise/config.toml` を書き換え） |
| `mise use python@3.12` | カレントディレクトリの `mise.toml` に書く（無ければ作る） |
| `mise use --pin node@22` | `22.23.3` のように完全なバージョンで固定して書く |
| `mise shell python@3.11` | 今のシェルだけ一時的に切り替える |
| `mise exec python@3.11 -- python x.py` | そのコマンドだけ別バージョンで実行（`mise x` でも可） |

`mise use` はインストールも同時に行う。グローバルを変えたら `.config/mise/config.toml` の差分を commit する。

### 状態を見る

| コマンド | 動作 |
| --- | --- |
| `mise ls` | 入っているバージョンと、どの設定ファイルから使われているか |
| `mise current` | カレントディレクトリで有効なバージョン |
| `mise ls-remote node` | インストールできるバージョン一覧 |
| `mise latest go` | 最新版の番号 |
| `mise outdated` | 設定の範囲内で更新があるもの |
| `mise which python` | 実際に使われる実行ファイルのパス |
| `mise doctor` | 設定・PATH の診断 |

### 更新・削除

| コマンド | 動作 |
| --- | --- |
| `mise upgrade` | 設定の範囲内で最新に上げる（`"3.14"` なら 3.14.x の最新へ） |
| `mise upgrade --bump` | 範囲を超えて最新にし、設定ファイルも書き換える |
| `mise uninstall node@20` | 特定バージョンを削除 |
| `mise prune` | どの設定からも使われていないバージョンを削除 |
| `mise self-update` | **使わない**。mise 本体は Nix で入れているので `nix flake update` → `hm-switch` で上げる |

---

## プロジェクトごとの設定

プロジェクトのルートで `mise use` すると `mise.toml` ができる。これを commit しておけば、
clone した人も `mise install` だけで同じバージョンが揃う。

```toml
# mise.toml
[tools]
python = "3.12"
node = "22"

[env]
DATABASE_URL = "postgres://localhost/dev"
```

- ディレクトリに入った時点で自動的に切り替わる（`cd` するだけ）。親ディレクトリの `mise.toml` も継承される。
- 手元だけの設定は `mise.local.toml` に書く（`.gitignore` に入れる）。
- 他人が作った `mise.toml` に `[env]` などが書かれていると `... are not trusted` エラーで止まる。
  中身を見てから `mise trust` する（`[tools]` だけのファイルはそのまま読まれる）。
- `.nvmrc` / `.python-version` などしか無いプロジェクトでも、上の `idiomatic_version_file_enable_tools`
  を設定していればそれを読む。

---

## 言語ごとの注意

### Python

- ビルド済みバイナリ（python-build-standalone）が落ちてくるので、pyenv と違いコンパイル待ちは無い。
- venv を `cd` で自動有効化したいときは `mise.toml` に書く。初回に `.venv` が作られる:

  ```toml
  [tools]
  python = "3.12"

  [env]
  _.python.venv = { path = ".venv", create = true }
  ```

- uv を使うなら mise で入れておく: `mise use -g uv`。uv の管理するプロジェクトでも、
  Python 本体は mise のものを使わせられる（`uv` は PATH 上の Python を見つける）。
- `pip install`（venv の外）したパッケージはその Python バージョンの中に入る。バージョンを変えると見えなくなる。

### Node.js

- `npm i -g` したパッケージはその Node バージョンの中に入る。Node を上げると消えたように見えるので、
  常用する CLI は [後述](#cli-ツールもまとめて入れる) の `npm:` 形式で入れる。
- pnpm / yarn は `mise use -g pnpm` のように mise で入れるか、
  `corepack` を使う（既定では無効。`mise settings set node.corepack true`）。
- `node = "lts"` は `mise upgrade` で次の LTS に上がる。上げたくなければ `"24"` のように書く。

### Go

- `GOROOT` は mise が自動で設定する。`GOPATH` は触らない（既定の `~/go` のまま）。
- **`GOBIN` はインストール中の Go の中を指す**ので、`go install` したツールは Go のバージョンを
  上げると消える。常用するツールは `mise use -g go:golang.org/x/tools/cmd/stringer` の形で入れる。
- [default.nix](../nix/home/default.nix) で PATH に入れている `~/go/bin` は、mise 環境では使われなくなる
  （害は無いので残してよい）。

### Java

- `JAVA_HOME` は mise が自動で設定する。Gradle / Maven はこれを見る。
- ディストリビューションは `temurin-21` / `corretto-21` / `zulu-21` のように名前で選ぶ。
  一覧は `mise ls-remote java | grep ^temurin-21`。
- Gradle / Maven 本体も mise で入れられる: `mise use gradle@8` / `mise use maven@3`。
  プロジェクトに `gradlew` / `mvnw` があるならそちらを使う。
- IntelliJ IDEA は `JAVA_HOME` を見ないので、Project Structure → SDK に
  `~/.local/share/mise/installs/java/<バージョン>` を追加する。

---

## CLI ツールもまとめて入れる

言語のパッケージマネージャで入れる CLI ツールは、mise の backend 形式で入れると
**言語のバージョンを変えても消えない**・**`config.toml` に残るので別マシンでも揃う**。

```sh
mise use -g npm:typescript            # npm i -g typescript の代わり
mise use -g pipx:ruff                 # pipx install ruff の代わり（uv があれば uv で入る）
mise use -g go:golang.org/x/tools/cmd/stringer   # go install の代わり
```

LSP やフォーマッタのうち Neovim で使うものは [neovim.nix](../nix/home/neovim.nix) で Nix から入れているので、
mise で重ねて入れる必要は無い。

---

## Neovim / Nix との関係

- [neovim.nix](../nix/home/neovim.nix) は LazyVim のプラグイン用に Nix の `nodejs` / `python3` を入れているが、
  シェル上では mise のほうが PATH の前に来る（`mise activate` がプロンプトのたびに先頭へ入れ直す）。
  `which node` が mise を指していれば問題無い。
- シェルから `nvim` を起動すると、そのディレクトリの mise の環境を引き継ぐ。
  LSP がプロジェクトの Node / Python を使ってほしいときは、プロジェクトのディレクトリで起動する。
- mise 本体のバージョンは `flake.lock` の nixpkgs で決まる。`mise doctor` が新しい版の存在を警告しても、
  `mise self-update` ではなく `nix flake update` → `hm-switch` で上げる。

## トラブルシュート

| 症状 | 確認すること |
| --- | --- |
| `mise use` したのにバージョンが変わらない | `mise doctor` で `activated: yes` か。No なら `exec zsh` するか、`hm-switch` 済みか |
| `which node` が Nix（`~/.nix-profile/bin`）を指す | mise が有効になっていない。`exec zsh` して `mise doctor` |
| `mise.toml` で `not trusted` エラー | 中身を確認して `mise trust` |
| `.nvmrc` が無視される | `idiomatic_version_file_enable_tools` に `node` が入っているか |
| `go install` したツールが消えた | Go を上げたため。`go:` backend で入れ直す |
| IntelliJ が JDK を見つけない | IntelliJ に mise の JDK パスを SDK として登録する |
