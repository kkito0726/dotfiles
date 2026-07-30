{ username, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # imports は無条件にする。module 引数 (pkgs/config) を imports の中で参照すると
  # 無限再帰になるため、OS 分岐は各モジュール内部の lib.mkIf isDarwin で行う。
  # terminals.nix / vscode.nix は macOS 専用の設定 (ターミナル / VSCode の
  # 設定リンク) で、Linux では mkIf により空になる。keymap.nix は逆に GUI 付き
  # Linux (gui=true) 専用で、macOS / ヘッドレス Linux では空になる。
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./lazygit.nix
    ./neovim.nix
    ./vim.nix
    ./tmux.nix
    ./terminals.nix
    ./vscode.nix
    ./keymap.nix
    ./hm-switch.nix
  ];

  home = {
    inherit username;
    # macOS は /Users、Linux は /home。uname 相当を Nix 側で判定する。
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";

    # 初回導入時の Home Manager のバージョン。以後は上げない。
    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less -FR";
    };

    # ユーザーローカルの実行ファイル用 PATH。zsh/bash 問わず、また macOS / Linux
    # どちらでも反映される (以前は zsh.nix の macOS 専用ブロックに直書きしていた)。
    # 並び順は元の macOS の zshrc (go/bin:.local/bin:bin) をそのまま踏襲している。
    # 存在しないディレクトリが混じっていても実害は無いので OS で分岐はしない。
    sessionPath = [
      "$HOME/go/bin"
      "$HOME/.local/bin"
      "$HOME/bin"
    ];
  };

  # NixOS 以外の Linux ディストロ (Ubuntu / Debian / Fedora など) 向けに
  # ロケールや XDG_DATA_DIRS を補正する。macOS / NixOS 上では無効。
  targets.genericLinux.enable = !isDarwin;

  # `home-manager` コマンド自体も宣言的に管理する
  programs.home-manager.enable = true;

  # ~/.nix-profile 経由で XDG のデスクトップ/manpage を拾えるようにする
  xdg.enable = true;
}
