{
  config,
  pkgs,
  lib,
  dotfilesDir,
  ...
}:

let
  isDarwin = pkgs.stdenv.isDarwin;
  # よく編集する対話設定 (alias/関数/挙動) はここの生ファイルを直接 source する。
  # nix store ではなく作業ツリーを指すので、編集して source で即反映できる。
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "amuse";
      plugins = [
        "git"
        "sudo" # ESC 2 回で直前のコマンドに sudo を付ける
        "docker"
        "kubectl"
        "systemd"
        "command-not-found"
        "colored-man-pages"
      ];
    };

    # alias は Nix で固定せず、末尾で source する生ファイル (.config/zsh/rc.zsh) に置く。
    # 頻繁に編集するものなので、編集して即反映 (hm-switch 不要) にするため。

    # ログインシェル (.zprofile)。macOS のみ Homebrew / OrbStack を初期化する。
    # brew shellenv は login shell で 1 度だけ評価すればよいのでここに置く。
    profileExtra = lib.optionalString isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"

      # OrbStack: command-line tools and integration
      source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :
    '';

    # 全シェルで読まれる (.zshenv)。cargo は macOS / Linux 両方あり得るので
    # 存在チェック付きで無条件に読む。
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    '';

    # Home Manager 25.05 以降は initExtra ではなく initContent を使う
    initContent = ''
      # Nix が入れたコマンドを最優先にする
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # このリポジトリを編集して即反映するためのヘルパー。
      # OS に応じて flake の attribute (…-darwin / …-linux) を切り替える。
      hm-switch() {
        local arch sys
        arch="$(uname -m | sed 's/arm64/aarch64/')"
        case "$(uname -s)" in
          Darwin) sys="$arch-darwin" ;;
          *)      sys="$arch-linux" ;;
        esac
        home-manager switch --flake "$HOME/dotfiles#$USER@$sys"
      }
    ''
    # ── macOS ホスト専用の対話設定 (旧 zsh/zshrc から移植) ──
    # pyenv / nvm は Homebrew 管理のまま維持する (A 案)。将来 Nix / mise へ
    # 寄せる場合はこのブロックを差し替える。
    + lib.optionalString isDarwin ''

      # pyenv: Python バージョン管理
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/shims:$PATH"
      eval "$(pyenv init -)"

      # nvm: Node バージョン管理 (Homebrew の nvm)
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

      # ユーザーローカルの実行ファイル
      export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/bin:$PATH"

      # よく使うエイリアス
      alias fmt-python="isort . && black ."
      alias pyMEA-classmap="pyreverse -o png -p pyMEA pyMEA"
    ''
    # よく編集する対話設定は最後に読む。実体は下の xdg.configFile が repo の作業ツリーへ
    # symlink しているので、編集したら `source ~/.config/zsh/rc.zsh` か新しいシェルで
    # 即反映される (hm-switch 不要)。
    + ''
      [ -f "${config.xdg.configHome}/zsh/rc.zsh" ] && source "${config.xdg.configHome}/zsh/rc.zsh"
    '';
  };

  # rc.zsh を ~/.config/zsh/rc.zsh へ symlink する。neovim.nix / terminals.nix と同じく
  # mkOutOfStoreSymlink なので nix store ではなくリポジトリの作業ツリーを指し、
  # 編集して即反映・そのまま commit できる。
  # (同じディレクトリの .zshrc は Home Manager が生成する別ファイル)
  xdg.configFile."zsh/rc.zsh".source = config.lib.file.mkOutOfStoreSymlink "${repo}/.config/zsh/rc.zsh";

  # zsh をログインシェルにできない環境 (chsh が使えない VM など) の保険として、
  # bash から対話シェル起動時に zsh へ委譲する。
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$ZSH_VERSION" ]] && command -v zsh > /dev/null; then
        exec zsh
      fi
    '';
  };
}
