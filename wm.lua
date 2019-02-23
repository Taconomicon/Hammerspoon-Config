require "config"

-------------------------------------------------------------------
-- Hammerspoon config to replace Cinch & Size-up window management

-- Source: spartanatreyu, Major revisions by Dylan Mink (Taconomicon)
-------------------------------------------------------------------

-------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------

--required to be non zero for dragging windows to work some weird timing issue with hammerspoon fighting against osx events
if hs.window.animationDuration <= 0 then
	hs.window.animationDuration = 0.00000001
end

--flag for dragging, 0 means no drag, 1 means dragging a window, -1 means dragging but not dragging the window
dragging = 0

--the window being dragged
dragging_window = nil

-- flags for quarter windows
x_pos = "none"
y_pos = "none"
div_size = 2

window_border_size_double = window_border_size * 2

-------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------

-- Exists because lua doesn't have a round function. WAT?!
function round(num)
	return math.floor(num + 0.5)
end

--based on kizzx2's hammerspoon-move-resize.lua
function get_window_under_mouse()
	-- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it
	-- and breaks itself
	local _ = hs.application

	local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
	local my_screen = hs.mouse.getCurrentScreen()

	return hs.fnutils.find(hs.window.orderedWindows(), function(w)
		return my_screen == w:screen() and my_pos:inside(w:frame())
	end)
end

-- Set quater window flags based on current window position
function set_quad()
	local win = hs.window.focusedWindow()
	local max = win:screen():frame()
	local f = win:frame()

	if (f.x < (max.w / 2)) then
		x_pos = "left"
	else
		x_pos = "right"
	end

	if (f.y < (max.h / 2)) then
		y_pos = "high"
	else
		y_pos = "low"
	end

	-- print("Pos: " .. x_pos .. " / " .. y_pos)
	-- print("Pos: (" .. f.x .. ", " .. f.y .. ")")
end

-- Returns target if in bounds, otherwise closest of min or max
function set_bounds(min, max, target)
	local ret = target

	if (target >= max) then
		ret = max
	elseif (target <= min) then
		ret = min
	end

	return ret
end

-- Define edges of screen
function get_edges(screen, window)
	local space = {}

	space.x_min = screen.x + window_border_size
	space.x_max = screen.x + screen.w - window_border_size - window.w
	space.y_min = screen.y + window_border_size
	space.y_max = screen.y + screen.h - window_border_size - window.h

	return space
end

-- Horizontal translation
-- Div: Dividing factor for the window size
	-- Ex: div == 2 for 50%. div == 4 for 25%.
-- Left: T/F flag for moving left or right
function translate_x(div, left)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	-- Set desired dimensions for window
	if (div == 0) then
		f.w = (max.w / 2) - window_border_size_double
		f.h = max.h - window_border_size_double
	else
		f.w = (max.w / div) - window_border_size_double
		f.h = (max.h / div) - window_border_size_double
	end

	-- Redefine window frame for windows which cannot be reduced in size
	win:setFrame(f)
	f = win:frame()

	local edges = get_edges(max, f)

	-- Define translation (moving x "left" is actually reducing the value)
	local x_new = x_min

	if (left) then
		x_new = f.x - (f.w + window_border_size_double)
	else
		x_new = f.x + (f.w + window_border_size_double)
	end

	-- Position window at location within max borders
	-- print ("Calling set_bounds(" .. x_min .. ", " .. x_max .. ", " .. x_new .. ")")
	f.x = set_bounds(edges.x_min, edges.x_max, x_new)
	-- print ("Calling set_bounds(" .. y_min .. ", " .. y_max .. ", " .. f.y .. ")")
	f.y = set_bounds(edges.y_min, edges.y_max, f.y)
	win:setFrame(f)
end

-- Vertical translation
-- Div: Dividing factor for the window size
	-- Ex: div == 2 for 50%. div == 4 for 25%.
