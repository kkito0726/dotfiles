{ pkgs, config, ... }:

let
  # キーバインド定義はリポジトリ直下の .tmux.conf に単一ソース化してある。
  # それを readFile で取り込み、macOS / VM とも同じ定義を使う。
  # これで prefix / ペイン移動 / 分割の定義は 1 箇所だけになる。
  sharedConf = builtins.readFile ../../.tmux.conf;
in
{
  programs.tmux = {
    enable = true;
    mouse = true; # 実際は sharedConf の `set -g mouse on` でも入るが明示しておく

    # ── ホストの .tmux.conf には無いが、VM で必要な設定 ──
    shell = "${pkgs.zsh}/bin/zsh"; # chsh 失敗時でも tmux 内は zsh にする
    terminal = "tmux-256color";
    historyLimit = 50000;
    escapeTime = 10; # 既定の 500ms だと nvim の ESC が体感で遅れる

    extraConfig = ''
      # ── ここまで: ホスト共有の ~/.tmux.conf と同一の内容 (単一ソース) ──
      ${sharedConf}

      # ── ここから: VM 専用の上書き ──
      # truecolor を有効にする (LazyVim の配色のため)
      set -ga terminal-overrides ",*256col*:Tc"

      # sharedConf の `bind r` はホストの ~/.tmux.conf を読み直すが、VM では
      # 設定の実体が home-manager 生成ファイルなので reload 先を差し替える。
      # (後勝ちなので sharedConf 側の bind r を上書きする)
      bind r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "Reloaded!"
    '';
  };
}
