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

	def logMethod(name, params)
		Canvas::LOGGER.debug{"Window##{@name}: #{name}(#{params.join(',')})"}
	end

	def refresh(window)
		logMethod('refresh', [window])
		FFI::NCurses.wborder(window, @left, @right, @top, @bottom, @topLeft, @topRight, @bottomLeft, @bottomRight)
	end
end
