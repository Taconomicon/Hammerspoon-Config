-------------------------------------------------------------------
-- Options
-------------------------------------------------------------------

--Set this to true to snap windows by dragging them to the edge of your screen
enable_window_snapping_with_mouse = true

--Set this to true to snap windows using keyboard shortcuts (eg. Ctrl + Option + Right Arrow)
enable_window_snapping_with_keyboard = true

--The height of the window's title area (in pixels), can change if you have different sized windows (might happen one day)
--or need a different window grabbing sensitivity. Chrome is a little weird since its title area's height is non-standard
window_titlebar_height = 21

--The amount (in pixels) around the edge of the screen in which the mouse has to be let go for the drag window to count
monitor_edge_sensitivity = 1

--The time (in seconds) it takes for a window to transition to its new position and size
hs.window.animationDuration = 0.15

--The amount (in pixels) of border space around a window
window_border_size = 30











-------------------------------------------------------------------
-- Global helper functions
-------------------------------------------------------------------

-- Key Binding Utility
-- Source: https://github.com/S1ngS1ng/HammerSpoon/blob/master/key-binding.lua

local hk = require "hs.hotkey"

--- Bind hotkey for window management.
-- @function key_bind
-- @param {table} hyper - hyper key set
-- @param { ...{key=value} } keyFuncTable - multiple hotkey and function pairs
--   @key {string} hotkey
--   @value {function} callback function
function key_bind(hyper, keyFuncTable)
  for key,fn in pairs(keyFuncTable) do
    hk.bind(hyper, key, fn)
  end
end

-- End source
