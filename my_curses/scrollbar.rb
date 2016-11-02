require 'ffi-ncurses'
require_relative 'component'

class Scrollbar < Component
	attr_reader :size, :height, :position, :pixPos
	def initialize(name, x, y, height, size)
		super(name, x, y)
		@size = size
		@height = height
		@position = 0
		@pixPos = 0
	end

	def size=(value)
		@size = value
		value = @pixPos
		@pixPos = (@position * (@height - 2)) / @size
		#@pixPos = @pixPos + ((@pixPos % (@height - 2) > @height / 2 - 1) ? 1 : 0)
		#@pixPos = @pixPos + ((@pixPos % 100 > 50) ? 1 : 0)
		unless (@pixPos == value)
			return true
		end
		return false
	end

	def position=(value)
		if (value < 0)
			value = 0
		elsif (value > @size - 1)
			value = @size - 1
		end
		@position = value
		value = @pixPos
		@pixPos = (@position * (@height - 2)) / @size
		#@pixPos = @pixPos + ((@pixPos % (@height - 2) > @height / 2 - 1) ? 1 : 0)
		unless (@pixPos == value)
			return true
		end
		return false
	end

	def refresh(window)
		FFI::NCurses.mvwaddstr(window, @posY, @posX, "\u2565")
		FFI::NCurses.mvwaddstr(window, @posY + @height - 1, @posX, "\u2568")
		1.upto(@height - 2) do |i|
			FFI::NCurses.mvwaddstr(window, @posY + i, @posX, "\u2551")
		end
		FFI::NCurses.wattron(window, FFI::NCurses::WA_REVERSE) if (@focus)
		FFI::NCurses.mvwaddstr(window, @posY + @pixPos + 1 , @posX, "\u256C")
		FFI::NCurses.wattroff(window, FFI::NCurses::WA_REVERSE) if (@focus)
	end

	def onKeyDown(key)
		case key
			when FFI::NCurses::KeyDefs::KEY_UP
				unless (@pixPos <= 0)
					@pixPos -= 1
					@position = (@pixPos * @size) / (@height - 2)
					return true
				end
			when FFI::NCurses::KeyDefs::KEY_DOWN
				unless (@pixPos >= @height - 3)
					@pixPos += 1
					@position = (@pixPos * @size) / (@height - 2)
					if (@pixPos == @height - 3)
						@position = @size - 1
					end
					return true
				end
			else
				# do nothing
		end
		return false
	end

	def onFocusEnter
		super
		return true
	end

	def onFocusExit
		super
		return true
	end
end
