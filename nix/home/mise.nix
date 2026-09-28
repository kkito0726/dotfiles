{
  lib,
  pkgs,
  config,
  dotfilesDir,
  ...
}:

let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
in
# Linux 専用。macOS ホストでは言語を Nix / mise で管理せず、zsh.nix の
# pyenv / nvm (Homebrew) を使い続けるため、ここでは何もしない。
lib.mkIf (!pkgs.stdenv.isDarwin) {
  # mise 本体 + zsh / bash への `mise activate` の差し込み。
  # globalConfig は使わないこと。値を書くと ~/.config/mise/config.toml が nix store の
  # 読み取り専用ファイルになり、下の source と衝突するうえ `mise use -g` も書けなくなる。
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # ~/.config/mise/config.toml -> ~/dotfiles/.config/mise/config.toml
  # tmux / zellij と同じ流儀。作業ツリーを直接指すので、`mise use -g` の結果が
  # そのままリポジトリに残る (hm-switch 不要)。
  xdg.configFile."mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repo}/.config/mise/config.toml";
}
