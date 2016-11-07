require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'border'
require_relative 'component'

class Window < Component
	attr_reader :width, :height, :caption
	def initialize(name, x, y, width, height, caption, border=nil)
		super(name, x, y)
		@caption     = caption
		@width       = width
		@height      = height
		@border      = border
		@focusIntern = nil
		@components  = {}
		@main        = Canvas.addWin(self)
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
		unless (@focusIntern.nil?)
			@focusIntern.onFocusExit
		end
		@focusIntern = @components[value]
		unless (@focusIntern.nil?)
			@focusIntern.onFocusEnter
		end
	end

	def focus
		return focus.name
	end

	def onFocusEnter
		unless (@focusIntern.nil?)
			@focusIntern.onFocusEnter
			@focusIntern.refresh(@content)
			if (@border.nil?)
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
			else
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			end
			return true
		end
		return false
	end

	def onKeyDown(key)
		if (!@focusIntern.nil? && @focusIntern.onKeyDown(key))
			@focusIntern.refresh(@content)
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
