{
  pkgs,
  config,
  dotfilesDir,
  ...
}:

let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  vimrcSource = "${repo}/.vimrc";
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
  home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink vimrcSource;

  # ~/.ideavimrc -> ~/dotfiles/.ideavimrc (IntelliJ の IdeaVim 設定)。
  # IntelliJ は macOS で使う想定だが、ファイルを置くだけなら無害なので全 OS で symlink する
  # (terminals.nix と同じ方針)。
  home.file.".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${repo}/.ideavimrc";
}
