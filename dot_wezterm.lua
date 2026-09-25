-- Managed by chezmoi. On WSL a run_onchange script copies this file to
-- %USERPROFILE%\.wezterm.lua; edit it in the chezmoi source, not there.
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local action = wezterm.action

if wezterm.target_triple:find('windows') then
  -- Open WSL by default, starting in the Linux home directory.
  -- Distro name must match `wsl -l`.
  config.default_domain = 'WSL:archlinux'
  config.default_cwd = '~'

  -- WSLENV lists the Windows env vars WSL may see. WEZTERM_PANE lets zsh
  -- run fastfetch only in the first pane (id 0).
  config.set_environment_variables = {
    WSLENV = 'TERM:COLORTERM:TERM_PROGRAM:TERM_PROGRAM_VERSION:WEZTERM_PANE',
  }
end

config.window_close_confirmation = 'NeverPrompt'

-- Built-in pane keys kept as-is:
--   Ctrl+Shift+Arrows      move between panes
--   Ctrl+Shift+Alt+Arrows  resize the current pane
--   Ctrl+Shift+Z           zoom the current pane (toggle)
config.keys = {
  -- Split the current pane, placing the new one below
  {
    key = 'Enter',
    mods = 'CTRL|SHIFT',
    action = action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Close just the current pane (the tab closes with its last pane)
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = action.CloseCurrentPane { confirm = false },
  },
}

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark' -- Fallback for when no GUI is available
end

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Dracula'
  else
    return 'OneHalfLight'
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

-- Mono variant: every Nerd Font icon is exactly one cell wide, so the
-- terminal and zsh agree on prompt width.
config.font = wezterm.font 'RobotoMono Nerd Font Mono'

return config
