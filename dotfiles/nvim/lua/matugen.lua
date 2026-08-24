 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#111414',
    base01 = '#1e2021',
    base02 = '#282a2b',
    base03 = '#8a9295',
    base04 = '#c0c8ca',
    base05 = '#e2e2e3',
    base06 = '#e2e2e3',
    base07 = '#e2e2e3',
    base08 = '#ffb4ab',
    base09 = '#d7bfe7',
    base0A = '#b8c9cf',
    base0B = '#a2cfdc',
    base0C = '#d6bee6',
    base0D = '#a1cedb',
    base0E = '#b8c9cf',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e2e2e3',          bg = '#111414' })
  hi('TelescopeBorder',         { fg = '#8a9295',             bg = '#111414' })
  hi('TelescopePromptNormal',   { fg = '#e2e2e3',          bg = '#111414' })
  hi('TelescopePromptBorder',   { fg = '#8a9295',             bg = '#111414' })
  hi('TelescopePromptPrefix',   { fg = '#a2cfdc',             bg = '#111414' })
  hi('TelescopePromptCounter',  { fg = '#c0c8ca',  bg = '#111414' })
  hi('TelescopePromptTitle',    { fg = '#111414',             bg = '#a2cfdc' })
  hi('TelescopePreviewTitle',   { fg = '#111414',             bg = '#b8c9cf' })
  hi('TelescopeResultsTitle',   { fg = '#111414',             bg = '#d7bfe7' })
  hi('TelescopeSelection',      { fg = '#e2e2e3',          bg = '#282a2b' })
  hi('TelescopeSelectionCaret', { fg = '#a2cfdc',             bg = '#282a2b' })
  hi('TelescopeMatching',       { fg = '#a2cfdc',             bold = true })
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
