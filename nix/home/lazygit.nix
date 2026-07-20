{ ... }:

{
  programs.lazygit = {
    enable = true;

    settings = {
      gui = {
        nerdFontsVersion = "3"; # ターミナル側で Nerd Font を使っていない場合は "" にする
        showIcons = true;
        showCommandLog = false;
        mouseEvents = true;
        sidePanelWidth = 0.25;
      };

      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        autoFetch = true;
        overrideGpg = false;
      };

      os.editPreset = "nvim";

      keybinding.universal.quit = "q";

      confirmOnQuit = false;
      disableStartupPopups = true;
      notARepository = "skip";
    };
  };
}
