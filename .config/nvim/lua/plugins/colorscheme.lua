-- 背景を透過させて、ターミナル側の透過（Alacritty 0.75 / WezTerm 0.7 / Ghostty 0.9）を活かす。
-- floats を "normal" のままにしているのは、補完メニュー（blink.cmp）や which-key の
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
      -- explorer（snacks.nvim）を透過させる。
      -- tokyonight の styles.sidebars が効くのは neo-tree / nvim-tree で、
      -- LazyVim の explorer は snacks の picker 実装なのでそちらの対象外になる。
      -- snacks のウィンドウは winhighlight で NormalFloat を SnacksPicker* に
      -- 差し替えており、それらは既定で NormalFloat（= floats = "normal" なので不透明）に
      -- リンクされる。そこでこのグループだけ背景を落とす。
      -- NormalFloat 自体は不透明のまま残るので、blink.cmp / which-key は透けない。
      on_highlights = function(hl, c)
        for _, group in ipairs({
          "SnacksNormal",
          "SnacksNormalNC",
          "SnacksPicker",
          "SnacksPickerBox",
          "SnacksPickerList",
          "SnacksPickerInput",
          "SnacksPickerPreview",
        }) do
          hl[group] = { fg = c.fg, bg = c.none }
        end

        for _, group in ipairs({
          "SnacksPickerBoxBorder",
          "SnacksPickerListBorder",
          "SnacksPickerInputBorder",
          "SnacksPickerPreviewBorder",
        }) do
          hl[group] = { fg = c.border_highlight, bg = c.none }
        end

        -- which-key のポップアップを不透明に戻す。
        -- tokyonight は WhichKeyNormal に bg_sidebar を使うので、
        -- styles.sidebars = "transparent" にすると連動して透けてしまう。
        -- ここはフローティングウィンドウなので floats 側（bg_float）に合わせる。
        hl.WhichKeyNormal = { bg = c.bg_float }
      end,
    },
  },
}
