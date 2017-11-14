require_relative 'window'
require_relative 'color_manager'
require_relative 'edit'
require_relative 'label'

class ColorPicker < Window
	def initialize(name, x, y, width, height, caption, border=nil)
		super(name, x, y, width, height, caption, border)
		add(Label.new(:label, 0, 0, 5, 5, "  red\n\ngreen\n\n blue"), false)
		add(Edit.new(:red, 6, 0, 4, '0'), true)
		add(Edit.new(:green, 6, 2, 4, '0'), true)
		add(Edit.new(:blue, 6, 4, 4, '0'), true)
		add(Label.new(:color, 10, 0, 5, 5, ' ' * 25))
		0.upto 2 do |i|
			Canvas::LOGGER.debug{@focusList[i]}
		end
		Canvas::LOGGER.debug{@focusList}
		setFocus(0)
		refresh
	end

	def onKeyDown(key)
		case key
			when "\t"
				return focusNext
			when 353
				return focusPrevious
			else
				if (!@focusList[@focusIntern].nil? && @focusList[@focusIntern].onKeyDown(key))
					@focusList[@focusIntern].refresh(@content)

					if (@border.nil?)
						FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
					else
						FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
					end
					return true
				end
		end
		return false
	end
end
