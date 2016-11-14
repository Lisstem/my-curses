require 'ffi-ncurses'

class Keyboard
	def initialize
		@constants = getKeyConstants
	end

	def getKeyConstants
		constants = %w(KEY_CODE_YES KEY_BREAK KEY_DOWN KEY_UP KEY_LEFT KEY_RIGHT KEY_HOME
					 KEY_BACKSPACE KEY_DL KEY_IL KEY_DC KEY_IC KEY_EIC KEY_CLEAR KEY_EOS KEY_EOL
					 KEY_SF KEY_SR KEY_NPAGE KEY_PPAGE KEY_STAB KEY_CTAB KEY_CATAB KEY_ENTER
					 KEY_SRESET KEY_RESET KEY_PRINT KEY_LL KEY_A1 KEY_A3 KEY_B2 KEY_C1 KEY_C3
					 KEY_BTAB KEY_BEG KEY_CANCEL KEY_CLOSE KEY_COMMAND KEY_COPY KEY_CREATE KEY_END
					 KEY_EXIT KEY_FIND KEY_HELP KEY_MARK KEY_MESSAGE KEY_MOVE KEY_NEXT KEY_OPEN
					 KEY_OPTIONS KEY_PREVIOUS KEY_REDO KEY_REFERENCE KEY_REFRESH KEY_REPLACE
					 KEY_RESTART KEY_RESUME KEY_SAVE KEY_SBEG KEY_SCANCEL KEY_SCOMMAND KEY_SCOPY
					 KEY_SCREATE KEY_SDC KEY_SDL KEY_SELECT KEY_SEND KEY_SEOL KEY_SEXIT KEY_SFIND
					 KEY_SHELP KEY_SHOME KEY_SIC KEY_SLEFT KEY_SMESSAGE KEY_SMOVE KEY_SNEXT
					 KEY_SOPTIONS KEY_SPREVIOUS KEY_SPRINT KEY_SREDO KEY_SREPLACE KEY_SRIGHT KEY_SRSUME
					 KEY_SSAVE KEY_SSUSPEND KEY_SUNDO KEY_SUSPEND KEY_UNDO)
		#puts(constants)
		0.upto(63) do |n|
			constants << "KEY_F#{n}"
		end
		retVal = {}
		constants.each do |constant|
			retVal[constant] = eval("FFI::NCurses::KeyDefs::#{constant}")
		end
		return retVal
	end

	def getKey
		key = FFI::NCurses.getch
		#puts(key)
		if (key < 128 || key >= 256)
			begin
				key = key.chr
			ensure
				return key
			end
		end
		#return key if (@constants.values.include?(key))
		key = [key]
		key << FFI::NCurses.getch
		key << FFI::NCurses.getch if (key[0] >= 224)
		key << FFI::NCurses.getch if (key[0] >= 240)
		return key.pack('C*').force_encoding('utf-8')
	end

	def constants
		return @constants
	end
end


=begin
	stdscr = FFI::NCurses.initscr  # start curses
	FFI::NCurses.cbreak
	FFI::NCurses.noecho
	FFI::NCurses.keypad(stdscr, true)
	file = File.open("keys.txt", "w")
	keyTest = Keyboard.new
	keyTest.constants.each_pair do |key, value|
		file.write("#{key} = #{value}\n")
	end
	while (true)
		key = keyTest.getKey
		#key = FFI::NCurses.getch
		if (key == 'q') # q 113
			break
		end
		file.write(key.to_s + "\n")
		#file.write(key.to_s(16) + "\n")
	end
ensure
	FFI::NCurses.endwin
	file.close unless file.nil?
=end