-- Left: T/F flag for moving left or right
function translate_y(div, up)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	-- Set desired dimensions for window
	if (div == 0) then
		f.w = max.w - window_border_size_double
		f.h = (max.h / 2) - window_border_size_double
	else
		f.w = (max.w / div) - window_border_size_double
		f.h = (max.h / div) - window_border_size_double
	end

	-- Redefine window frame for windows which cannot be reduced in size
	win:setFrame(f)
	f = win:frame()

	local edges = get_edges(max, f)

	local y_new = nil
	-- Define translation (moving y "upwards" is actually reducing the value)
	if (up) then
		y_new = f.y - (f.h + window_border_size_double)
	else
		y_new = f.y + (f.h + window_border_size_double)
	end

	-- Position window at location within max borders
	-- print ("Calling set_bounds(" .. x_min .. ", " .. x_max .. ", " .. f.x .. ")")
	f.x = set_bounds(edges.x_min, edges.x_max, f.x)
	-- print ("Calling set_bounds(" .. edges.y_min .. ", " .. edges.y_max .. ", " .. y_new .. ")")
	f.y = set_bounds(edges.y_min, edges.y_max, y_new)
	win:setFrame(f)
end

function call_borderless(func)
	set_quad()

	local hold = window_border_size

	window_border_size, window_border_size_double = 0, 0

	func()

	window_border_size = hold
	window_border_size_double = hold * 2
end

function minimize()
		hs.window.focusedWindow():minimize()
end

-------------------------------------------------------------------
-- Window movements
-------------------------------------------------------------------

function fullscreen()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + window_border_size
	f.y = max.y + window_border_size
	f.w = max.w - window_border_size_double
	f.h = max.h - window_border_size_double
	win:setFrame(f)
end

function center()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w / 4)
	f.y = max.y + (max.h / 4)
	f.w = max.w / 2
	f.h = max.h / 1.5
	win:setFrame(f)
end

function top_half()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + window_border_size
	f.y = max.y + window_border_size
	f.w = max.w - window_border_size_double
	f.h = (max.h / 2) - window_border_size_double
	win:setFrame(f)
end

function bottom_half()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + window_border_size
	f.y = (max.h / 2) + window_border_size
	f.w = max.w - window_border_size_double
	f.h = (max.h / 2) - window_border_size_double
	win:setFrame(f)
end

function left_half()
	set_quad()
	translate_x(0, true)
end

function right_half()
	set_quad()
	translate_x(0, false)

	-- local win = hs.window.focusedWindow()
	-- local f = win:frame()
	-- local screen = win:screen()
	-- local max = screen:frame()
	--
	-- -- Set desired dimensions for window
	-- f.w = (max.w / 2) - window_border_size_double
	-- f.h = max.h - window_border_size_double
	-- -- Redefine window frame
	-- win:setFrame(f)
	-- f = win:frame()
	--
	-- local edges = get_edges(max, f)
	-- local x_new = f.x + (f.w + window_border_size_double)
	-- -- Align window with right border
	-- if ((x_new + f.w) >= edges.x_max) then
	-- 	x_new = edges.x_max - f.w
	-- end
	--
	-- f.x = set_bounds(edges.x_min, edges.x_max, x_new)
	-- f.y = set_bounds(edges.y_min, edges.y_max, f.y)
	-- win:setFrame(f)
end

function move_up()
		set_quad()
		translate_y(div_size, true)
end

function move_down()
		set_quad()
		translate_y(div_size, false)
end

function move_left()
		set_quad()
		translate_x(div_size, true)
end

function move_right()
		set_quad()
		translate_x(div_size, false)
end

function b_fullscreen() 	call_borderless(fullscreen)		end

function b_top_half()  		call_borderless(top_half) 		end
function b_bottom_half() 	call_borderless(bottom_half)	end
function b_left_half()  	call_borderless(left_half) 		end
function b_right_half() 	call_borderless(right_half) 	end

function b_move_up()  		call_borderless(move_up) 			end
function b_move_down() 		call_borderless(move_down) 		end
function b_move_left()  	call_borderless(move_left) 		end
function b_move_right() 	call_borderless(move_right) 	end

