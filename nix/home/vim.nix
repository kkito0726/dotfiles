{
  pkgs,
  config,
  dotfilesDir,
  ...
}:

let
  vimrcSource = "${config.home.homeDirectory}/${dotfilesDir}/.vimrc";
in
{
  # 本物の Vim。neovim (LazyVim) とは別物として共存させる。
  #   vim  -> この Vim (~/.vimrc を読む)
  #   nvim -> neovim   (~/.config/nvim = LazyVim を読む)
  #
  # vim-full を使う理由: .vimrc の `set clipboard+=unnamed` は clipboard 対応
  # ビルド (+clipboard) でないと起動時に E518 を出す。軽量な pkgs.vim は
  # -clipboard なので、X11/GTK 込みの vim-full を選ぶ。
  home.packages = [ pkgs.vim-full ];

  # ~/.vimrc -> ~/dotfiles/.vimrc
  # nvim 設定と同じく、実体はリポジトリ側に置いて mkOutOfStoreSymlink で指す。
  # ホスト (macOS) が install.sh で張るリンクと同じ実体になる。
  home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink vimrcSource;
}
