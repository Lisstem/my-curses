require 'ffi-ncurses'
require_relative 'color_manager'
require_relative 'formatted_string'
require_relative 'component'

class StringBox < Component
	attr_reader :text, :width

	def initialize(name, x, y, width, text, color = nil)
		super(name, x, y)
		@width = width
		setText(text, color)
	end

	def text=(value)
		@text = FormattedString.new(text, color)
	end

	def refresh(window)
		Color.setColor(window, @text.color)
		FFI::NCurses.mvwaddstr(window, @posY, @posX, @text.string[0...@width])
		Color.setColor(window, :default)
	end
end
