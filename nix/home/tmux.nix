{ pkgs, config, ... }:

{
  # ホストの ~/.tmux.conf と同じキーバインドを再現する。
  # (ホスト側のファイルは dotfiles リポジトリ管理外なので、ここでは
  #  Nix で宣言的に持つ。dotfiles に移すならこのファイルは削ってよい)
  programs.tmux = {
    enable = true;

    # prefix を C-q にする。
    # unbind C-b / set -g prefix / bind C-q send-prefix はこの option が生成する。
    prefix = "C-q";

    mouse = true;

    # ── 以下はホストの .tmux.conf には無いが、VM で使うために入れている ──
    shell = "${pkgs.zsh}/bin/zsh"; # chsh 失敗時でも tmux 内は zsh にする
    terminal = "tmux-256color";
    historyLimit = 50000;
    escapeTime = 10; # 既定の 500ms だと nvim の ESC が体感で遅れる
    # ──────────────────────────────────────────────────────────────────

    extraConfig = ''
      # truecolor を有効にする (LazyVim の配色のため)
      set -ga terminal-overrides ",*256col*:Tc"

      # vim のキーバインドでペインを移動します。
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind | split-window -h
      bind v split-window -v
      bind s choose-tree -Zw

      # ホストでは ~/.tmux.conf を読み直していたが、ここでの設定の実体は
      # home-manager が生成する nix store 上のファイル。設定を変えるには
      # home-manager switch が必要で、r はその後の再読み込みに使う。
      bind r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded!"
    '';
  };
}
