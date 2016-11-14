require 'ffi-ncurses'

class ColorManager
	def initialize(window)
		FFI::NCurses.start_color
		FFI::NCurses.assume_default_colors(-1, -1)
		@colors = {:default => 0}
		@colorCount = FFI::NCurses.tigetnum('colors')
		#printColor
	end

	def addColor

	end

	def printColor
		begin
			puts(@colorCount)
			puts(FFI::NCurses.tigetnum('pairs'))
			1.upto @colorCount do |color|
				FFI::NCurses.init_pair(color, 7 , color - 1)
				FFI::NCurses.attr_set(FFI::NCurses::A_NORMAL, color, nil)
				FFI::NCurses.waddstr(window, '#' + (color - 1).to_s)
			end
		rescue => ex
			puts(ex.message)
		end
	end
end

class ColorError < StandardError
end
