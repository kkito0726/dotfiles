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

    # alias は Nix で固定せず、末尾で source する生ファイル (~/.zshrc) に置く。
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

      # hm-switch はここには置かない。シェル関数だと、関数を直したあとも既存のシェルが
      # 古い定義を持ち続けて事故るため、実行ファイルにしてある (hm-switch.nix)。
    ''
    # ── macOS ホスト専用の対話設定 ──
    # ここに置くのは「macOS でしか成立しない」ものだけに絞る。pyenv / nvm は Homebrew
    # 管理のまま維持する (A 案)。将来 Nix / mise へ寄せる場合はこのブロックを差し替える。
    #   - OS 非依存の alias   … ~/.zshrc (即反映できるので)
    #   - ユーザーローカル PATH … home.sessionPath (default.nix, zsh/bash 共通)
    # を担当とし、ここには書かない。
    + lib.optionalString isDarwin ''

      # pyenv: Python バージョン管理
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/shims:$PATH"
      eval "$(pyenv init -)"

      # nvm: Node バージョン管理 (Homebrew の nvm)
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    ''
    # よく編集する対話設定は最後に ~/.zshrc から読む。dotDir=~/.config/zsh のため zsh の
    # 本体 rc は ~/.config/zsh/.zshrc (HM 生成) で、~/.zshrc は自動では読まれず空いている。
    # そこを下の home.file が repo の作業ツリーへ symlink するので、~/.zshrc を編集したら
    # `source ~/.zshrc` か新しいシェルで即反映される (hm-switch 不要)。
    # ※ ZDOTDIR は ~/.config/zsh なので、ここは必ず $HOME/.zshrc を指すこと (無限再帰回避)。
    + ''
      [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
    '';
  };

  # 普段編集する zsh 設定の実体はリポジトリの .zshrc。.vimrc / .ideavimrc と同じ流儀で
  # ~/.zshrc へ mkOutOfStoreSymlink する (nix store ではなく作業ツリーを指すので即反映)。
  # HM の本体 rc は ~/.config/zsh/.zshrc なので、この ~/.zshrc とは衝突しない。
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${repo}/.zshrc";

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
