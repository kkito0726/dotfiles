{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      # ── VM ごとに変える箇所 ──────────────────────
      user = {
        name = "ken";
        email = "k.kito0726@gmail.com";
      };
      # ────────────────────────────────────────────

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rebase.autoStash = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "zdiff3";

      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate --all";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      ".envrc"
    ];
  };

  # git diff / git log を delta で見やすくする
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      dark = true;
    };
  };

  programs.gh.enable = true;
}
