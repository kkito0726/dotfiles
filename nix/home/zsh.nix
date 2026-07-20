{ config, ... }:

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
      theme = "robbyrussell";
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

    shellAliases = {
      ls = "eza --group-directories-first";
      ll = "eza -l --group-directories-first --git";
      la = "eza -la --group-directories-first --git";
      lt = "eza --tree --level=2";
      cat = "bat";
      v = "nvim";
      # vim は本物の Vim (vim.nix) を指すので alias は張らない
      lg = "lazygit";
      hm = "home-manager";
    };

    # Home Manager 25.05 以降は initExtra ではなく initContent を使う
    initContent = ''
      # Nix が入れたコマンドを最優先にする
      export PATH="$HOME/.nix-profile/bin:$PATH"

      # ディレクトリ移動を快適にする
      setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
      setopt INTERACTIVE_COMMENTS

      # 補完で大文字小文字を区別しない
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select

      # このリポジトリを編集して即反映するためのヘルパー
      hm-switch() {
        home-manager switch --flake "$HOME/nix-config-vm#$USER@$(uname -m | sed 's/arm64/aarch64/')-linux"
      }
    '';
  };

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
