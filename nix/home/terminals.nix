{
  config,
  dotfilesDir,
  ...
}:

# ターミナルエミュレータの設定ファイルを ~/.config 以下へ symlink する。
# ghostty / wezterm / alacritty はいずれも macOS / Linux とも XDG (~/.config) を
# 読むので、OS を問わず同じパスに配置できる。GUI が無い VM でも config ファイルを
# 置いておくだけなら無害なので、全 OS で symlink する (repo の内容をそのまま反映)。
#
# アプリ本体は macOS では Homebrew cask で入れる方針。Linux には本体を入れない
# (ヘッドレス VM 想定)。GUI Linux で本体も欲しくなったら home.packages に足す。
#
# neovim.nix / vim.nix と同じく mkOutOfStoreSymlink を使い、nix store ではなく
# リポジトリの作業ツリーを指す。これで設定を編集して即反映・そのまま commit できる。
let
  repo = "${config.home.homeDirectory}/${dotfilesDir}";
  link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";
in
{
  xdg.configFile = {
    # WezTerm: 本体設定 + キーバインド (wezterm.lua が keybinds.lua を require する)
    "wezterm/wezterm.lua".source = link ".config/wezterm/wezterm.lua";
    "wezterm/keybinds.lua".source = link ".config/wezterm/keybinds.lua";

    # Ghostty
    "ghostty/config".source = link ".config/ghostty/config";

    # Alacritty
    "alacritty/alacritty.toml".source = link ".config/alacritty/alacritty.toml";
  };
}
