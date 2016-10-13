require 'ffi-ncurses'

class ColorManager
	def initialize
		FFI::NCurses.start_color
		FFI::NCurses.assume_default_colors(-1, -1)
		@colors = {:default => 0}

		begin
			puts(FFI::NCurses.tigetnum('colors'))
			puts(FFI::NCurses.tigetnum('pairs'))
		rescue => ex
			puts(ex.message)
		end
	end

	def addColor

	end
end

class ColorError < StandardError
end
