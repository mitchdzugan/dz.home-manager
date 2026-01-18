if ("yes" == os.getenv("DZ_NVIM_CONFIG_USE_LOCAL")) then
  local fnlDirname = os.getenv("DZ_NVIM_CONFIG_CHECKOUT_PATH")
  local fennel = require("fennel").install()
  fennel["path"] = os.getenv("DZ_NVIM_CONFIG_FENNEL_PATH")
  fennel["macro-path"] = os.getenv("DZ_NVIM_CONFIG_MACRO_PATH")
  package.path = os.getenv("DZ_NVIM_CONFIG_LUA_PATH_EXTRA") .. package.path
  fennel.dofile(fnlDirname .. "/src/nvim-config.fnl").doTheThings()
else
  require("nvim-config").doTheThings()
end


local hooks = require "ibl.hooks"

-- local ibl_c1 = "#ecc7ee"
-- local ibl_c2 = "#c7c9ee"
-- local ibl_c3 = "#c9eec7"
local ibl_c1 = "#7c577e"
local ibl_c2 = "#57795e"
local ibl_c3 = "#595e77"
-- ibl_c1 = "#233c3a"
-- ibl_c2 = "#3c2325"
-- ibl_c3 = "#3c3a23"

-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "temp_ibl_dz1", { fg = ibl_c1 })
  vim.api.nvim_set_hl(0, "temp_ibl_dz2", { fg = ibl_c2 })
  vim.api.nvim_set_hl(0, "temp_ibl_dz3", { fg = ibl_c3 })
end)

vim.api.nvim_set_hl(0, "temp_ibl_dz1", { fg = ibl_c1 })
vim.api.nvim_set_hl(0, "temp_ibl_dz2", { fg = ibl_c2 })
vim.api.nvim_set_hl(0, "temp_ibl_dz3", { fg = ibl_c3 })
local ibl_highlight = {
    "temp_ibl_dz1",
    "temp_ibl_dz2",
    "temp_ibl_dz3",
}
--[[
require('hlchunk').setup({
  chunk = {
    enable = false,
    use_treesitter = false,
    -- priority = 3,
  },
  indent = {
    enable = false,
    chars = { '🮙', '🮘' },
    style = { ibl_c1, ibl_c2, ibl_c3 },
    use_treesitter = true,
    priority = 1,
  },
  line_num = {
    enable = true,
    use_treesitter = true,
    -- priority = 2,
  },
  blank = {
    enable = false,
    chars = { '🮙', '🮘' },
    style = { { fg = ibl_c1 }, { fg = ibl_c2 }, { fg = ibl_c3 } },
    use_treesitter = true,
    -- priority = 4,
  },
})
]]--
require("ibl").setup({
  indent = { char = "", highlight = ibl_highlight },
  whitespace = {
    highlight = ibl_highlight,
    remove_blankline_trail = true,
  },
  exclude = { filetypes = {"org"} },
})

