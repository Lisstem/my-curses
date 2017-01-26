require 'ffi-ncurses'
require 'logger'
require_relative 'color_manager'
require_relative 'keyboard'

class Canvas
	LOGGER = Logger.new(File.new("curses.log",'w'))
	LOGGER.level = Logger::DEBUG
	LOGGER.formatter = proc do |severity, datetime, progname, msg|
		date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
		if severity == 'INFO' or severity == 'WARN'
			"[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
		else
			"[#{date_format}] #{severity} (#{progname}): #{msg}\n"
		end
	end
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
	@@logDepth = 0;


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

	def self.update
		LOGGER.debug{"#{"\t" * @@logDepth}<Canvas>: Updated terminal."}
		FFI::NCurses.doupdate
	end

	def self.logMethod(clas, name, method, *args)
		Canvas::LOGGER.debug{"#{"\t" * @@logDepth}<#{clas}:#{name}>: #{method}(#{args.join(', ')}) {"}
		@@logDepth += 1
	end

	def self.logReturn(returnValue)
		@@logDepth -= 1
		Canvas::LOGGER.debug("#{"\t" * @@logDepth}} => #{returnValue}")
	end
end
