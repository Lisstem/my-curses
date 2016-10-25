require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'border'
require_relative 'string_box'

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
			@content = FFI::NCurses.newpad(height, width)
		else
			@content = FFI::NCurses.newpad(height - 1, width - 1)
		end
		refresh
	end

	def refresh
		FFI::NCurses.mvwaddstr(@main, 0, 2, @caption)
		FFI::NCurses.wnoutrefresh(@main)
		@components.values.each do |component|
			component.refresh(@content)
		end
		if (@border.nil?)
			FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
		else
			FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			@border.refresh(@main)
		end
		FFI::NCurses.doupdate
	end

	def add(component)
		unless (@components.key?(component.name))
			@components[name] = component
			refresh
		end
	end
end

begin
	window = Window.new(0, 0, 50, 20, 'blub', 'Caption', Border.new('-', '|', '+'))
	window.add(StringBox.new('test', 0, 0, 8, 18, 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.

Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.

Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer'))
	FFI::NCurses.getch
ensure
	FFI::NCurses.endwin
end
