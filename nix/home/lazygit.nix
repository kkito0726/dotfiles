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
        # lazygit 0.61+ は git.paging (単数) を git.pagers (配列) へ移行した。
        # 旧形式のままだと起動時に自動移行を試み、home-manager 管理の
        # 読み取り専用 config への書き戻しに失敗する (permission denied)。
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          }
        ];
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
