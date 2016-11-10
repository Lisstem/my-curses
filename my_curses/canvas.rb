require 'ffi-ncurses'
require_relative 'color_manager'
require_relative 'keyboard'

class Canvas
	@@stdscr = FFI::NCurses.initscr  # start curses
	FFI::NCurses.cbreak
	FFI::NCurses.noecho
	FFI::NCurses.keypad(@@stdscr, true)
	FFI::NCurses.curs_set(0)
	@@colors = nil
	if (FFI::NCurses.has_colors)
		@@colors = ColorManager.new(@@stdscr)
	end
	@@focus = nil
	@@windows = {}
	FFI::NCurses.wrefresh(@@stdscr)
	@@keyboard = Keyboard.new


	def self.rows
		return FFI::NCurses.getmaxy(@@stdscr)
	end

	def self.cols
		return FFI::NCurses.getmaxx(@@stdscr)
	end

	def self.endWin
		FFI::NCurses.endwin
	end

	def self.addWin(window)
		if (@@windows.key?(window.name))
			raise RuntimeError.new("Window \"#{window.name}\" already exists")
		end
		@@windows[window.name] = window
		if (@@focus.nil?)
			@@focus = window
		end
		return FFI::NCurses.derwin(@@stdscr, window.height, window.width, window.posY, window.posX)
	end

	def self.getKey
		return @@keyboard.getKey
	end
end
