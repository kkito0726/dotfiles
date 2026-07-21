{
  config,
  pkgs,
  lib,
  dotfilesDir,
  ...
}:

# macOS ホスト専用。ターミナルエミュレータの設定ファイルを ~/.config 以下へ
# symlink する。アプリ本体 (WezTerm / Ghostty / Alacritty) は Homebrew cask で
# 入れる方針なので、ここでは設定ファイルのリンクだけを担う。
#
# neovim.nix / vim.nix と同じく mkOutOfStoreSymlink を使い、nix store ではなく
# リポジトリの作業ツリーを指す。これで設定を編集して即反映・そのまま commit できる。
#
# Linux では mkIf により何も生成しない (default.nix から無条件 import される)。
let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
lib.mkIf pkgs.stdenv.isDarwin {
  xdg.configFile = {
    # WezTerm: 本体設定 + キーバインド (wezterm.lua が keybinds.lua を require する)
    "wezterm/wezterm.lua".source = link ".config/wezterm/wezterm.lua";
    "wezterm/keybinds.lua".source = link ".config/wezterm/keybinds.lua";

    # Ghostty
    "ghostty/config".source = link ".config/ghostty/config";

    # Alacritty
    "alacritty/alacritty.toml".source = link ".config/alacritty/alacritty.toml";
  };
}
