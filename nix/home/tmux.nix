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
{
  # programs.tmux は使わない。あれを enable にすると
  # xdg.configFile."tmux/tmux.conf".text を HM 側が定義してしまい、
  # リポジトリの設定ファイルを mkOutOfStoreSymlink で指せなくなる
  # (同じパスの text と source は衝突する)。
  # そのため本体パッケージだけ入れて、設定ファイルは自前で置く。
  home.packages = [ pkgs.tmux ];

  # programs.tmux の secureSocket (Linux では既定 ON) が export していたもの。
  # ソケットを /tmp ではなく /run/user/$UID に置く (ログアウトで消えるがより安全)。
  # 落とすと既存の tmux サーバが新しいシェルから見えなくなるので、挙動を維持する。
  # macOS では元々 OFF (secureSocket の既定が isLinux) なので Linux 限定にする。
  home.sessionVariables = lib.mkIf pkgs.stdenv.isLinux {
    TMUX_TMPDIR = ''''${XDG_RUNTIME_DIR:-"/run/user/$(id -u)"}'';
  };

  xdg.configFile = {
    # ~/.config/tmux/tmux.conf -> ~/dotfiles/.config/tmux/tmux.conf
    # terminals.nix / neovim.nix と同じ流儀。nix store ではなく作業ツリーを
    # 指すので、編集したら prefix + r で即反映される (hm-switch 不要)。
    "tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${repo}/.config/tmux/tmux.conf";

    # store パスを含むなど、Nix でしか書けない設定はこちらへ分離する。
    # tmux.conf の末尾から source-file されるので、後勝ちで上書きが効く
    # (mode-keys vi のような repo 側の設定は潰さないよう、ここには置かないこと)。
    "tmux/nix.conf".text = ''
      # chsh が失敗しても tmux 内は zsh にする
      set -g default-shell "${pkgs.zsh}/bin/zsh"

      # truecolor を有効にする (LazyVim の配色のため)
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      set -g history-limit 50000

      # 既定の 500ms だと nvim の ESC / jj が体感で遅れる
      set -s escape-time 10
    '';
  };
}
