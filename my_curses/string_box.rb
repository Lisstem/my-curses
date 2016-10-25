require 'ffi-ncurses'
require_relative 'formatted_string'
require_relative 'component'

class StringBox < Component
	attr_reader :height, :width, :text
	attr_accessor :xPos, :yPos

	def initialize(name, x, y, width, height, text)
		super(name)
		@height = height
		@width = width
		@xPos = x
		@yPos = y
		@boxes = {}
		self.text = text
	end

	def text=(value)
		@text = value
		value = value.split(' ')
		x = 0
		y = 0
		value.each do |string|
			string = string.strip
			while (string.length > 0)
				if (x + string.length > @width)
					if (@width - x < 3)
						y += 1
						break if (y > @height)
						@boxes[[0, y]] = FormattedString.new(string)
						x = string.length + 1
					else
						@boxes[[x, y]] = FormattedString.new(string[0, @width - x - 1] + '-')
						y += 1
						break if (y > @height)
						x = @width - x - 1
						@boxes[[0, y]] = FormattedString.new(string[x, string.length - x])
						x = string.length - x + 1
					end
				else
					@boxes[[x, y]] = FormattedString.new(string)
						x += string.length + 1
				end
			end
		end
	end

	def refresh(window)
		@boxes.each_pair do |pos, box|
			x, y = pos
			FFI::NCurses.mvwaddstr(window, y, x, box.string)
		end
	end
end
