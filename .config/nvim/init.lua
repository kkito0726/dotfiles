-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- クリップボードをOSと共有する
vim.opt.clipboard = "unnamedplus"

keymap("i", "jj", "<ESC>", opts)
keymap("v", "ff", "<ESC>", opts)
-- expandtab オプションを設定します。タブ文字をスペースに変換します。
vim.cmd("set expandtab")

-- tabstop オプションを設定します。タブ文字の幅を4スペースに設定します。
vim.cmd("set tabstop=4")

-- softtabstop オプションを設定します。インサートモードでのタブの幅を4スペースに設定します。
vim.cmd("set softtabstop=4")

-- shiftwidth オプションを設定します。インデントに使用するスペースの幅を4スペースに設定します。
vim.cmd("set shiftwidth=4")
