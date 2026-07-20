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
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # vim / vi は本物の Vim (vim.nix) に譲るため alias は張らない。
    viAlias = false;
    vimAlias = false;

    # LazyVim のプラグインは lazy.nvim が管理するため、
    # ここでは Nix でプラグインを入れずランタイム依存だけを揃える。
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;

    extraPackages = with pkgs; [
      # LazyVim 本体が要求するもの
      git
      ripgrep
      fd
      gcc
      gnumake
      unzip
      curl
      tree-sitter

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
  };

  # ~/.config/nvim -> ~/dotfiles/.config/nvim
  #
  # この flake 自体が dotfiles リポジトリの中にあるので、switch する時点で
  # 実体は既に clone 済み。リンクを張るだけでよい。
  # mkOutOfStoreSymlink なので nix store ではなく作業ツリーを指し、
  # VM 上でそのまま編集して commit できる。
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimSource;
}
