require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'border'

class Window
	attr_reader :posX, :posY, :width, :height, :name, :caption
	def initialize(posX, posY, width, height, name, caption, border=nil)
		@caption = caption
		@posX = posX
		@posY = posY
		@width = width
		@height = height
		@name = name
		@border = border
		@focus = nil
		@components = {}
		@main = Canvas.addWin(self)
		if (@border.nil?)
			@content = @main
		else
			@content = FFI::NCurses.derwin(@main, 1, 1, height - 2, width - 2)
		end
		refresh
	end

	def refresh
		@components.values.each do |component|
			component.refresh
		end
		unless (@border.nil?)
			@border.refresh(@main)
		end
		FFI::NCurses.mvwaddstr(@main, 0, 2, @caption)
		FFI::NCurses.wrefresh(@main)
	end
end

begin
	window = Window.new(0, 0, 10, 5, 'blub', 'Caption', Border.new('-', '|', '+'))
	sleep(5)
ensure
	FFI::NCurses.endwin
end
