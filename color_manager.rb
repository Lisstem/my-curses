require 'ffi-ncurses'

class Color
	def initialize(window)
		FFI::NCurses.start_color
		FFI::NCurses.assume_default_colors(-1, -1)
		@colors = {:black => FFI::NCurses::COLOR_BLACK, :blue => FFI::NCurses::COLOR_BLUE, :cyan => FFI::NCurses::COLOR_CYAN,
				   :green => FFI::NCurses::COLOR_GREEN, :magenta => FFI::NCurses::COLOR_MAGENTA, :red => FFI::NCurses::COLOR_RED,
				   :white => FFI::NCurses::COLOR_WHITE, :yellow => FFI::NCurses::COLOR_YELLOW}
		@pairs = {:default => 0}
		@maxColors = FFI::NCurses.tigetnum('colors')
		@maxPairs = FFI::NCurses.tigetnum('pairs')
		#printColor
	end

	def addColor(name, red, green, blue)
		if (@colors.count < @maxColors)
			@colors[name] = FFI::NCurses.color_content(@colors.count, red, green, blue)
		end
	end

	def changeColor(name, red, green, blue)
		if (@colors.key?(name))
			@colors[name] = FFI::NCurses.color_content(@colors.count, red, green, blue)
		end
	end

	def addPair(name, fg, bg)
		if (@pairs < @maxPairs)
			@pairs[name] = FFI::NCurses.init_pair(@pairs.count, fg, bg)
		end
	end

	def printColor
		begin
			puts(@maxColors)
			puts(FFI::NCurses.tigetnum('pairs'))
			1.upto @maxColors do |color|
				FFI::NCurses.init_pair(color, 7 , color - 1)
				FFI::NCurses.attr_set(FFI::NCurses::A_NORMAL, color, nil)
				FFI::NCurses.waddstr(window, '#' + (color - 1).to_s)
			end
		rescue => ex
			puts(ex.message)
		end
	end

	def self.setColor(window, color)
		FFI::NCurses.wattron(window, @pairs[color])
	end

	def self.clearColor(window, color)
		FFI::NCurses.wattroff(window, @pairs[color])
	end
end

class ColorError < StandardError
end
