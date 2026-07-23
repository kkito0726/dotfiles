{
  config,
  lib,
  pkgs,
  dotfilesDir,
  gui,
  ...
}:

# GUI 付き Linux 専用のキー再マップ (xremap)。
#
# 有効になるのは `gui = true` かつ Linux のときだけ (flake.nix の ken-gui@<system>)。
# macOS ホストや従来のヘッドレス Linux VM (ken@<system>) では mkIf により空になる。
#
# xremap を選ぶ理由: 設定が ~/.config/xremap/config.yml に閉じるので terminals.nix と
# 同じ mkOutOfStoreSymlink で repo 管理でき、user systemd サービスで起動できる
# (keyd は /etc + root デーモンなのでユーザー権限の Home Manager では宣言的に扱えない)。
#
# 【アプリ別に振り分ける】Super は Super のまま残し (GNOME のタイル/ワークスペース等を
# 温存)、ターミナルでは Cmd(Super)+C をコピー(Ctrl+Shift+C)に・Ctrl+C は SIGINT のまま、
# それ以外のアプリでは Super+<キー> を Ctrl+<キー> に個別変換する (config.yml 参照)。
# 振り分けにはフォーカス中ウィンドウの判別が要るため、GNOME/Wayland (Ubuntu 26.04 の
# デフォルト) 前提で gnome variant を使う。
# 別環境なら pkgs.xremap.{x11,kde,wlroots,hypr,niri,cosmic} に差し替える。
#
# 【初回のみ root で必要な設定 (Home Manager では管理できない)】docs/nix-vm.md 参照。
#   - /dev/uinput へアクセスできるよう udev ルール + input グループ追加。
#   - GNOME/Wayland ではウィンドウ判別用に「Xremap」GNOME 拡張の導入が必要。
#   - 非 systemd 環境では systemd サービスは起動しないので xremap を手動起動する。
let
  enable = pkgs.stdenv.isLinux && gui;
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";

  # GNOME/Wayland でアプリ判別を効かせるための variant。
  xremapPkg = pkgs.xremap.gnome;
in
lib.mkIf enable {
  home.packages = [ xremapPkg ];

  # neovim.nix / terminals.nix と同じく nix store ではなくリポジトリの作業ツリーを指す。
  # 設定を編集して即反映・そのまま commit できる。
  xdg.configFile."xremap/config.yml".source = link ".config/xremap/config.yml";

  # GUI 用サービスの定石。グラフィカルセッション (+ GNOME 拡張の D-Bus) が立ち上がって
  # から起動し、セッション終了で一緒に止まるよう graphical-session.target に紐付ける。
  # default.target だとセッション確立前に起動してウィンドウ判別に繋がらないことがある。
  systemd.user.services.xremap = {
    Unit = {
      Description = "xremap key remapper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${xremapPkg}/bin/xremap %h/.config/xremap/config.yml";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
