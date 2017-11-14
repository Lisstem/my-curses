require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'component'
require_relative 'formatted_string'

class Label < Component
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
		@text = text
		text = text.split("\n")
		y = 0
		Canvas::LOGGER.debug{text}
		text.each do |string|
			while (string != nil)
				@boxes[y] = []
				@boxes[y] << [0, FormattedString.new(string[0...@width])] unless (string.length == 0)
				@boxes[y] << [string.length, FormattedString.new(' ' * (@width - string.length))] if (string.length < @width)
				string = string[@width + 1...string.length]
				y += 1
				if (y >= @height)
					Canvas::LOGGER.debug{@boxes}
					return
				end
			end
		end
		Canvas::LOGGER.debug{@boxes}
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

	methods = instance_methods(false)
	oldMethods = {}
	Canvas::LOGGER.debug{"#{self}: logged methods: #{methods.join(', ')}"}
	methods.each do |method|
		oldMethods[method] = instance_method(method)
		define_method method do |*args|
			Canvas.logMethod(self.class, self.name, method, args)
			tmp = oldMethods[method].bind(self).call(*args)
			Canvas.logReturn(tmp)
			return tmp
		end
	end
end
