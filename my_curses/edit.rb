require 'ffi-ncurses'
require_relative 'component'

class Edit < Component
	attr_reader :width, :position, :text
	def initialize(name, x, y, width)
		super(name, x, y)
		@width = width
		@position = 0
		@text = 'adjaskjdlh'
	end

	def onKeyDown(key)
		case key
			when FFI::NCurses::KeyDefs::KEY_LEFT
				@position -= 1 unless (@position == 0)
			when FFI::NCurses::KeyDefs::KEY_RIGHT
				@position += 1 unless (@position == @text.length)
			else
				unless (key.is_a? Integer)
					key = ' ' if (key == "\t")
					@text += key
					@position += 1
				end
		end
	end

	def refresh(window)
		text = @text
		if (text.length > @width)
			text = text[0, @width - 1]
		else
			text += ' ' * (@width - text.length)
		end
		FFI::NCurses.mvwaddstr(window, @posY, @posX, text)
		FFI::NCurses.wmove(window, @posY , @posX + @position)
	end

	def onFocusEnter
		super
		FFI::NCurses.curs_set(1)
		return false
	end
end
