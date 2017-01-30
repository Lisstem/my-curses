require 'ffi-ncurses'
require_relative 'canvas'
require_relative 'border'
require_relative 'component'

class Window < Component
	attr_reader :width, :height, :caption

	def initialize(name, x, y, width, height, caption, border=nil)
		super(name, x, y)
		@caption     = caption
		@width       = width
		@height      = height
		@border      = border
		@focusIntern = 0
		@components  = {}
		@focusList = []
		@main        = Canvas.addWin(self)
		if (@border.nil?)
			@content = FFI::NCurses.newpad(height, width)
		else
			@content = FFI::NCurses.newpad(height - 1, width - 1)
		end
		refresh
	end

	def refresh
		FFI::NCurses.wnoutrefresh(@main)
		@components.values.each do |component|
			component.refresh(@content)
		end
		if (@border.nil?)
			FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
		else
			FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			@border.refresh(@main)
		end
		FFI::NCurses.mvwaddstr(@main, 0, 2, @caption[0, @width - 3])
	end

	def add(component, focusAble = false)
		unless (@components.key?(component.name))
			@components[component.name] = component
			if (focusAble)
				@focusList << component
			end
			refresh
		end
	end

	def setFocus(value)
		tmp = false
		unless (@focusList[@focusIntern].nil?)
			if (@focusList[@focusIntern].onFocusExit)
				@focusList[@focusIntern].refresh(@content)
				tmp = true
			end
		end
		@focusIntern = value
		unless (@focusList[@focusIntern].nil?)
			if (@focusList[@focusIntern].onFocusEnter)
				@focusList[@focusIntern].refresh(@content)
				tmp = true
			end
			@focusList[@focusIntern].refresh(@content)
		end
		if (tmp)
			if (@border.nil?)
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
			else
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			end
		end
		return tmp
	end

	def focusNext
		nex = @focusIntern + 1
		if (nex >= @focusList.count)
			nex = 0
		end
		return setFocus(nex)
	end

	def focusPrevious
		nex = @focusIntern - 1
		if (nex < 0)
			nex = @focusList.count - 1
		end
		return setFocus(nex)
	end

	def focus
		return @focusList[@focusIntern].name
	end

	def onFocusEnter
		unless (@focusList[@focusIntern].nil?)
			@focusList[@focusIntern].onFocusEnter
			@focusList[@focusIntern].refresh(@content)
			if (@border.nil?)
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 0, 0, @height, @width)
			else
				FFI::NCurses.pnoutrefresh(@content, 0, 0, 1, 1, @height - 2, @width - 2)
			end
			return true
		end
		return false
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
