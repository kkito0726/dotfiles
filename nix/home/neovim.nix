{
  pkgs,
  config,
  dotfilesDir,
  ...
}:

let
  nvimSource = "${config.home.homeDirectory}/${dotfilesDir}/.config/nvim";
in
{
  # neovim 本体 + LazyVim のランタイム依存を入れる。
  #
  # あえて programs.neovim は使わない。programs.neovim は ~/.config/nvim/init.lua と
  # ~/.local/share/nvim/site/pack/hm を生成するが、これは下の「~/.config/nvim を
  # ディレクトリごと symlink する」設定と衝突する (init.lua の realpath が symlink
  # 越しに $HOME 外へ解決され、home-manager が "outside $HOME" で activation 失敗する)。
  # LazyVim に設定ディレクトリを丸ごと所有させ、Nix はランタイム依存の供給に徹する。
  home.packages = with pkgs; [
    neovim

    # LazyVim 本体が要求するもの
    git
    ripgrep
    fd
    gcc
    gnumake
    unzip
    curl
    tree-sitter

    # プロバイダ / 一部プラグインが使うランタイム
    nodejs
    python3

    # Lua まわり (LazyVim の設定を書くのに使う)
    lua-language-server
    stylua

    # よく使う LSP / フォーマッタ。不要なら削ってよい。
    typescript-language-server
    nixd
    nixfmt
    pyright
    ruff
    gopls
    marksman
  ];

  # ~/.config/nvim -> ~/dotfiles/.config/nvim
  #
  # この flake 自体が dotfiles リポジトリの中にあるので、switch する時点で
  # 実体は既に clone 済み。リンクを張るだけでよい。
  # mkOutOfStoreSymlink なので nix store ではなく作業ツリーを指し、
  # VM 上でそのまま編集して commit できる。
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimSource;
}
