require 'ffi-ncurses'

class Border
	attr_reader :top, :bottom, :left, :right, :topLeft, :topRight, :bottomLeft, :bottomRight
	def initialize(top, left, vertex, bottom = top, right = left,
			topRight = vertex, bottomLeft = vertex, bottomRight = vertex)
		@top = top.codepoints.first
		@bottom = bottom.codepoints.first
		@left = left.codepoints.first
		@right = right.codepoints.first
		@topLeft = vertex.codepoints.first
		@topRight = topRight.codepoints.first
		@bottomLeft = bottomLeft.codepoints.first
		@bottomRight = bottomRight.codepoints.first
	end

	def name
		return ''
	end

	def refresh(window)
		FFI::NCurses.wborder(window, @left, @right, @top, @bottom, @topLeft, @topRight, @bottomLeft, @bottomRight)
	end

	methods = [:refresh]
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
