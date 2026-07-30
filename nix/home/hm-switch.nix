{
  config,
  pkgs,
  dotfilesDir,
  username,
  ...
}:

# `hm-switch` — この dotfiles を再適用するヘルパー。
#
# 【なぜシェル関数ではなく実行ファイルなのか】
# 以前は zsh.nix の initContent に関数として書いていたが、関数はシェル起動時に rc から
# 読み込まれてメモリに載るので、あとで rc を直しても既に開いているシェルは古い定義を
# 持ち続ける。実際「関数を直した直後に、それより前から開いていたターミナルで hm-switch を
# 叩き、決め打ちの古い版が走って GUI 構成が外れ、xremap が消える」という事故が起きた。
# 実行ファイルなら起動のたびに現在の中身が読まれるので、この陳腐化が原理的に起きない。
# ついでに zsh 以外 (bash / スクリプト) からも同じ挙動で呼べる。
#
# 【GUI 判定】Nix は GUI の有無を評価時に判定できないため、構成名 ($USER-gui@…) で
# 分けている (flake.nix 参照)。ここを決め打ちにすると GUI 機で再適用する度に
# keymap.nix (xremap) が消えるので、実行時に判定する:
#   1. graphical-session.target が active … デスクトップにログイン中。-gui を選び、
#      同時にマーカーを残す。
#   2. マーカーがある … 過去に GUI 機として適用済み。デスクトップ未ログインの SSH / TTY
#      から叩いても -gui を維持する。target はセッション状態なので GUI 機でも inactive に
#      なりうる。ここを見ないと「SSH から再適用したら xremap が消えた」が再発する。
#   3. どちらでもない … 従来どおりヘッドレス VM 用の $USER@… を選ぶ。
# macOS は systemd が無く、flake 側にも -gui 構成が無い (linuxSystems のみ) ので分岐しない。
#
# 引数はそのまま home-manager へ渡す (例: hm-switch --show-trace)。
let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  marker = "${config.xdg.stateHome}/hm-gui";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "hm-switch" ''
      set -eu

      arch="$(uname -m | sed 's/arm64/aarch64/')"

      case "$(uname -s)" in
        Darwin)
          attr="${username}@$arch-darwin"
          ;;
        *)
          sys="$arch-linux"
          if systemctl --user is-active -q graphical-session.target 2>/dev/null; then
            attr="${username}-gui@$sys"
            # マーカー作成に失敗しても switch 自体は続行する (判定が 1 に戻るだけ)。
            { mkdir -p "$(dirname "${marker}")" && touch "${marker}"; } || true
          elif [ -e "${marker}" ]; then
            attr="${username}-gui@$sys"
          else
            attr="${username}@$sys"
          fi
          ;;
      esac

      # 取り違えにその場で気づけるよう、選んだ attribute を表示してから実行する。
      echo "hm-switch: $attr"
      exec home-manager switch --flake "${repo}#$attr" "$@"
    '')
  ];
}
