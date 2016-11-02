require 'ffi-ncurses'
require_relative 'component'
require_relative 'scrollbar'

class TextList < Component
	SCROLLBAR = true
	TEXT = false
	attr_reader :height, :width, :text

	def initialize(name, x, y, width,  height,text = '')
		super(name, x, y)
		@height = height
		@width = width
		@scrollbar = Scrollbar.new('bar', 0, 0, height, 0)
		@focusIntern = SCROLLBAR
		@boxes = []
		@text = ''
		addText(text)
		begin
			file = File.open("dump.txt", "w")
			i = 0
			@boxes.each do |arr|
				file.write("#{i} = {")
				unless (arr.empty?)
					arr.each do |xs, box|
						file.write("#{xs} = #{box}, ")
					end
					file.seek(-2, IO::SEEK_CUR)
				end
				file.write("}\n")
				i += 1
			end
			file.write("Lines = #{@scrollbar.size}")
		rescue IOError => e
			#some error occur, dir not writable etc.
		ensure
			file.close unless file.nil?
		end
	end

	def addText(text)
		text = text.split('\n')
		@text += text.join("\n")
		text.each do |value|
			value = value.split(' ')
			x = 0
			y = @boxes.length
			@boxes[y] = []
			value.each do |string|
				string = string.strip
				#while (string.length > 0)
				if (x + string.length >= @width - 1)
					if (@width - x < 4)
						@boxes[y] << [x, FormattedString.new(' ' * (@width - x - 1))]
						y += 1
						@boxes[y] = [[0, FormattedString.new(string)]]
						x = string.length
					else
						@boxes[y] << [x, FormattedString.new(' ' + string[0, @width - x - 3] + '-')]
						y += 1
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
		@scrollbar.size = @boxes.length
	end

	def refresh(window)
		@scrollbar.refresh(window)
		return if (@boxes.empty?)
		start = @scrollbar.position - @height / 2
		start = (start > 0) ? start : 0
		0.upto(@height - 1) do |y|
			FFI::NCurses.wattron(window, FFI::NCurses::WA_REVERSE) if (@focus && @focusIntern == TEXT && start + y == @scrollbar.position)
			line = @boxes[start + y]
			if (line.nil?)
				FFI::NCurses.mvwaddstr(window, @posY + y, @posX + 1, ' ' * (@width - 1))
			else
				line.each do |x, box|
					FFI::NCurses.mvwaddstr(window, @posY + y, @posX + x + 1, box.string)
				end
			end
			FFI::NCurses.wattroff(window, FFI::NCurses::WA_REVERSE) if (@focus &&  @focusIntern == TEXT && start + y == @scrollbar.position)
		end
	end

	def onKeyDown(key)
		case key
			when FFI::NCurses::KeyDefs::KEY_LEFT
				if (@focusIntern == TEXT)
					@focusIntern = SCROLLBAR
					return @scrollbar.onFocusEnter
				end
			when FFI::NCurses::KeyDefs::KEY_RIGHT
				if (@focusIntern == SCROLLBAR)
					@focusIntern = TEXT
					return @scrollbar.onFocusExit
				end
			else
				if (@focusIntern == SCROLLBAR)
					return @scrollbar.onKeyDown(key)
				end
				case key
					when FFI::NCurses::KeyDefs::KEY_UP
						@scrollbar.position = @scrollbar.position - 1
						return true
					when FFI::NCurses::KeyDefs::KEY_DOWN
						@scrollbar.position = @scrollbar.position + 1
						return true
					else
						return false
				end
		end
	end


	def onFocusEnter
		super
		if (@focusIntern == SCROLLBAR)
			@scrollbar.onFocusEnter
		end
		return true
	end

	def onFocusExit
		super
		if (@focusIntern == SCROLLBAR)
			@scrollbar.onFocusExit
		end
		return true
	end
end
