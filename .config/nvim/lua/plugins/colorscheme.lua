-- 背景を透過させて、ターミナル側の透過（Alacritty 0.75 / WezTerm 0.7 / Ghostty 0.9）を活かす。
-- floats を "normal" のままにしているのは、補完メニューや which-key の
-- ポップアップまで透けると文字が背景と混ざって読みにくくなるため。
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "normal",
      },
    },
  },
}
