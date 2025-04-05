local wezterm = require("wezterm")


local act = wezterm.action


-- table that holds the configuration
local config = {}


-- newer versions of wezterm have a 'config_builder' that provides nicer error messages
if wezterm.config_builder then
   config = wezterm.config_builder()
end


config.adjust_window_size_when_changing_font_size = false
config.automatically_reload_config = true
config.enable_scroll_bar = true
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.color_scheme = "Catppuccin Mocha"
config.font_size = 16.0
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }


-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.colors = {
   tab_bar = {
       active_tab = {
           fg_color = "#073642",
           bg_color = "#2aa198",
       },
   },
}


config.keys = {


   -- ----------------------------------------------------------------
   -- TABS
   --
   -- when possible do as tmux do
   -- ----------------------------------------------------------------


   -- Show tab navigator; similar to listing panes in tmux
   {
       key = "w",
       mods = "LEADER",
       action = act.ShowTabNavigator,
   },
   -- Create a tab (alternative to Ctrl-Shift-Tab)
   {
       key = "c",
       mods = "LEADER",
       action = act.SpawnTab("CurrentPaneDomain"),
   },
   -- Rename current tab; analagous to command in tmux
   {
       key = ",",
       mods = "LEADER",
       action = act.PromptInputLine({
           description = "Enter new name for tab",
           action = wezterm.action_callback(function(window, pane, line)
               if line then
                   window:active_tab():set_title(line)
               end
           end),
       }),
   },
   -- Move to next/previous TAB
   {
       key = "n",
       mods = "LEADER",
       action = act.ActivateTabRelative(1),
   },
   {
       key = "p",
       mods = "LEADER",
       action = act.ActivateTabRelative(-1),
   },
   -- Close tab
   {
       key = "&",
       mods = "LEADER|SHIFT",
       action = act.CloseCurrentTab({ confirm = true }),
   },


   -- ----------------------------------------------------------------
   -- PANES
   --
   -- do as tmux do
   -- ----------------------------------------------------------------


   -- -- Vertical split
   {
       -- |
       key = "|",
       mods = "LEADER|SHIFT",
       action = act.SplitPane({
           direction = "Right",
           size = { Percent = 50 },
       }),
   },
   -- Horizontal split
   {
       -- -
       key = "-",
       mods = "LEADER",
       action = act.SplitPane({
           direction = "Down",
           size = { Percent = 50 },
       }),
   },
   -- CTRL + (h,j,k,l) to move between panes
   {
       key = "h",
       mods = "CTRL",
       action = act({ EmitEvent = "move-left" }),
   },
   {
       key = "j",
       mods = "CTRL",
       action = act({ EmitEvent = "move-down" }),
   },
   {
       key = "k",
       mods = "CTRL",
       action = act({ EmitEvent = "move-up" }),
   },
   {
       key = "l",
       mods = "CTRL",
       action = act({ EmitEvent = "move-right" }),
   },
   -- ALT + (h,j,k,l) to resize panes
   {
       key = "h",
       mods = "ALT",
       action = act({ EmitEvent = "resize-left" }),
   },
   {
       key = "j",
       mods = "ALT",
       action = act({ EmitEvent = "resize-down" }),
   },
   {
       key = "k",
       mods = "ALT",
       action = act({ EmitEvent = "resize-up" }),
   },
   {
       key = "l",
       mods = "ALT",
       action = act({ EmitEvent = "resize-right" }),
   },
   -- Close/kill active pane
   {
       key = "x",
       mods = "LEADER",
       action = act.CloseCurrentPane({ confirm = true }),
   },
   -- Swap active pane with another one
   {
       key = "{",
       mods = "LEADER|SHIFT",
       action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
   },
   -- Zoom current pane (toggle)
   {
       key = "z",
       mods = "LEADER",
       action = act.TogglePaneZoomState,
   },
   {
       key = "f",
       mods = "ALT",
       action = act.TogglePaneZoomState,
   },
   -- Move to next/previous pane
   {
       key = ";",
       mods = "LEADER",
       action = act.ActivatePaneDirection("Prev"),
   },
   {
       key = "o",
       mods = "LEADER",
       action = act.ActivatePaneDirection("Next"),
   },
   { key = "RightArrow", mods = "CMD", action = wezterm.action({ ActivatePaneDirection = "Next" }) },
   { key = "LeftArrow", mods = "CMD", action = wezterm.action({ ActivatePaneDirection = "Prev" }) },
   { key = "UpArrow", mods = "CMD", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
   { key = "DownArrow", mods = "CMD", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
}


return config



