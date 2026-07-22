{
  config,
  pkgs,
  lib,
  dotfilesDir,
  ...
}:

# macOS ホスト専用。VSCode のユーザー設定を symlink する。
# VSCode 本体は Homebrew cask で入れる方針なので、ここでは settings/keybindings の
# リンクだけを担う。
#
# macOS のユーザー設定ディレクトリは XDG ではなく Application Support 配下:
#   ~/Library/Application Support/Code/User/
# home.file のキーは $HOME からの相対パスなので、そのまま指定する。
#
# Linux では mkIf により何も生成しない (default.nix から無条件 import される)。
let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  userDir = "Library/Application Support/Code/User";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
lib.mkIf pkgs.stdenv.isDarwin {
  home.file = {
    "${userDir}/settings.json".source = link "vscode/settings.json";
    "${userDir}/keybindings.json".source = link "vscode/keybindings.json";
  };
}
