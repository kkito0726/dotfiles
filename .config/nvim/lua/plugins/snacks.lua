-- LazyVim の explorer（`<leader>e`）で `.config` などのドットファイルを表示する。
-- explorer は neo-tree ではなく snacks.picker の source なので、
-- files の既定値 `hidden = false` をそのまま継承して隠しファイルが出てこない。
-- ここで explorer の source だけを上書きする（picker 直下に書くと
-- files / grep など他の picker にも波及するため）。
-- なお `ignored = true` を足すと .gitignore 対象（node_modules 等）も表示できる。
-- 実行中に一時的に切り替えたいだけなら explorer 上で `H`（hidden）/ `I`（ignored）。
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
          },
        },
      },
    },
  },
}
