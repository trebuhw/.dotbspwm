-- Streamlined WezTerm configuration - maintains all functionality
local wezterm = require "wezterm"
local act = wezterm.action
local config = wezterm.config_builder()

-- GitHub Dark color palette
local colors = {
  fg="#d0d7de", bg="#0d1117", comment="#8b949e", red="#ff7b72",
  green="#3fb950", yellow="#d29922", blue="#539bf5", magenta="#bc8cff",
  cyan="#39c5cf", selection="#415555", caret="#58a6ff", invisibles="#2f363d"
}

-- Keybindings (aligned with Ghostty)
config.keys = {}

-- ALT: primary actions
for _, v in ipairs({
  {"Enter", act.SplitHorizontal{domain='CurrentPaneDomain'}},
  {"w", act.CloseCurrentPane{confirm=true}},
  {"t", act.SpawnTab'CurrentPaneDomain'},
  {"LeftArrow", act.ActivateTabRelative(-1)},
  {"RightArrow", act.ActivateTabRelative(1)},
  {"c", act.CopyTo'ClipboardAndPrimarySelection'},
  {"v", act.PasteFrom'Clipboard'},
  {"=", act.IncreaseFontSize},
  {"-", act.DecreaseFontSize},
  {"0", act.ResetFontSize},
}) do table.insert(config.keys, {mods="ALT", key=v[1], action=v[2]}) end

-- ALT+SHIFT: pane navigation & split management
for _, v in ipairs({
  {"Enter", act.SplitVertical{domain='CurrentPaneDomain'}},
  {"LeftArrow", act.ActivatePaneDirection'Left'},
  {"RightArrow", act.ActivatePaneDirection'Right'},
  {"z", act.TogglePaneZoomState},
  {"=", act.PaneSelect{mode='SwapWithActive'}},
}) do table.insert(config.keys, {mods="ALT|SHIFT", key=v[1], action=v[2]}) end

-- ALT+UP/DOWN: pane navigation (no conflict with tabs)
for _, v in ipairs({
  {"UpArrow", act.ActivatePaneDirection'Up'},
  {"DownArrow", act.ActivatePaneDirection'Down'},
}) do table.insert(config.keys, {mods="ALT", key=v[1], action=v[2]}) end

-- ALT+1-8: goto tab
for i = 0, 7 do table.insert(config.keys, {mods="ALT", key=tostring(i+1), action=act.ActivateTab(i)}) end

-- CTRL+SHIFT+ALT: move tabs (matches Ghostty)
for _, v in ipairs({
  {"LeftArrow", act.MoveTabRelative(-1)},
  {"RightArrow", act.MoveTabRelative(1)},
}) do table.insert(config.keys, {mods="CTRL|SHIFT|ALT", key=v[1], action=v[2]}) end

-- Font configuration
config.font = wezterm.font_with_fallback({
  {family='JetBrainsMono Nerd Font Mono', weight='Regular'},
  {family='SauceCodePro Nerd Font Mono', weight='Regular'},
  {family='IosevkaTerm Nerd Font Mono', weight='Regular'},
  {family='Lilex Nerd Font Mono', weight='Regular'},  
  {family='Symbols Nerd Font Mono', weight='Regular'}
})
config.font_size = 12
config.line_height = 1.1
config.window_frame = {
  font = wezterm.font{family='IosevkaTerm Nerd Font Mono', weight='Regular', style='Italic'},
  font_size = 12.0,
  active_titlebar_bg = colors.bg
}

-- Performance settings
config.max_fps = 120
config.animation_fps = 1
config.window_background_opacity = 0.98
config.enable_scroll_bar = false
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.warn_about_missing_glyphs = false
-- Auto-detect Wayland based on environment
local is_wayland = os.getenv("WAYLAND_DISPLAY") ~= nil or
                   os.getenv("XDG_SESSION_TYPE") == "wayland"
config.enable_wayland = is_wayland
config.front_end = "OpenGL"
config.prefer_egl = true
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- Color scheme
config.colors = {
  foreground=colors.fg, background=colors.bg,
  cursor_bg=colors.caret, cursor_fg=colors.bg, cursor_border=colors.caret,
  selection_fg=colors.fg, selection_bg=colors.selection,
  scrollbar_thumb=colors.invisibles, split=colors.invisibles,
  ansi = {colors.invisibles, colors.red, colors.green, colors.yellow,
          colors.blue, colors.magenta, colors.cyan, colors.fg},
  brights = {colors.comment, "#ff9790", "#6af28c", "#e3b341",
             "#79c0ff", "#d2a8ff", "#56d4dd", "#ffffff"},
  tab_bar = {
    background=colors.bg, inactive_tab_edge=colors.invisibles,
    active_tab={bg_color=colors.blue, fg_color=colors.bg, intensity="Bold"},
    inactive_tab={bg_color=colors.bg, fg_color=colors.comment},
    inactive_tab_hover={bg_color="#21262d", fg_color=colors.caret},
    new_tab={bg_color=colors.bg, fg_color=colors.caret, intensity="Bold"},
    new_tab_hover={bg_color="#21262d", fg_color=colors.red}
  }
}

-- Mouse bindings
config.mouse_bindings = {
  {event={Down={streak=1, button="Right"}}, mods="NONE", action=act.CopyTo("Clipboard")},
  {event={Down={streak=1, button="Middle"}}, mods="NONE", action=act.SplitHorizontal{domain="CurrentPaneDomain"}},
  {event={Down={streak=1, button="Middle"}}, mods="SHIFT", action=act.CloseCurrentPane{confirm=false}}
}

return config
