require 'ffi-ncurses'

class Component
	attr_reader :name
	def initialize(name, x, y)
		@name = name
		@posX     = x
		@posY     = y
	end

	def onKeyDown(key)
		return false
	end

	def onFocusEnter
		FFI::NCurses.curs_set(0)
	end
end
