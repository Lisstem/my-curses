require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'border'
require_relative 'string_box'
require_relative 'scrollbar'
require_relative 'component'

class Window < Component
	attr_reader :width, :height, :caption
	def initialize(name, x, y, width, height, caption, border=nil)
		super(name, x, y)
		@caption = caption
		@width = width
		@height = height
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
		FFI::NCurses.mvwaddstr(@main, 0, 2, @caption[0, @width - 3])
		FFI::NCurses.doupdate
	end

	def add(component)
		unless (@components.key?(component.name))
			@components[component.name] = component
			refresh()
		end
	end

	def focus=(value)
		@focus = @components[value]
		unless (@focus.nil?)
			@focus.onFocusEnter
		end
	end

	def focus
		return focus.name
	end

	def onFocusEnter
		@focus.onFocusEnter
	end

	def onKeyDown(key)
		if (!@focus.nil? && @focus.onKeyDown(key))
			@focus.refresh(@content)
			if (@border.nil?)
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
			else
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			end
			return true
		end
		return false
	end
end

begin
	window = Window.new('blub', 0, 0, 100, 20, 'Really really really really long caption', Border.new('-', '|', '+'))
	window.add(Scrollbar.new('testsc', 0, 0, window.height - 2, window.height - 4))
	window.focus = 'testsc'
	window.add(StringBox.new('test', 1, 0, window.width - 3, window.height - 2, 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.

Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.

Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer'))
	while true
		key = FFI::NCurses.getch
		if (key == 113) # q
			break
		else
			if (window.onKeyDown(key))
				FFI::NCurses.doupdate
			end
		end
	end
ensure
	FFI::NCurses.endwin
end
