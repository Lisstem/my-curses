require 'ffi-ncurses'
require_relative 'label.rb'

class Button < Component
	attr_reader :width, :width, :text
	def initialize(name, x, y, width, height, text = '')
		super(name, x, y)
		@text     = text
		@width       = width
		@height      = height
		@boxes = []
		setText(text)
	end

	def setText(text)
		text = text.split('\n')
		@text = text.join("\n")
		y = 0
		@boxes = []
		text.each do |value|
			value = value.split(' ')
			break if (y >= @height)
			tmp = ''
			value.each do |string|
				string = string.strip
				if (tmp.length + string.length >= @width - 1)
					temp = (@width - tmp.length)
					@boxes[y] = [[0, FormattedString.new(' ' * (temp / 2 + temp % 2) + tmp + ' ' * (temp / 2))]]
					y += 1
					tmp = string
				else
					tmp += " #{string}"
				end
			end
			temp = (@width - tmp.length)
			@boxes[y] = [[0, FormattedString.new(' ' * (temp / 2 + temp % 2) + tmp + ' ' * (temp / 2))]]
			y += 1
		end
	end

	def refresh(window)
		FFI::NCurses.wattron(window, FFI::NCurses::WA_REVERSE) if (@focus)
		0.upto(@height - 1) do |y|
			Canvas::LOGGER.debug{@boxes}
			line = @boxes[y]
			if (line.nil?)
				FFI::NCurses.mvwaddstr(window, @posY + y, @posX, ' ' * @width)
			else
				line.each do |x, box|
					FFI::NCurses.mvwaddstr(window, @posY + y, @posX + x, box.string)
				end
			end
		end
		FFI::NCurses.wattroff(window, FFI::NCurses::WA_REVERSE) if (@focus)
	end

	def onFocusEnter
		FFI::NCurses.curs_set(0)
		@focus = true
		return true
	end

	def onFocusExit
		@focus = false
		return true
	end

	def onEnter
		@boxes = []
		@text = ''
		setText('blub')
		return true
	end

	def onKeyDown(key)
		case key
			when "\n"
				return onEnter
			else
				return false
		end
	end
end
