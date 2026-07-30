{
  config,
  pkgs,
  lib,
  dotfilesDir,
  gui,
  ...
}:

# VSCode のユーザー設定を symlink する。VSCode 本体は OS 側のパッケージ管理
# (macOS: Homebrew cask / Linux: snap 等) で入れる方針なので、ここでは
# settings/keybindings のリンクだけを担う。
#
# 設定ディレクトリは OS で場所が違う:
#   macOS … ~/Library/Application Support/Code/User/  (XDG ではない)
#   Linux … ~/.config/Code/User/
#
# 【macOS】settings.json / keybindings.json の両方をリンクする。
# 【GUI 付き Linux】keybindings.json だけをリンクする。settings.json は
#   フォント指定などマシン固有の内容で macOS 版と大きく乖離しているため、
#   まとめると片方を壊すので今は管理対象外にしてある。
# ヘッドレス Linux VM (gui=false) では VSCode を使わないので何も生成しない。
let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
  macUserDir = "Library/Application Support/Code/User";
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin {
    home.file = {
      "${macUserDir}/settings.json".source = link "vscode/settings.json";
      "${macUserDir}/keybindings.json".source = link "vscode/keybindings.json";
    };
  })

  (lib.mkIf (pkgs.stdenv.isLinux && gui) {
    xdg.configFile."Code/User/keybindings.json".source = link "vscode/keybindings.json";
  })
]
