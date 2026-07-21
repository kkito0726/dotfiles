{ pkgs, lib, ... }:

{
  home.packages =
    with pkgs;
    [
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
      # bat / eza / fzf / zoxide は下の programs.*.enable が本体を入れるのでここには書かない

      # ── ビルドツール (treesitter のコンパイル等に必要) ──
      gcc
      gnumake
      pkg-config
    ]
    # ── クリップボード (Linux のみ) ──────────────────
    # nvim の `clipboard = "unnamedplus"` は外部プロバイダを必要とする。
    # X11 なら xclip、Wayland なら wl-clipboard。
    # macOS は pbcopy/pbpaste が標準で使われるため不要 (かつ darwin ではビルド不可)。
    ++ lib.optionals pkgs.stdenv.isLinux [
      xclip
      wl-clipboard
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