-------------------------------------------------------------------
--Window snapping with mouse, Windows style (Cinch Alternative)
-------------------------------------------------------------------

--Setup drag start and dragging
click_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseDragged}, function(e)

	--if drag is just starting...
	if dragging == 0 then
		dragging_window = get_window_under_mouse()
		--if mouse over a window...
		if dragging_window ~= nil then

			local m = hs.mouse.getAbsolutePosition()
			local mx = round(m.x)
			local my = round(m.y)
			--print('mx: ' .. mx .. ', my: ' .. my)

			local f = dragging_window:frame()
			local screen = dragging_window:screen()
			local max = screen:frame()
			--print('fx: ' .. f.x .. ', fy: ' .. f.y .. ', fw: ' .. f.w .. ', fh: ' .. f.h)

			--if mouse inside titlebar horizontally
			if mx > f.x and mx < (f.x + f.w) then
				--print('mouse is inside titlebar horizontally')

				--if mouse inside titlebar vertically
				if my > f.y and my < (f.y + window_titlebar_height) then
					--print('mouse is inside titlebar')

					dragging = 1
					--print(' - start dragging - window: ' .. dragging_window:id())

				else
					--print('mouse is not inside titlebar')
					dragging = -1
					dragging_window = nil
				end
			else
				--print('mouse is not inside titlebar horizontally')
				dragging = -1
				dragging_window = nil
			end

		end
	--else if drag is already going
	--[[
	else
		if dragging_window ~= nil then
			local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
			local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)

			local m = hs.mouse.getAbsolutePosition()
			local mx = round(m.x)
			local my = round(m.y)

			print(' - dragging: ' .. mx .. "," .. my .. ". window id: " .. dragging_window:id())
		end
	]]--
	end
end)

--Setup drag end
unclick_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(e)

	--print('unclick, dragging: ' .. dragging)

	--if dragging the mouse
	if dragging == 1 then

		--if the mouse is dragging a window
		if dragging_window ~= nil then

			--print('letting go of window: ' .. dragging_window:id())

			local m = hs.mouse.getAbsolutePosition()
			local mx = round(m.x)
			local my = round(m.y)

			--print('mx: ' .. mx .. ', my: ' .. my)

			local win = dragging_window
			local f = win:frame()
			local screen = win:screen()
			local max = screen:frame()

			if mx < monitor_edge_sensitivity and my < monitor_edge_sensitivity then
				x_pos = "left"
				y_pos = "high"

				f.x = max.x
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx > monitor_edge_sensitivity and mx < (max.w - monitor_edge_sensitivity) and my < monitor_edge_sensitivity then
				x_pos = "none"
				y_pos = "none"

				f.x = max.x
				f.y = max.y
				f.w = max.w
				f.h = max.h
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my < monitor_edge_sensitivity then
				x_pos = "right"
				y_pos = "high"

				f.x = max.x + (max.w / 2)
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx < monitor_edge_sensitivity and my < (max.h - monitor_edge_sensitivity) and my > monitor_edge_sensitivity then
				x_pos = "left"
				y_pos = "none"

				f.x = max.x
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my > monitor_edge_sensitivity and my < (max.h - monitor_edge_sensitivity) then
				x_pos = "right"
				y_pos = "none"

				f.x = max.x + (max.w / 2)
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h
				win:setFrame(f)
			elseif mx < monitor_edge_sensitivity and my > (max.h - monitor_edge_sensitivity) then
				x_pos = "left"
				y_pos = "low"

				f.x = max.x
				f.y = max.y + (max.h / 2)
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my > (max.h - monitor_edge_sensitivity) then
				x_pos = "right"
				y_pos = "low"

				f.x = max.x + (max.w / 2)
				f.y = max.y + (max.h / 2)
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			end

		end
		--print("end dragging")
	end

	dragging = 0
	dragging_window = nil
end)

--Start watching for dragging (AKA: turn dragging on)
if enable_window_snapping_with_mouse == true then
	click_event:start()
	unclick_event:start()
end
