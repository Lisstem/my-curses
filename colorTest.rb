require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'color_manager'
require_relative 'colorPicker'
require_relative 'border'

begin
	window = ColorPicker.new(:window, 0, 0, 40, 20, 'Color Test', Border.new('-', '|', '+'))
	Canvas.update
	while true
		key = Canvas.getKey
		if (key == 'q') # q
			break
		else
			if (window.onKeyDown(key))
				Canvas.update
			end
		end
	end
ensure
	FFI::NCurses.endwin
end
