require 'ffi-ncurses'
require_relative 'color_manager'

class Canvas
	@@stdscr = FFI::NCurses.initscr  # start curses
	FFI::NCurses.cbreak
	FFI::NCurses.noecho
	@@colors = nil
	if (FFI::NCurses.has_colors)
		@@colors = ColorManager.new
	end
	@@focus = nil
	@@windows = {}
	FFI::NCurses.wrefresh(@@stdscr)


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
end
