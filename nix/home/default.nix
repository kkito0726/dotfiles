{ username, ... }:

{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./lazygit.nix
    ./neovim.nix
    ./tmux.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # 初回導入時の Home Manager のバージョン。以後は上げない。
    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less -FR";
    };
  };

  # NixOS 以外の Linux ディストロ (Ubuntu / Debian / Fedora など) 向けに
  # ロケールや XDG_DATA_DIRS を補正する。NixOS 上で使うときは false にする。
  targets.genericLinux.enable = true;

  # `home-manager` コマンド自体も宣言的に管理する
  programs.home-manager.enable = true;

  # ~/.nix-profile 経由で XDG のデスクトップ/manpage を拾えるようにする
  xdg.enable = true;
}
