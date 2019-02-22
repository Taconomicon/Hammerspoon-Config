require "wm"

-------------------------------------------------------------------
--Window snapping with Keyboard, Windows style (Sizeup Alternative)
-------------------------------------------------------------------

if enable_window_snapping_with_keyboard == true then

	key_bind({"ctrl", "cmd"}, {
		up 		= fullscreen,
		down 	= center
	})

	key_bind({"ctrl", "cmd", "shift"}, {
		up 		= b_fullscreen,
		down 	= minimize
	})

	key_bind({"ctrl", "alt"}, {
		up 		= top_half,
		down 	= bottom_half,
		left 	= left_half,
		right = right_half
	})

	key_bind({"ctrl", "alt", "shift"}, {
		up 		= b_top_half,
		down 	= b_bottom_half,
		left 	= b_left_half,
		right = b_right_half
	})

	key_bind({"ctrl", "alt", "cmd"}, {
		up 		= move_up,
		down 	= move_down,
		left 	= move_left,
		right = move_right
	})

	key_bind({"ctrl", "alt", "cmd", "shift"}, {
		up 		= b_top_left,
		down 	= b_low_right,
		left 	= b_low_left,
		right = b_top_right
	})

	-- Set window size to quaters
	hk.bind({"ctrl", "cmd"}, "=", function()
		print("Increasing window size... 1/" .. div_size .. " --> 1/" .. 2)
			div_size = 2
	end)

	-- Set window size to eighths (16ths?)
	hk.bind({"ctrl", "cmd"}, "-", function()
		print("Reducing window_size... 1/" .. div_size .. " --> 1/" .. 4)
		div_size = 4
	end)

-- this "end" is to make sure the keyboard shortcuts don't work if enable_window_snapping_with_keyboard is set to false
end
