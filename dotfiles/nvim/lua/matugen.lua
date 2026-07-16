 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121319',
    base01 = '#1e1f26',
    base02 = '#292930',
    base03 = '#8f909e',
    base04 = '#c5c5d5',
    base05 = '#e3e1eb',
    base06 = '#e3e1eb',
    base07 = '#e3e1eb',
    base08 = '#ffb4ab',
    base09 = '#fdaaff',
    base0A = '#bdc4f3',
    base0B = '#bac3ff',
    base0C = '#fdaaff',
    base0D = '#bac3ff',
    base0E = '#bdc4f3',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e3e1eb',          bg = '#121319' })
  hi('TelescopeBorder',         { fg = '#8f909e',             bg = '#121319' })
  hi('TelescopePromptNormal',   { fg = '#e3e1eb',          bg = '#121319' })
  hi('TelescopePromptBorder',   { fg = '#8f909e',             bg = '#121319' })
  hi('TelescopePromptPrefix',   { fg = '#bac3ff',             bg = '#121319' })
  hi('TelescopePromptCounter',  { fg = '#c5c5d5',  bg = '#121319' })
  hi('TelescopePromptTitle',    { fg = '#121319',             bg = '#bac3ff' })
  hi('TelescopePreviewTitle',   { fg = '#121319',             bg = '#bdc4f3' })
  hi('TelescopeResultsTitle',   { fg = '#121319',             bg = '#fdaaff' })
  hi('TelescopeSelection',      { fg = '#e3e1eb',          bg = '#292930' })
  hi('TelescopeSelectionCaret', { fg = '#bac3ff',             bg = '#292930' })
  hi('TelescopeMatching',       { fg = '#bac3ff',             bold = true })
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
