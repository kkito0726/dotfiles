{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ── 基本 CLI ────────────────────────────────
    curl
    wget
    unzip
    gnutar
    gzip
    tree
    htop
    jq
    less
    which

    # ── モダンな置き換え系 ──────────────────────
    ripgrep # rg : LazyVim の grep 検索にも必須
    fd # find の代替 : LazyVim のファイル検索にも必須
    bat # cat の代替
    eza # ls の代替
    fzf
    zoxide

    # ── クリップボード ──────────────────────────
    # nvim の `clipboard = "unnamedplus"` は外部プロバイダを必要とする。
    # X11 なら xclip、Wayland なら wl-clipboard が使われる。
    xclip
    wl-clipboard

    # ── ビルドツール (treesitter のコンパイル等に必要) ──
    gcc
    gnumake
    pkg-config
  ];

  # ── 依存パッケージを使う CLI ツールの設定 ────────
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    bat.enable = true;

    eza = {
      enable = true;
      enableZshIntegration = false; # エイリアスは zsh.nix 側で明示する
      icons = "auto";
      git = true;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
