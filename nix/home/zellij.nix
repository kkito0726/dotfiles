{
  config,
  dotfilesDir,
  ...
}:

let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
in
{
  programs.zellij = {
    enable = true;

    # settings / extraConfig は空のままにすること。
    # どちらかに値を書くと HM が xdg.configFile."zellij/config.kdl".text を
    # 定義してしまい、下の source と衝突する (tmux.nix と同じ事情)。
    # 空なら HM 側は config.kdl を一切定義しないので、実体をリポジトリに置ける。

    # zsh 起動時に zellij を自動起動しない。
    # この既定値は home.shell.enableShellIntegration (= true) を継承するため、
    # 明示的に false にしないと全ての対話シェルが zellij の中で立ち上がる。
    # tmux と併用して試している段階なので、起動は手動 (`zellij`) に任せる。
    enableZshIntegration = false;
  };

  # ~/.config/zellij/config.kdl -> ~/dotfiles/.config/zellij/config.kdl
  # tmux / terminals.nix と同じ流儀。nix store ではなく作業ツリーを指すので、
  # 編集したら zellij を起動し直すだけで反映される (hm-switch 不要)。
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/.config/zellij/config.kdl";
}
