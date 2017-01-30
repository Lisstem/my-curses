require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'component'
class Label < Component
	attr_reader :width, :width, :text
	def initialize(name, x, y, width, height, text = '')
		super(name, x, y)
		@text     = text
		@width       = width
		@height      = height
		@boxes = []
		addText(text)
	end

	def addText(text)
		text = text.split('\n')
		@text += text.join("\n")
		text.each do |value|
			value = value.split(' ')
			x = 0
			y = @boxes.length
			break if (y >= @height)
			@boxes[y] = []
			value.each do |string|
				string = string.strip
				if (x + string.length >= @width - 1)
					if (@width - x < 4)
						@boxes[y] << [x, FormattedString.new(' ' * (@width - x - 1))]
						y += 1
						break if (y >= @height)
						@boxes[y] = [[0, FormattedString.new(string)]]
						x = string.length
					else
						@boxes[y] << [x, FormattedString.new(' ' + string[0, @width - x - 3] + '-')]
						y += 1
						break if (y >= @height)
						x = @width - x - 3
						@boxes[y] = [[0, FormattedString.new(string[x, string.length - x])]]
						x = string.length - x
					end
				else
					string = ' ' + string unless (x == 0)
					@boxes[y] << [x, FormattedString.new(string)]
					x += string.length
				end
				#end
			end
			@boxes[y] << [x, FormattedString.new(' ' * (@width - x - 1))] if (x < @width - 1)
		end
	end

	def refresh(window)
		0.upto(@height - 1) do |y|
			line = @boxes[y]
			if (line.nil?)
				FFI::NCurses.mvwaddstr(window, @posY + y, @posX, ' ' * (@width - 1))
			else
				line.each do |x, box|
					FFI::NCurses.mvwaddstr(window, @posY + y, @posX + x, box.string)
				end
			end
		end
	end
end
