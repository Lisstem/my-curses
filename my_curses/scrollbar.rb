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

	def refresh(window)
		# @pixPos = (@position * (@height - 2)) / @size
		# @pixPos = @pixPos / 100 + ((@pixPos % 100 > 50) ? 1 : 0)
		FFI::NCurses.mvwaddstr(window, @posY, @posX, "\u2565")
		FFI::NCurses.mvwaddstr(window, @posY + @height - 1, @posX, "\u2568")
		1.upto(@height - 2) do |i|
			FFI::NCurses.mvwaddstr(window, @posY + i, @posX, "\u2551")
		end
		FFI::NCurses.mvwaddstr(window, @posY + @pixPos + 1 , @posX, "\u256C")
	end

	def onKeyDown(key)
		case key
			when FFI::NCurses::KeyDefs::KEY_UP
				unless (@pixPos <= 0)
					@pixPos -= 1
					@position = (@pixPos * 100 * @size) / (@height - 2)
					return true
				end
			when FFI::NCurses::KeyDefs::KEY_DOWN
				unless (@pixPos >= @height - 3)
					@pixPos += 1
					@position = (@pixPos * 100 * @size) / (@height - 2)
					return true
				end
			else
				# do nothing
		end
		return false
	end
end