--[[
require("fluoromachine").setup({
  glow = true,
  theme = 'delta',
  transparent = false,
})
vim.cmd.colorscheme 'fluoromachine'


]]--
--[[
require("rose-pine").setup({
  styles = {
    bold = true,
    italic = false,
    transparency = false,
  }
})
vim.cmd("colorscheme rose-pine")

require("nvim-tree").setup({
  hijack_cursor = true,
  hijack_netrw = false,
  actions = { open_file = { quit_on_open = true } },
})

local function ivy_dynamic_height(ratio)
  return {
    theme = "ivy",
    layout_config = {
      height = function(_, _, max_lines)
        return math.floor(max_lines * ratio)
      end
    }
  }
end

local ivy_full = ivy_dynamic_height(1.0)
local ivy_compact = ivy_dynamic_height(0.75)

require('telescope').setup{
  defaults = {
    theme = "ivy",
    layout_strategy = "vertical",
    mappings = {
      i = {
        ["<esc>"] = "close",
        ["<C-h>"] = "which_key",
      }
    }
  },
  pickers = {
    -- GLOBAL
    find_files = ivy_compact,
    live_grep = ivy_full,
    buffers = ivy_compact,
    help_tags = ivy_compact,
    current_buffer_fuzzy_find = ivy_full,
    treesitter = ivy_full,
  }
}

require("dz.markdown")

-- require('signup').setup({ })
require("nvim-paredit").setup({
  use_default_keys = false,
  indent = {
    enabled = true,
  }
})

local function notify(funname, opts)
  opts.once = vim.F.if_nil(opts.once, false)
  local level = vim.log.levels[opts.level]
  if not level then
    error("Invalid error level", 2)
  end
  local notify_fn = opts.once and vim.notify_once or vim.notify
  notify_fn(string.format("[telescope.%s]: %s", funname, opts.msg), level, {
    title = "telescope.nvim",
  })
end

if (vim.g.dz_dev == nil) then
  vim.g.dz_dev = {
    backgrounded = 0,
    tabs = {},
    start_picking = function()
      local dz_dev = vim.g.dz_dev
      dz_dev.backgrounded = 0
      vim.g.dz_dev = dz_dev
    end,
    stop_picking = function()
      return nil -- pass for now
    end,
    prenav = function (fname, newtab, col, row)
      local dz_dev =  vim.g.dz_dev
      local currfile = vim.api.nvim_buf_get_name(0)
      local tab_id = vim.api.nvim_get_current_tabpage()
      local tabs = dz_dev.tabs
      local tab = tabs[tab_id] or {}
      if (newtab) then
        tab = dz_dev.newtab or {}
      end
      local history = tab.history or {}
      local position = math.min(tab.position or 0, #history)
      local new_position = position + 1
      local new_history = {}
      for i=1, position do new_history[i] = history[i] end
      new_history[new_position] = { fname = fname, col = col, row = row }
      tab.history = new_history
      tab.position = new_position
      if (tab.last_position == nil or history[tab.last_position].fname ~= currfile) then
        tab.last_position = ((new_history[position] == nil) and new_position) or position
      end
      if (newtab) then
        dz_dev.newtab = tab
      else
        tabs[tab_id] = tab
        dz_dev.tabs = tabs
      end
      vim.g.dz_dev = dz_dev
    end
  }
end

function handle_enter (ev)
  local currfile = vim.api.nvim_buf_get_name(0)
  if (currfile == "") then return end
  local tab_id = vim.api.nvim_get_current_tabpage()
  local dz_dev =  vim.g.dz_dev
  local tabs = dz_dev.tabs
  local tab = tabs[tab_id]
  if (tab == nil) then
    tab = dz_dev.newtab or {}
  end
  local history = tab.history or {}
  local position = math.min(tab.position or 0, #history)
  local is_set = (history[position] or {}).fname == currfile
  if (not is_set) then
    local new_position = position + 1
    local new_history = {}
    for i=1, position do new_history[i] = history[i] end
    new_history[new_position] = { fname = currfile }
    tab.history = new_history
    tab.position = new_position
    if (tab.last_position == nil or history[tab.last_position].fname ~= currfile) then
      tab.last_position = ((new_history[position] == nil) and new_position) or position
    end
  end
  tabs[tab_id] = tab
  dz_dev.newtab = nil
  dz_dev.tabs = tabs
  vim.g.dz_dev = dz_dev
end

vim.api.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*"},
  callback = function(ev)
    handle_enter(ev)
  end
})

function move_in_tab_history(amount)
  local tab_id = vim.api.nvim_get_current_tabpage()
  local dz_dev =  vim.g.dz_dev
  local tabs = dz_dev.tabs
  local tab = tabs[tab_id] or {}
  local position = tab.position or 1
  local history = tab.history
  local new_position = math.min(#history, math.max(1, position + amount))
  local nav_data = history[new_position]
  if (new_position == position or nav_data == nil) then return end
  tab.position = new_position
  tabs[tab_id] = tab
  dz_dev.tabs = tabs
  vim.g.dz_dev = dz_dev
  vim.cmd("e " .. nav_data.fname)
  local row = nav_data.row
  local col = nav_data.col or 0
  if (row ~= nil) then
    vim.cmd("call cursor(" .. row .. ", " .. col ")")
  end
end

function back_tab_history() move_in_tab_history(-1) end
function frwd_tab_history() move_in_tab_history( 1) end
vim.api.nvim_create_user_command("TabHistoryBack", back_tab_history, { nargs = 0 })
vim.api.nvim_create_user_command("TabHistoryFrwd", frwd_tab_history, { nargs = 0 })
vim.keymap.set('n', 'H', ':TabHistoryBack<cr>')
vim.keymap.set('n', 'L', ':TabHistoryFrwd<cr>')

function mru_in_tab()
  local tab_id = vim.api.nvim_get_current_tabpage()
  local dz_dev =  vim.g.dz_dev
  local tabs = dz_dev.tabs
  local tab = tabs[tab_id] or {}
  local history = tab.history
  local position = tab.position or 1
  local last_position = tab.last_position or 1
  local nav_data = history[last_position]
  if (last_position == position or nav_data == nil) then return end
  tab.position = last_position
  tab.last_position = position
  tabs[tab_id] = tab
  dz_dev.tabs = tabs
  vim.g.dz_dev = dz_dev
  vim.cmd("e " .. nav_data.fname)
  local row = nav_data.row
  local col = nav_data.col or 0
  if (row ~= nil) then
    vim.cmd("call cursor(" .. row .. ", " .. col ")")
  end
end
vim.api.nvim_create_user_command("TabMRU", mru_in_tab, { nargs = 0 })

function print_dev_state ()
  print(vim.inspect(vim.g.dz_dev))
end

vim.api.nvim_create_user_command("DevState", print_dev_state, { nargs = 0 })

function apply_bg_tab(cmd)
  return function (opts)
    tab_id = vim.api.nvim_get_current_tabpage()
    vim.cmd("+" .. vim.g.dz_dev.backgrounded .. cmd .. " " .. opts.args .. " | tabn " .. tab_id)
  end
end

vim.api.nvim_create_user_command("BGtabedit", apply_bg_tab("tabe"), { nargs = "*" })
vim.api.nvim_create_user_command("BGtab"    , apply_bg_tab("tab") , { nargs = "*" })

require('nvim-cursorline').setup {
  cursorline = {
    enable = false,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}

-- require("dz.tabline")
require("dz.wk.init")

local hooks = require "ibl.hooks"

local ibl_c1 = "#ecc7ee"
local ibl_c2 = "#c7c9ee"
local ibl_c3 = "#c9eec7"

-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "temp_ibl_dz1", { fg = ibl_c1 })
  vim.api.nvim_set_hl(0, "temp_ibl_dz2", { fg = ibl_c2 })
  vim.api.nvim_set_hl(0, "temp_ibl_dz3", { fg = ibl_c3 })
end)

vim.api.nvim_set_hl(0, "temp_ibl_dz1", { fg = ibl_c1 })
vim.api.nvim_set_hl(0, "temp_ibl_dz2", { fg = ibl_c2 })
vim.api.nvim_set_hl(0, "temp_ibl_dz3", { fg = ibl_c3 })
local ibl_highlight = {
    "temp_ibl_dz1",
    "temp_ibl_dz2",
    "temp_ibl_dz3",
}
require('hlchunk').setup({
  chunk = {
    enable = true,
    use_treesitter = true,
    -- priority = 3,
  },
  indent = {
    enable = false,
    chars = { '🮙', '🮘' },
    style = { ibl_c1, ibl_c2, ibl_c3 },
    use_treesitter = true,
    priority = 1,
  },
  line_num = {
    enable = true,
    use_treesitter = true,
    -- priority = 2,
  },
  blank = {
    enable = false,
    chars = { '🮙', '🮘' },
    style = { { fg = ibl_c1 }, { fg = ibl_c2 }, { fg = ibl_c3 } },
    use_treesitter = true,
    -- priority = 4,
  },
})
require("ibl").setup({
  indent = { char = "", highlight = ibl_highlight },
  whitespace = {
    highlight = ibl_highlight,
    remove_blankline_trail = true,
  },
})

require("tokyodark").setup({})
require("image").setup({
  backend = "kitty",
  window_overlap_clear_enabled = true,
})
require("netrw").setup({})
require('guess-indent').setup({})

]]--
--[[

require('neoscroll').setup({})

require("nvimmer-ps").setup()


require('lspkind').init({
    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'text',
    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    preset = 'default',
    -- override preset symbols
    symbol_map = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "",
    },
})

vim.diagnostic.config({
  virtual_text = false,
})
require("lsp_lines").setup()

-- local keyopts = { noremap = true, silent = true }
-- vim.keymap.set({'n', 'v', 'o'}, '<c-h>', require('tree-climber').goto_parent, keyopts)
-- vim.keymap.set({'n', 'v', 'o'}, '<c-l>', require('tree-climber').goto_child, keyopts)
-- vim.keymap.set({'n', 'v', 'o'}, '<c-j>', require('tree-climber').goto_next, keyopts)
-- vim.keymap.set({'n', 'v', 'o'}, '<c-k>', require('tree-climber').goto_prev, keyopts)
-- vim.keymap.set({'v', 'o'}, 'in', require('tree-climber').select_node, keyopts)
-- vim.keymap.set('n', '<c-K>', require('tree-climber').swap_prev, keyopts)
-- vim.keymap.set('n', '<c-J>', require('tree-climber').swap_next, keyopts)
-- vim.keymap.set('n', '<c-H>', require('tree-climber').highlight_node, keyopts)

]]--
--[[
require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            default_workspace = "default",
            workspaces = {
              default = "~/Documents/neorg",
              ssbm = "/VOID/ssbm/neorg",
            }
          }
        },
        ["core.journal"] = {
          config = { workspace = "default" }
        },
        ["core.summary"] = {
          config = { strategy = "by_path" }
        },
    }
})
--]]
