 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131318',
    base01 = '#1f1f24',
    base02 = '#2a292f',
    base03 = '#908f9c',
    base04 = '#c7c5d2',
    base05 = '#e4e1e8',
    base06 = '#e4e1e8',
    base07 = '#e4e1e8',
    base08 = '#ffb4ab',
    base09 = '#ffbcef',
    base0A = '#c2c4e7',
    base0B = '#cacdff',
    base0C = '#fcadeb',
    base0D = '#bdc2ff',
    base0E = '#c2c4e7',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e4e1e8',          bg = '#131318' })
  hi('TelescopeBorder',         { fg = '#908f9c',             bg = '#131318' })
  hi('TelescopePromptNormal',   { fg = '#e4e1e8',          bg = '#131318' })
  hi('TelescopePromptBorder',   { fg = '#908f9c',             bg = '#131318' })
  hi('TelescopePromptPrefix',   { fg = '#cacdff',             bg = '#131318' })
  hi('TelescopePromptCounter',  { fg = '#c7c5d2',  bg = '#131318' })
  hi('TelescopePromptTitle',    { fg = '#131318',             bg = '#cacdff' })
  hi('TelescopePreviewTitle',   { fg = '#131318',             bg = '#c2c4e7' })
  hi('TelescopeResultsTitle',   { fg = '#131318',             bg = '#ffbcef' })
  hi('TelescopeSelection',      { fg = '#e4e1e8',          bg = '#2a292f' })
  hi('TelescopeSelectionCaret', { fg = '#cacdff',             bg = '#2a292f' })
  hi('TelescopeMatching',       { fg = '#cacdff',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
