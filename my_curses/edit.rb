require 'ffi-ncurses'
require_relative 'component'

class Edit < Component
	attr_reader :width, :cursor, :text
	def initialize(name, x, y, width)
		super(name, x, y)
		@width = width
		@cursor = 0
		@position = 0
		@text = 'adjaskjdlh'
	end

	def onKeyDown(key)
		case key
			when FFI::NCurses::KeyDefs::KEY_LEFT
				unless (@cursor <= 0)
					@cursor -= 1
					if (@cursor <= @position && @position != 0)
						@position -= 1
					end
				end
			when FFI::NCurses::KeyDefs::KEY_RIGHT
				unless (@cursor >= @text.length)
					@cursor += 1
					if (@cursor - @position >= @width)
						@position += 1
					end
				end
			when FFI::NCurses::KeyDefs::KEY_BACKSPACE, 8.chr('ASCII')
				if (@cursor > 0)
					@text.slice!(@cursor - 1)
					@cursor -= 1
					if (@cursor <= @position && @position != 0)
						@position -= 1
					end
				end
			when FFI::NCurses::KeyDefs::KEY_DC
				if (@cursor < @text.length)
					@text.slice!(@cursor)
				end
			when "\n"
				@text.insert(@cursor, '\n')
				@cursor += 2
				if (@cursor - @position >= @width)
					@position += 2
				end
			else
				unless (key.is_a? Integer)
					key = ' ' if (key == "\t")
					@text.insert(@cursor, key)
					@cursor += 1
					if (@cursor - @position >= @width)
						@position += 1
					end
				end
		end
		return true
	end

	def refresh(window)
		text = @text
		if (text.length - @position > @width)
			text = text[@position, @width - 1]
		else
			text = text[@position, text.length]
		end
		text += ' ' * (@width - text.length) if (@width - text.length > 0)
		FFI::NCurses.mvwaddstr(window, @posY, @posX, text)
		#FFI::NCurses.mvwaddstr(window, @posY - 1, @posX, '%3d:%3d' % [@position, @cursor])
		FFI::NCurses.wmove(window, @posY , @posX + @cursor - @position)
	end

	def onFocusEnter
		super
		FFI::NCurses.curs_set(1)
		return false
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
