require 'ffi-ncurses'

class Component
	attr_reader :name, :posX, :posY, :focus
	def initialize(name, x, y)
		@name = name
		@posX = x
		@posY = y
		@focus = false
	end

	def onKeyDown(key)
		return false
	end

	def onFocusEnter
		FFI::NCurses.curs_set(0)
		@focus = true
		return false
	end

	def onFocusExit
		@focus = false
		return false
	end
end
